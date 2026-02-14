"""
Operation routes: CRUD, validation workflow, AI integration.

Workflow:
- Receipt: employee validates → triggers AI transfer creation
- Transfer: supervisor approves/overrides → employee executes → validates
- Picking: AI creates from preparation order → supervisor approves → employee executes
- Delivery: employee executes and validates
"""

import random
from datetime import datetime
from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.enums import OperationType, OperationStatus
from app.repositories.operation_repository import OperationRepository
from app.repositories.operation_log_repository import OperationLogRepository
from app.repositories.product_repository import ProductRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.repositories.chariot_repository import ChariotRepository
from app.repositories.user_repository import UserRepository
from app.schemas.operation import OperationCreate, OperationApprove, OperationResponse
from app.ai.storage_optimizer import storage_optimizer
from app.ai.picking_optimizer import picking_optimizer
from app.ai.pathfinding import get_pathfinder
from app.utils.dependencies import get_current_user, get_supervisor_user
from app.utils.logger import logger

router = APIRouter()
operation_repo = OperationRepository()
operation_log_repo = OperationLogRepository()
product_repo = ProductRepository()
emplacement_repo = EmplacementRepository()
chariot_repo = ChariotRepository()
user_repo = UserRepository()


# ── LIST / READ ──────────────────────────────────────────────────


@router.get("/", response_model=List[OperationResponse])
async def list_operations(
    operation_type: Optional[OperationType] = Query(default=None, description="Filter by type"),
    employee_id: Optional[str] = Query(default=None, description="Filter by employee"),
    status: Optional[OperationStatus] = Query(default=None, description="Filter by status"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all operations with optional filters."""
    ops = await operation_repo.get_filtered(
        operation_type=operation_type,
        employee_id=employee_id,
        status=status,
    )
    return [OperationResponse(**o) for o in ops]


@router.get("/pending", response_model=List[OperationResponse])
async def list_pending_operations(
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all pending operations."""
    ops = await operation_repo.get_by_status(OperationStatus.PENDING)
    return [OperationResponse(**o) for o in ops]


@router.get("/{operation_id}", response_model=OperationResponse)
async def get_operation(
    operation_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a single operation by ID."""
    op = await operation_repo.get_by_id_or_raise(operation_id)
    return OperationResponse(**op)


@router.get("/employee/{employee_id}/operations", response_model=List[OperationResponse])
async def get_employee_operations(
    employee_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all operations assigned to a specific employee."""
    ops = await operation_repo.get_by_employee(employee_id)
    return [OperationResponse(**o) for o in ops]


@router.get("/{operation_id}/logs")
async def get_operation_logs(
    operation_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all log entries for a specific operation."""
    logs = await operation_log_repo.get_by_operation(operation_id)
    return logs


@router.get("/{operation_id}/destination-info")
async def get_destination_info(
    operation_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Get detailed info about the destination emplacement of an operation.

    Returns coordinates, slot availability, product info, etc.
    """
    op = await operation_repo.get_by_id_or_raise(operation_id)
    emplacement_id = op.get("emplacement_id")
    if not emplacement_id:
        return {"error": "No destination emplacement set for this operation"}

    emplacement = await emplacement_repo.get_by_id(emplacement_id)
    if not emplacement:
        return {"error": f"Emplacement {emplacement_id} not found"}

    return {
        "emplacement_id": emplacement_id,
        "x": emplacement.get("x"),
        "y": emplacement.get("y"),
        "z": emplacement.get("z", 0),
        "floor": emplacement.get("floor", 0),
        "is_slot": emplacement.get("is_slot", False),
        "is_occupied": emplacement.get("is_occupied", False),
        "is_expedition": emplacement.get("is_expedition", False),
        "current_product_id": emplacement.get("product_id"),
        "current_quantity": emplacement.get("quantity", 0),
    }


# ── CREATE ───────────────────────────────────────────────────────


async def _create_operation(
    data: OperationCreate, op_type: OperationType, current_user: Dict
) -> OperationResponse:
    """Helper to create an operation of a given type."""
    op_data = data.model_dump()
    op_data["type"] = op_type.value
    op_data["status"] = OperationStatus.PENDING.value
    if not op_data.get("employee_id"):
        op_data["employee_id"] = current_user["id"]
    created = await operation_repo.create(op_data)

    # Log creation
    await _log_operation(created["id"], "created", created)

    return OperationResponse(**created)


@router.post("/receipt", response_model=OperationResponse, status_code=201)
async def create_receipt_operation(
    data: OperationCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Create a receipt operation."""
    return await _create_operation(data, OperationType.RECEIPT, current_user)


@router.post("/transfer", response_model=OperationResponse, status_code=201)
async def create_transfer_operation(
    data: OperationCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Create a transfer operation."""
    return await _create_operation(data, OperationType.TRANSFER, current_user)


@router.post("/picking", response_model=OperationResponse, status_code=201)
async def create_picking_operation(
    data: OperationCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Create a picking operation."""
    return await _create_operation(data, OperationType.PICKING, current_user)


@router.post("/delivery", response_model=OperationResponse, status_code=201)
async def create_delivery_operation(
    data: OperationCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Create a delivery operation."""
    return await _create_operation(data, OperationType.DELIVERY, current_user)


# ── APPROVE (Supervisor approves AI suggestion) ─────────────────


@router.put("/{operation_id}/approve", response_model=OperationResponse)
async def approve_operation(
    operation_id: str,
    override: Optional[OperationApprove] = None,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Supervisor approves an operation (optionally with overrides).

    For transfer/picking operations:
    - If override data provided, updates the operation fields first (logs override)
    - Assigns a random available chariot
    - Generates AI route to destination
    - Sets status to 'in_progress'
    """
    op = await operation_repo.get_by_id_or_raise(operation_id)
    now = datetime.utcnow().isoformat()

    if op.get("status") != OperationStatus.PENDING.value:
        from app.core.exceptions import ConflictError
        raise ConflictError("Operation is not in pending status")

    update_data = {}

    # Handle override if provided
    if override:
        override_fields = override.model_dump(exclude_unset=True)
        if override_fields:
            update_data.update(override_fields)
            # Log override
            await _log_operation(operation_id, "overridden", {
                **op,
                **override_fields,
                "overridor_id": current_user["id"],
                "overriden_at": now,
            })

    # Assign chariot for transfer/picking (not receipt/delivery)
    op_type = op.get("type")
    if op_type in (OperationType.TRANSFER.value, OperationType.PICKING.value):
        if not op.get("chariot_id") and not update_data.get("chariot_id"):
            chariot = await _assign_random_chariot(operation_id)
            if chariot:
                update_data["chariot_id"] = chariot["id"]

    # Generate route to destination
    dest_emplacement_id = update_data.get("emplacement_id") or op.get("emplacement_id")
    source_emplacement_id = update_data.get("source_emplacement_id") or op.get("source_emplacement_id")
    if dest_emplacement_id and source_emplacement_id:
        route = await _generate_route(source_emplacement_id, dest_emplacement_id)
        if route:
            update_data["suggested_route"] = route

    # Set status to in_progress
    update_data["status"] = OperationStatus.IN_PROGRESS.value
    updated = await operation_repo.update(operation_id, update_data)

    # Log approval
    await _log_operation(operation_id, "approved", {
        **updated,
        "validator_id": current_user["id"],
    })

    return OperationResponse(**updated)


# ── VALIDATE (Employee/Supervisor completes operation) ───────────


@router.put("/{operation_id}/validate", response_model=OperationResponse)
async def validate_operation(
    operation_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Validate (complete) an operation. Any authenticated user.

    Behavior depends on operation type:
    - Receipt: increments reception_freq, triggers AI transfer creation
    - Transfer: updates emplacement stock, releases chariot
    - Picking: increments demand_freq, triggers delivery creation
    - Delivery: increments delivery_freq, closes the loop
    """
    op = await operation_repo.get_by_id_or_raise(operation_id)
    op_type = op.get("type")
    op_status = op.get("status")

    # Receipt can go from pending → validated (employee validates directly)
    # Transfer/Picking go from in_progress → validated
    # Delivery goes from pending/in_progress → validated
    valid_statuses = [OperationStatus.PENDING.value, OperationStatus.IN_PROGRESS.value]
    if op_status not in valid_statuses:
        from app.core.exceptions import ConflictError
        raise ConflictError(f"Operation cannot be validated from status '{op_status}'")

    if op_status == OperationStatus.VALIDATED.value:
        from app.core.exceptions import ConflictError
        raise ConflictError("Operation is already validated")

    now = datetime.utcnow().isoformat()
    product_id = op.get("product_id")

    # Update operation status
    update_data = {
        "status": OperationStatus.VALIDATED.value,
        "validator_id": current_user["id"],
        "validated_at": now,
    }
    updated = await operation_repo.update(operation_id, update_data)

    # Log validation
    await _log_operation(operation_id, "validated", {
        **updated,
        "validator_id": current_user["id"],
        "validated_at": now,
    })

    # Type-specific post-validation triggers
    if op_type == OperationType.RECEIPT.value:
        await _on_receipt_validated(op, operation_id, current_user)
    elif op_type == OperationType.TRANSFER.value:
        await _on_transfer_validated(op)
    elif op_type == OperationType.PICKING.value:
        await _on_picking_validated(op, operation_id, current_user)
    elif op_type == OperationType.DELIVERY.value:
        await _on_delivery_validated(op)

    return OperationResponse(**updated)


@router.delete("/{operation_id}", status_code=204)
async def delete_operation(
    operation_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete an operation. Supervisor/Admin only."""
    # Release chariot if assigned
    op = await operation_repo.get_by_id_or_raise(operation_id)
    if op.get("chariot_id"):
        await chariot_repo.update(op["chariot_id"], {"assigned_to_operation_id": None})
    await operation_repo.delete(operation_id)


# ── POST-VALIDATION TRIGGERS ────────────────────────────────────


async def _on_receipt_validated(
    op: Dict[str, Any], operation_id: str, current_user: Dict[str, Any]
) -> None:
    """
    After receipt validation:
    1. Increment product reception_freq
    2. Use AI storage_optimizer to suggest destination emplacement
    3. Find source expedition zone
    4. Generate route via pathfinder
    5. Create transfer operation (status=pending for supervisor approval)
    """
    product_id = op.get("product_id")

    # 1. Increment reception frequency
    if product_id:
        await _increment_product_frequency(product_id, "reception_freq")

    # 2. AI suggests best storage slot
    dest_emplacement_id = None
    if product_id:
        suggestions = await storage_optimizer.suggest_slot(product_id, top_n=1)
        if suggestions:
            best_slot = suggestions[0]
            dest_emplacement_id = best_slot.get("id")

    # 3. Find expedition zone as source
    source_emplacement_id = None
    expedition_zones = await emplacement_repo.get_expedition_zones()
    if expedition_zones:
        source_emplacement_id = expedition_zones[0].get("id")

    # 4. Generate route
    suggested_route = None
    if source_emplacement_id and dest_emplacement_id:
        suggested_route = await _generate_route(source_emplacement_id, dest_emplacement_id)

    # 5. Create transfer operation (pending supervisor approval)
    now = datetime.utcnow().isoformat()
    transfer_data = {
        "type": OperationType.TRANSFER.value,
        "status": OperationStatus.PENDING.value,
        "product_id": product_id,
        "quantity": op.get("quantity", 0),
        "employee_id": op.get("employee_id"),
        "chariot_id": None,  # assigned on approval
        "order_id": op.get("order_id"),
        "emplacement_id": dest_emplacement_id,
        "source_emplacement_id": source_emplacement_id,
        "suggested_route": suggested_route,
    }
    created_transfer = await operation_repo.create(transfer_data)

    # Log transfer creation
    await _log_operation(created_transfer["id"], "created", created_transfer)

    logger.info(
        f"Transfer operation {created_transfer['id']} created after receipt "
        f"{operation_id} validation → dest={dest_emplacement_id}"
    )


async def _on_transfer_validated(op: Dict[str, Any]) -> None:
    """
    After transfer validation:
    1. Update destination emplacement stock
    2. Release the chariot
    3. Increment relevant product frequencies
    """
    product_id = op.get("product_id")
    quantity = op.get("quantity", 0)
    emplacement_id = op.get("emplacement_id")

    # 1. Update destination emplacement stock
    if emplacement_id and product_id:
        emplacement = await emplacement_repo.get_by_id(emplacement_id)
        if emplacement:
            current_qty = emplacement.get("quantity", 0)
            new_qty = current_qty + quantity
            await emplacement_repo.update(emplacement_id, {
                "product_id": product_id,
                "quantity": new_qty,
                "is_occupied": True,
            })

    # 2. Release chariot
    chariot_id = op.get("chariot_id")
    if chariot_id:
        await chariot_repo.update(chariot_id, {"assigned_to_operation_id": None})


async def _on_picking_validated(
    op: Dict[str, Any], operation_id: str, current_user: Dict[str, Any]
) -> None:
    """
    After picking validation:
    1. Decrement source emplacement stock
    2. Increment demand_freq
    3. Release chariot
    4. Create delivery operation
    """
    product_id = op.get("product_id")
    quantity = op.get("quantity", 0)
    source_emplacement_id = op.get("source_emplacement_id")

    # 1. Decrement source emplacement
    if source_emplacement_id and product_id:
        emplacement = await emplacement_repo.get_by_id(source_emplacement_id)
        if emplacement:
            current_qty = emplacement.get("quantity", 0)
            new_qty = max(current_qty - quantity, 0)
            await emplacement_repo.update(source_emplacement_id, {
                "quantity": new_qty,
                "is_occupied": new_qty > 0,
                "product_id": product_id if new_qty > 0 else None,
            })

    # 2. Increment demand frequency
    if product_id:
        await _increment_product_frequency(product_id, "demand_freq")

    # 3. Release chariot
    chariot_id = op.get("chariot_id")
    if chariot_id:
        await chariot_repo.update(chariot_id, {"assigned_to_operation_id": None})

    # 4. Create delivery operation
    active_employees = await user_repo.get_active_employees()
    employee_id = None
    if active_employees:
        employee = random.choice(active_employees)
        employee_id = employee["id"]

    delivery_data = {
        "type": OperationType.DELIVERY.value,
        "status": OperationStatus.PENDING.value,
        "product_id": product_id,
        "quantity": quantity,
        "employee_id": employee_id,
        "order_id": op.get("order_id"),
        "emplacement_id": None,
        "source_emplacement_id": None,
    }
    created_delivery = await operation_repo.create(delivery_data)
    await _log_operation(created_delivery["id"], "created", created_delivery)

    logger.info(f"Delivery operation {created_delivery['id']} created after picking {operation_id}")


async def _on_delivery_validated(op: Dict[str, Any]) -> None:
    """
    After delivery validation:
    1. Increment delivery_freq
    2. Release chariot if any
    """
    product_id = op.get("product_id")
    if product_id:
        await _increment_product_frequency(product_id, "delivery_freq")

    chariot_id = op.get("chariot_id")
    if chariot_id:
        await chariot_repo.update(chariot_id, {"assigned_to_operation_id": None})


# ── HELPER FUNCTIONS ─────────────────────────────────────────────


async def _increment_product_frequency(product_id: str, field: str) -> None:
    """Increment a product's frequency field by 1."""
    product = await product_repo.get_by_id(product_id)
    if product:
        current_value = product.get(field, 0.0)
        await product_repo.update(product_id, {field: current_value + 1.0})


async def _assign_random_chariot(operation_id: str) -> Optional[Dict[str, Any]]:
    """Assign a random available chariot to an operation."""
    available = await chariot_repo.get_available()
    if not available:
        logger.warning(f"No available chariots for operation {operation_id}")
        return None
    chariot = random.choice(available)
    await chariot_repo.update(chariot["id"], {"assigned_to_operation_id": operation_id})
    return chariot


async def _generate_route(
    source_emplacement_id: str, dest_emplacement_id: str
) -> Optional[list]:
    """Generate a route between two emplacements using the pathfinder."""
    source = await emplacement_repo.get_by_id(source_emplacement_id)
    dest = await emplacement_repo.get_by_id(dest_emplacement_id)
    if not source or not dest:
        return None

    pathfinder = get_pathfinder()
    start = (source.get("x", 0), source.get("y", 0), source.get("floor", 0))
    goal = (dest.get("x", 0), dest.get("y", 0), dest.get("floor", 0))

    result = pathfinder.find_path(start, goal)
    if result:
        return result.get("path")
    return None


async def _log_operation(
    operation_id: str, action: str, op_data: Dict[str, Any]
) -> None:
    """Create an OperationLog entry for an operation event."""
    await operation_log_repo.create({
        "operation_id": operation_id,
        "action": action,
        "type": op_data.get("type"),
        "product_id": op_data.get("product_id"),
        "quantity": op_data.get("quantity", 0),
        "employee_id": op_data.get("employee_id"),
        "chariot_id": op_data.get("chariot_id"),
        "order_id": op_data.get("order_id"),
        "emplacement_id": op_data.get("emplacement_id"),
        "validator_id": op_data.get("validator_id"),
        "validated_at": op_data.get("validated_at"),
        "overridor_id": op_data.get("overridor_id"),
        "overriden_at": op_data.get("overriden_at"),
        "date": datetime.utcnow().isoformat(),
    })

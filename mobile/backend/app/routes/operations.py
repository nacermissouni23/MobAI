"""
Operation routes: CRUD, lifecycle management (start, complete, validate),
with stock ledger integration.
"""

from datetime import datetime
from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.enums import OperationType, OperationStatus
from app.core.exceptions import ValidationError, StockError
from app.repositories.operation_repository import OperationRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.repositories.stock_ledger_repository import StockLedgerRepository
from app.repositories.chariot_repository import ChariotRepository
from app.schemas.operation import OperationCreate, OperationResponse
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
operation_repo = OperationRepository()
emplacement_repo = EmplacementRepository()
ledger_repo = StockLedgerRepository()
chariot_repo = ChariotRepository()


@router.get("/", response_model=List[OperationResponse])
async def list_operations(
    operation_type: Optional[OperationType] = Query(default=None, description="Filter by type"),
    status_filter: Optional[OperationStatus] = Query(default=None, description="Filter by status"),
    employee_id: Optional[str] = Query(default=None, description="Filter by employee"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all operations with optional filters."""
    ops = await operation_repo.get_filtered(
        operation_type=operation_type,
        status_filter=status_filter,
        employee_id=employee_id,
    )
    return [OperationResponse(**o) for o in ops]


@router.get("/pending/all", response_model=List[OperationResponse])
async def get_pending_operations(
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all pending operations."""
    ops = await operation_repo.get_pending()
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


async def _create_operation(data: OperationCreate, op_type: OperationType, current_user: Dict) -> OperationResponse:
    """Helper to create an operation of a given type."""
    op_data = data.model_dump()
    op_data["type"] = op_type.value
    op_data["status"] = OperationStatus.PENDING.value
    if not op_data.get("employee_id"):
        op_data["employee_id"] = current_user["id"]
    created = await operation_repo.create(op_data)
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


@router.put("/{operation_id}/start", response_model=OperationResponse)
async def start_operation(
    operation_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Start (begin) an operation."""
    op = await operation_repo.get_by_id_or_raise(operation_id)

    if op.get("status") != OperationStatus.PENDING.value:
        raise ValidationError(f"Operation must be PENDING to start. Current: {op.get('status')}")

    update_data = {
        "status": OperationStatus.IN_PROGRESS.value,
        "started_at": datetime.utcnow().isoformat(),
        "employee_id": current_user["id"],
    }
    updated = await operation_repo.update(operation_id, update_data)
    return OperationResponse(**updated)


@router.put("/{operation_id}/complete", response_model=OperationResponse)
async def complete_operation(
    operation_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Complete an operation. Updates stock levels and creates ledger entries.
    """
    op = await operation_repo.get_by_id_or_raise(operation_id)

    if op.get("status") != OperationStatus.IN_PROGRESS.value:
        raise ValidationError(
            f"Operation must be IN_PROGRESS to complete. Current: {op.get('status')}"
        )

    product_id = op.get("product_id")
    quantity = op.get("quantity", 0)
    op_type = op.get("type")

    # ── Stock Updates based on operation type ────────────────────────
    if op_type == OperationType.RECEIPT.value and product_id:
        # Receipt: add stock at destination
        dest_x = op.get("destination_x", 0)
        dest_y = op.get("destination_y", 0)
        dest_z = op.get("destination_z", 0)
        dest_floor = op.get("destination_floor", 0)
        await _update_stock(dest_x, dest_y, dest_z, dest_floor, product_id, quantity)
        await _record_ledger(
            dest_x, dest_y, dest_z, dest_floor, product_id, quantity,
            operation_id, OperationType.RECEIPT, current_user["id"]
        )

    elif op_type == OperationType.TRANSFER.value and product_id:
        # Transfer: remove from source, add to destination
        src_x = op.get("source_x", 0)
        src_y = op.get("source_y", 0)
        src_z = op.get("source_z", 0)
        src_floor = op.get("source_floor", 0)
        dest_x = op.get("destination_x", 0)
        dest_y = op.get("destination_y", 0)
        dest_z = op.get("destination_z", 0)
        dest_floor = op.get("destination_floor", 0)

        await _validate_stock(src_x, src_y, src_z, src_floor, product_id, quantity)
        await _update_stock(src_x, src_y, src_z, src_floor, product_id, -quantity)
        await _update_stock(dest_x, dest_y, dest_z, dest_floor, product_id, quantity)
        await _record_ledger(
            src_x, src_y, src_z, src_floor, product_id, -quantity,
            operation_id, OperationType.TRANSFER, current_user["id"]
        )
        await _record_ledger(
            dest_x, dest_y, dest_z, dest_floor, product_id, quantity,
            operation_id, OperationType.TRANSFER, current_user["id"]
        )

    elif op_type == OperationType.PICKING.value and product_id:
        # Picking: remove from source
        src_x = op.get("source_x", 0)
        src_y = op.get("source_y", 0)
        src_z = op.get("source_z", 0)
        src_floor = op.get("source_floor", 0)

        await _validate_stock(src_x, src_y, src_z, src_floor, product_id, quantity)
        await _update_stock(src_x, src_y, src_z, src_floor, product_id, -quantity)
        await _record_ledger(
            src_x, src_y, src_z, src_floor, product_id, -quantity,
            operation_id, OperationType.PICKING, current_user["id"]
        )

    elif op_type == OperationType.DELIVERY.value and product_id:
        # Delivery: remove from source (expedition zone)
        src_x = op.get("source_x", 0)
        src_y = op.get("source_y", 0)
        src_z = op.get("source_z", 0)
        src_floor = op.get("source_floor", 0)

        await _validate_stock(src_x, src_y, src_z, src_floor, product_id, quantity)
        await _update_stock(src_x, src_y, src_z, src_floor, product_id, -quantity)
        await _record_ledger(
            src_x, src_y, src_z, src_floor, product_id, -quantity,
            operation_id, OperationType.DELIVERY, current_user["id"]
        )

    # Release chariot if assigned
    chariot_id = op.get("chariot_id")
    if chariot_id:
        await chariot_repo.update(chariot_id, {"assigned_to_operation": None})

    # Mark operation completed
    update_data = {
        "status": OperationStatus.COMPLETED.value,
        "completed_at": datetime.utcnow().isoformat(),
    }
    updated = await operation_repo.update(operation_id, update_data)
    return OperationResponse(**updated)


@router.put("/{operation_id}/validate", response_model=OperationResponse)
async def validate_operation(
    operation_id: str,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Validate an operation. Supervisor/Admin only."""
    update_data = {
        "validator_id": current_user["id"],
        "validated_at": datetime.utcnow().isoformat(),
    }
    updated = await operation_repo.update(operation_id, update_data)
    return OperationResponse(**updated)


@router.delete("/{operation_id}", status_code=204)
async def delete_operation(
    operation_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete an operation. Supervisor/Admin only."""
    await operation_repo.delete(operation_id)


# ── Helper Functions ─────────────────────────────────────────────

async def _update_stock(
    x: int, y: int, z: int, floor: int, product_id: str, qty_delta: int
) -> None:
    """Update stock at an emplacement location."""
    location = await emplacement_repo.get_by_coordinates(x, y, z, floor)
    if location:
        new_qty = max(location.get("quantity", 0) + qty_delta, 0)
        is_occupied = new_qty > 0
        await emplacement_repo.update(location["id"], {
            "quantity": new_qty,
            "is_occupied": is_occupied,
            "product_id": product_id if is_occupied else None,
        })


async def _validate_stock(
    x: int, y: int, z: int, floor: int, product_id: str, quantity: int
) -> None:
    """Validate sufficient stock at a location."""
    location = await emplacement_repo.get_by_coordinates(x, y, z, floor)
    if not location:
        raise StockError(f"No location found at ({x}, {y}, {z}, floor {floor})")
    available = location.get("quantity", 0)
    if available < quantity:
        raise StockError(
            f"Insufficient stock at ({x},{y},{z},F{floor}): "
            f"available={available}, requested={quantity}"
        )


async def _record_ledger(
    x: int, y: int, z: int, floor: int,
    product_id: str, quantity: int,
    operation_id: str, operation_type: OperationType,
    user_id: str,
) -> None:
    """Record an immutable stock ledger entry."""
    ledger_data = {
        "x": x,
        "y": y,
        "z": z,
        "floor": floor,
        "product_id": product_id,
        "quantity": quantity,
        "recorded_at": datetime.utcnow().isoformat(),
        "operation_id": operation_id,
        "operation_type": operation_type.value,
        "user_id": user_id,
    }
    await ledger_repo.create(ledger_data)

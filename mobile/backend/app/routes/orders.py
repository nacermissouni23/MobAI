"""
Order routes: CRUD + validation workflow for orders.

Workflow:
- Supervisor creates 'command' order (status=pending)
- Supervisor validates → logs to OrderLog → triggers receipt operation
- AI generates 'preparation' orders via forecasting
"""

import random
from datetime import datetime
from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.enums import OrderType, OrderStatus, OperationType, OperationStatus
from app.repositories.order_repository import OrderRepository
from app.repositories.order_log_repository import OrderLogRepository
from app.repositories.operation_repository import OperationRepository
from app.repositories.operation_log_repository import OperationLogRepository
from app.repositories.user_repository import UserRepository
from app.schemas.order import OrderCreate, OrderResponse
from app.schemas.order_log import OrderLogResponse
from app.ai.forecasting import forecasting_engine
from app.utils.dependencies import get_current_user, get_supervisor_user
from app.utils.logger import logger

router = APIRouter()
order_repo = OrderRepository()
order_log_repo = OrderLogRepository()
operation_repo = OperationRepository()
operation_log_repo = OperationLogRepository()
user_repo = UserRepository()


# ── CRUD ─────────────────────────────────────────────────────────


@router.get("/", response_model=List[OrderResponse])
async def list_orders(
    order_type: Optional[OrderType] = Query(default=None, description="Filter by order type"),
    status: Optional[OrderStatus] = Query(default=None, description="Filter by status"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all orders with optional filters."""
    orders = await order_repo.get_filtered(order_type=order_type, status=status)
    return [OrderResponse(**o) for o in orders]


@router.get("/pending", response_model=List[OrderResponse])
async def list_pending_orders(
    _user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Get all pending orders awaiting validation. Supervisor/Admin only."""
    orders = await order_repo.get_pending()
    return [OrderResponse(**o) for o in orders]


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a single order by ID."""
    order = await order_repo.get_by_id_or_raise(order_id)
    return OrderResponse(**order)


@router.get("/{order_id}/logs", response_model=List[OrderLogResponse])
async def get_order_logs(
    order_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all log entries for a specific order."""
    logs = await order_log_repo.get_by_order(order_id)
    return [OrderLogResponse(**log) for log in logs]


@router.post("/", response_model=OrderResponse, status_code=201)
async def create_order(
    data: OrderCreate,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Create a new order (status=pending). Supervisor/Admin only.

    For 'command' orders: supervisor specifies product_id and quantity.
    """
    order_data = data.model_dump()
    order_data["type"] = order_data.get("type", OrderType.COMMAND.value)
    if isinstance(order_data["type"], OrderType):
        order_data["type"] = order_data["type"].value
    order_data["status"] = OrderStatus.PENDING.value
    order_data["supervisor_id"] = current_user["id"]
    created = await order_repo.create(order_data)

    # Log order creation
    await order_log_repo.create({
        "order_id": created["id"],
        "action": "created",
        "order_type": order_data["type"],
        "supervisor_id": current_user["id"],
        "product_id": order_data.get("product_id"),
        "quantity": order_data.get("quantity", 0),
        "date": datetime.utcnow().isoformat(),
    })

    return OrderResponse(**created)


@router.delete("/{order_id}", status_code=204)
async def delete_order(
    order_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete an order. Supervisor/Admin only."""
    await order_repo.delete(order_id)


# ── VALIDATION WORKFLOW ──────────────────────────────────────────


@router.put("/{order_id}/validate", response_model=OrderResponse)
async def validate_order(
    order_id: str,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Validate a pending order. Supervisor/Admin only.

    For 'command' orders:
    - Sets order status to 'validated'
    - Logs to OrderLog
    - Creates a 'receipt' operation assigned to a random active employee
    - Logs the operation creation to OperationLog
    """
    order = await order_repo.get_by_id_or_raise(order_id)

    if order.get("status") == OrderStatus.VALIDATED.value:
        from app.core.exceptions import ConflictError
        raise ConflictError("Order is already validated")

    now = datetime.utcnow().isoformat()

    # Update order status
    updated_order = await order_repo.update(order_id, {
        "status": OrderStatus.VALIDATED.value,
        "validator_id": current_user["id"],
        "validated_at": now,
    })

    # Log order validation
    await order_log_repo.create({
        "order_id": order_id,
        "action": "validated",
        "order_type": order.get("type"),
        "supervisor_id": current_user["id"],
        "product_id": order.get("product_id"),
        "quantity": order.get("quantity", 0),
        "date": now,
    })

    # Trigger receipt operation for 'command' orders
    order_type = order.get("type")
    if order_type == OrderType.COMMAND.value:
        await _create_receipt_from_order(order, order_id, current_user)

    return OrderResponse(**updated_order)


# ── FORECASTING ──────────────────────────────────────────────────


@router.post("/generate-preparation", response_model=List[OrderResponse])
async def generate_preparation_orders(
    days: Optional[int] = Query(default=None, description="Historical days for forecasting"),
    min_demand_freq: float = Query(default=0.5, description="Minimum demand frequency"),
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Generate preparation orders using the AI forecaster. Supervisor/Admin only.

    The forecaster predicts which products will need delivery soon
    and creates 'preparation' orders for them.
    """
    predictions = await forecasting_engine.predict_preparation_orders(
        days=days,
        min_demand_frequency=min_demand_freq,
    )

    created_orders = []
    for pred in predictions:
        order_data = {
            "type": OrderType.PREPARATION.value,
            "status": OrderStatus.PENDING.value,
            "supervisor_id": current_user["id"],
            "product_id": pred["product_id"],
            "quantity": pred["predicted_quantity"],
        }
        created = await order_repo.create(order_data)

        # Log preparation order creation
        await order_log_repo.create({
            "order_id": created["id"],
            "action": "created",
            "order_type": OrderType.PREPARATION.value,
            "supervisor_id": current_user["id"],
            "product_id": pred["product_id"],
            "quantity": pred["predicted_quantity"],
            "date": datetime.utcnow().isoformat(),
        })

        created_orders.append(OrderResponse(**created))

    return created_orders


# ── HELPER FUNCTIONS ─────────────────────────────────────────────


async def _create_receipt_from_order(
    order: Dict[str, Any],
    order_id: str,
    current_user: Dict[str, Any],
) -> None:
    """
    Create a receipt operation triggered by command order validation.

    - Assigns to a random active employee
    - chariot_id is null (no chariot for receipt)
    - Logs creation to OperationLog
    """
    # Pick a random active employee
    active_employees = await user_repo.get_active_employees()
    employee_id = None
    if active_employees:
        employee = random.choice(active_employees)
        employee_id = employee["id"]
    else:
        logger.warning("No active employees available for receipt operation")

    now = datetime.utcnow().isoformat()

    op_data = {
        "type": OperationType.RECEIPT.value,
        "status": OperationStatus.PENDING.value,
        "product_id": order.get("product_id"),
        "quantity": order.get("quantity", 0),
        "employee_id": employee_id,
        "chariot_id": None,  # no chariot for receipt
        "order_id": order_id,
        "emplacement_id": None,  # employee goes to expedition zone
        "source_emplacement_id": None,
    }
    created_op = await operation_repo.create(op_data)

    # Log operation creation
    await operation_log_repo.create({
        "operation_id": created_op["id"],
        "action": "created",
        "type": OperationType.RECEIPT.value,
        "product_id": order.get("product_id"),
        "quantity": order.get("quantity", 0),
        "employee_id": employee_id,
        "order_id": order_id,
        "date": now,
    })

    logger.info(
        f"Receipt operation {created_op['id']} created for order {order_id}, "
        f"assigned to employee {employee_id}"
    )

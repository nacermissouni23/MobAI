"""
Order routes: CRUD, AI generation, validation, override, and completion.
"""

from datetime import datetime
from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.enums import OrderType, OrderStatus
from app.core.exceptions import ValidationError
from app.repositories.order_repository import OrderRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.schemas.order import OrderCreate, OrderOverride, OrderResponse, OrderLineSchema
from app.ai.forecasting import forecasting_engine
from app.ai.picking_optimizer import picking_optimizer
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
order_repo = OrderRepository()
emplacement_repo = EmplacementRepository()


@router.get("/", response_model=List[OrderResponse])
async def list_orders(
    order_type: Optional[OrderType] = Query(default=None, description="Filter by order type"),
    status_filter: Optional[OrderStatus] = Query(default=None, description="Filter by status"),
    ai_generated_only: bool = Query(default=False, description="Only AI-generated orders"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all orders with optional filters."""
    orders = await order_repo.get_filtered(
        order_type=order_type,
        status_filter=status_filter,
        ai_generated_only=ai_generated_only,
    )
    return [OrderResponse(**o) for o in orders]


@router.get("/pending/all", response_model=List[OrderResponse])
async def get_pending_orders(
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all pending orders."""
    orders = await order_repo.get_pending_orders()
    return [OrderResponse(**o) for o in orders]


@router.get("/overridden/all", response_model=List[OrderResponse])
async def get_overridden_orders(
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Get all overridden orders. Supervisor/Admin only."""
    orders = await order_repo.get_overridden_orders()
    return [OrderResponse(**o) for o in orders]


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a single order by ID."""
    order = await order_repo.get_by_id_or_raise(order_id)
    return OrderResponse(**order)


@router.post("/command", response_model=OrderResponse, status_code=201)
async def create_command_order(
    data: OrderCreate,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Create a manual command order. Supervisor/Admin only."""
    order_data = {
        "type": OrderType.COMMAND.value,
        "status": OrderStatus.PENDING.value,
        "lines": [line.model_dump() for line in data.lines],
        "generated_by_ai": False,
    }
    created = await order_repo.create(order_data)
    return OrderResponse(**created)


@router.post("/preparation/generate", response_model=OrderResponse, status_code=201)
async def generate_preparation_order(
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Generate an AI-powered preparation order based on demand forecasting.
    Supervisor/Admin only.
    """
    predictions = await forecasting_engine.predict_preparation_orders()

    if not predictions:
        raise ValidationError("No products require preparation at this time")

    # Convert predictions to order lines
    lines = []
    for pred in predictions:
        lines.append({
            "product_id": pred["product_id"],
            "sku": pred.get("sku"),
            "product_name": pred.get("product_name"),
            "quantity": pred["predicted_quantity"],
        })

    order_data = {
        "type": OrderType.PREPARATION.value,
        "status": OrderStatus.AI_GENERATED.value,
        "lines": lines,
        "generated_by_ai": True,
    }

    created = await order_repo.create(order_data)
    return OrderResponse(**created)


@router.post("/picking/generate", response_model=dict, status_code=201)
async def generate_picking_order(
    data: OrderCreate,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Generate an AI-optimized picking order with route optimization.
    Supervisor/Admin only.
    """
    # First create the order
    order_lines_data = [line.model_dump() for line in data.lines]

    # Optimize the picking route
    route_result = await picking_optimizer.optimize_order_picking(order_lines_data)

    # Build order with optimized lines (reordered by route)
    optimized_lines = []
    for stop in route_result.get("route", []):
        optimized_lines.append({
            "product_id": stop.get("product_id", ""),
            "sku": stop.get("sku"),
            "product_name": stop.get("product_name"),
            "quantity": stop.get("pick_quantity", 0),
            "source_x": stop.get("x"),
            "source_y": stop.get("y"),
            "source_z": stop.get("z"),
            "source_floor": stop.get("floor"),
        })

    # Fall back to original lines if route optimization returned nothing
    if not optimized_lines:
        optimized_lines = order_lines_data

    order_data = {
        "type": OrderType.PICKING.value,
        "status": OrderStatus.AI_GENERATED.value,
        "lines": optimized_lines,
        "generated_by_ai": True,
    }

    created = await order_repo.create(order_data)

    return {
        "order": OrderResponse(**created).model_dump(),
        "route": route_result,
    }


@router.put("/{order_id}/override", response_model=OrderResponse)
async def override_order(
    order_id: str,
    data: OrderOverride,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Override an AI-generated order. Supervisor/Admin only."""
    order = await order_repo.get_by_id_or_raise(order_id)

    update_data = {
        "status": OrderStatus.OVERRIDDEN.value,
        "overridden_by": current_user["id"],
        "override_reason": data.override_reason,
    }

    if data.lines is not None:
        update_data["lines"] = [line.model_dump() for line in data.lines]

    updated = await order_repo.update(order_id, update_data)
    return OrderResponse(**updated)


@router.put("/{order_id}/validate", response_model=OrderResponse)
async def validate_order(
    order_id: str,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Validate an order. Supervisor/Admin only."""
    update_data = {
        "status": OrderStatus.VALIDATED.value,
    }
    updated = await order_repo.update(order_id, update_data)
    return OrderResponse(**updated)


@router.put("/{order_id}/complete", response_model=OrderResponse)
async def complete_order(
    order_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Mark an order as completed."""
    update_data = {
        "status": OrderStatus.COMPLETED.value,
        "completed_at": datetime.utcnow().isoformat(),
        "completed_by": current_user["id"],
    }
    updated = await order_repo.update(order_id, update_data)
    return OrderResponse(**updated)


@router.delete("/{order_id}", status_code=204)
async def delete_order(
    order_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete an order. Supervisor/Admin only."""
    await order_repo.delete(order_id)

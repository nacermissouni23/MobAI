"""
Inventory routes: stock queries, ledger, adjustments, and summaries.
"""

from datetime import datetime
from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.enums import OperationType
from app.repositories.emplacement_repository import EmplacementRepository
from app.repositories.stock_ledger_repository import StockLedgerRepository
from app.schemas.stock_ledger import StockAdjustment, StockLedgerResponse, StockSummaryResponse
from app.schemas.emplacement import EmplacementResponse
from app.utils.dependencies import get_current_user, get_supervisor_user
from app.config.settings import settings

router = APIRouter()
emplacement_repo = EmplacementRepository()
ledger_repo = StockLedgerRepository()


@router.get("/stock", response_model=List[EmplacementResponse])
async def get_stock(
    product_id: Optional[str] = Query(default=None, description="Filter by product"),
    floor: Optional[int] = Query(default=None, description="Filter by floor"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get current stock levels with optional filters."""
    filters: List[tuple] = [("is_slot", True), ("is_occupied", True)]
    if product_id:
        filters.append(("product_id", product_id))
    if floor is not None:
        filters.append(("floor", floor))

    locations = await emplacement_repo.query(filters=filters)
    return [EmplacementResponse(**loc) for loc in locations]


@router.get("/stock/product/{product_id}", response_model=List[EmplacementResponse])
async def get_product_stock(
    product_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all stock locations for a specific product."""
    locations = await emplacement_repo.get_product_locations(product_id)
    return [EmplacementResponse(**loc) for loc in locations]


@router.get("/ledger", response_model=List[StockLedgerResponse])
async def get_ledger(
    product_id: Optional[str] = Query(default=None, description="Filter by product"),
    operation_id: Optional[str] = Query(default=None, description="Filter by operation"),
    limit: int = Query(default=100, ge=1, le=1000, description="Max entries"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get stock ledger entries with optional filters."""
    entries = await ledger_repo.get_filtered(
        product_id=product_id,
        operation_id=operation_id,
        limit=limit,
    )
    return [StockLedgerResponse(**e) for e in entries]


@router.get("/ledger/location", response_model=List[StockLedgerResponse])
async def get_ledger_by_location(
    x: int = Query(..., ge=0),
    y: int = Query(..., ge=0),
    z: int = Query(default=0, ge=0),
    floor: int = Query(default=0, ge=0),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get stock ledger entries for a specific location."""
    entries = await ledger_repo.get_by_location(x, y, z, floor)
    return [StockLedgerResponse(**e) for e in entries]


@router.post("/adjust", response_model=StockLedgerResponse, status_code=201)
async def adjust_stock(
    data: StockAdjustment,
    current_user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Manually adjust stock at a location. Supervisor/Admin only.
    Creates a ledger entry for audit trail.
    """
    # Update emplacement location
    location = await emplacement_repo.get_by_coordinates(data.x, data.y, data.z, data.floor)
    if location:
        new_qty = max(location.get("quantity", 0) + data.quantity, 0)
        await emplacement_repo.update(location["id"], {
            "quantity": new_qty,
            "is_occupied": new_qty > 0,
            "product_id": data.product_id if new_qty > 0 else None,
        })

    # Create ledger entry
    ledger_data = {
        "x": data.x,
        "y": data.y,
        "z": data.z,
        "floor": data.floor,
        "product_id": data.product_id,
        "quantity": data.quantity,
        "recorded_at": datetime.utcnow().isoformat(),
        "operation_id": None,
        "operation_type": None,
        "user_id": current_user["id"],
    }
    created = await ledger_repo.create(ledger_data)
    return StockLedgerResponse(**created)


@router.get("/low-stock", response_model=List[EmplacementResponse])
async def get_low_stock(
    threshold: int = Query(
        default=None, ge=0, description="Low stock threshold"
    ),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get locations with stock below the threshold."""
    if threshold is None:
        threshold = settings.LOW_STOCK_THRESHOLD

    occupied = await emplacement_repo.get_occupied_slots()
    low_stock = [loc for loc in occupied if loc.get("quantity", 0) <= threshold]
    return [EmplacementResponse(**loc) for loc in low_stock]


@router.get("/stock-summary", response_model=List[StockSummaryResponse])
async def get_stock_summary(
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get aggregated stock summary per product."""
    occupied = await emplacement_repo.get_occupied_slots()

    # Aggregate by product_id
    summary_map: Dict[str, Dict[str, int]] = {}
    for loc in occupied:
        pid = loc.get("product_id")
        if not pid:
            continue
        if pid not in summary_map:
            summary_map[pid] = {"total_quantity": 0, "location_count": 0}
        summary_map[pid]["total_quantity"] += loc.get("quantity", 0)
        summary_map[pid]["location_count"] += 1

    return [
        StockSummaryResponse(
            product_id=pid,
            total_quantity=data["total_quantity"],
            location_count=data["location_count"],
        )
        for pid, data in summary_map.items()
    ]

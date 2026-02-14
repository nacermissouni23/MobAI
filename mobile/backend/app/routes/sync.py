"""
Sync routes: offline data synchronization with conflict resolution.
"""

from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.repositories.operation_repository import OperationRepository
from app.repositories.stock_ledger_repository import StockLedgerRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.utils.dependencies import get_current_user
from app.utils.logger import logger

router = APIRouter()
operation_repo = OperationRepository()
ledger_repo = StockLedgerRepository()
emplacement_repo = EmplacementRepository()


# ── Request Schemas ──────────────────────────────────────────────

class SyncOperationItem(BaseModel):
    """A single operation to sync from the mobile client."""
    local_id: Optional[str] = None
    data: Dict[str, Any]
    client_timestamp: Optional[str] = None


class SyncStockMovementItem(BaseModel):
    """A single stock movement to sync from the mobile client."""
    local_id: Optional[str] = None
    data: Dict[str, Any]
    client_timestamp: Optional[str] = None


class SyncOperationsRequest(BaseModel):
    """Request body for syncing operations."""
    operations: List[SyncOperationItem] = Field(default_factory=list)


class SyncStockMovementsRequest(BaseModel):
    """Request body for syncing stock movements."""
    movements: List[SyncStockMovementItem] = Field(default_factory=list)


class FullSyncRequest(BaseModel):
    """Request body for a full sync."""
    operations: List[SyncOperationItem] = Field(default_factory=list)
    movements: List[SyncStockMovementItem] = Field(default_factory=list)
    last_sync_timestamp: Optional[str] = None


# ── Endpoints ────────────────────────────────────────────────────

@router.post("/operations")
async def sync_operations(
    request: SyncOperationsRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Sync offline operations from mobile client.

    Conflict resolution strategy:
    - If server already has the operation (matched by local_id), skip.
    - Otherwise, create new operation.
    """
    synced = []
    skipped = []
    errors = []

    for item in request.operations:
        try:
            op_data = item.data
            op_data["synced_at"] = datetime.utcnow().isoformat()
            op_data["synced_from"] = current_user["id"]

            # Check for duplicate using local_id if provided
            if item.local_id:
                existing = await operation_repo.find_one("local_id", item.local_id)
                if existing:
                    skipped.append({"local_id": item.local_id, "server_id": existing["id"]})
                    continue

            op_data["local_id"] = item.local_id
            created = await operation_repo.create(op_data)
            synced.append({"local_id": item.local_id, "server_id": created["id"]})
        except Exception as e:
            errors.append({"local_id": item.local_id, "error": str(e)})
            logger.error(f"Sync error for operation {item.local_id}: {e}")

    return {
        "synced": synced,
        "skipped": skipped,
        "errors": errors,
        "timestamp": datetime.utcnow().isoformat(),
    }


@router.post("/stock-movements")
async def sync_stock_movements(
    request: SyncStockMovementsRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Sync offline stock movements (ledger entries) from mobile client.
    """
    synced = []
    skipped = []
    errors = []

    for item in request.movements:
        try:
            mvmt_data = item.data
            mvmt_data["synced_at"] = datetime.utcnow().isoformat()
            mvmt_data["user_id"] = current_user["id"]

            if item.local_id:
                existing = await ledger_repo.find_one("local_id", item.local_id)
                if existing:
                    skipped.append({"local_id": item.local_id, "server_id": existing["id"]})
                    continue

            mvmt_data["local_id"] = item.local_id
            created = await ledger_repo.create(mvmt_data)
            synced.append({"local_id": item.local_id, "server_id": created["id"]})

            # Also update warehouse stock
            x = mvmt_data.get("x", 0)
            y = mvmt_data.get("y", 0)
            z = mvmt_data.get("z", 0)
            floor = mvmt_data.get("floor", 0)
            product_id = mvmt_data.get("product_id")
            quantity = mvmt_data.get("quantity", 0)

            if product_id:
                location = await emplacement_repo.get_by_coordinates(x, y, z, floor)
                if location:
                    new_qty = max(location.get("quantity", 0) + quantity, 0)
                    await emplacement_repo.update(location["id"], {
                        "quantity": new_qty,
                        "is_occupied": new_qty > 0,
                        "product_id": product_id if new_qty > 0 else None,
                    })

        except Exception as e:
            errors.append({"local_id": item.local_id, "error": str(e)})
            logger.error(f"Sync error for movement {item.local_id}: {e}")

    return {
        "synced": synced,
        "skipped": skipped,
        "errors": errors,
        "timestamp": datetime.utcnow().isoformat(),
    }


@router.post("/full-sync")
async def full_sync(
    request: FullSyncRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Perform a full sync of both operations and stock movements.
    Returns server-side data updated since last_sync_timestamp for client to merge.
    """
    # Sync operations
    op_result = await sync_operations(
        SyncOperationsRequest(operations=request.operations),
        current_user,
    )

    # Sync stock movements
    mvmt_result = await sync_stock_movements(
        SyncStockMovementsRequest(movements=request.movements),
        current_user,
    )

    # Get server-side updates since last sync
    server_operations = []
    server_movements = []

    if request.last_sync_timestamp:
        all_ops = await operation_repo.get_all()
        server_operations = [
            op for op in all_ops
            if op.get("updated_at", "") > request.last_sync_timestamp
        ]

        all_movements = await ledger_repo.get_all()
        server_movements = [
            m for m in all_movements
            if m.get("created_at", "") > request.last_sync_timestamp
        ]

    return {
        "operations_sync": op_result,
        "movements_sync": mvmt_result,
        "server_updates": {
            "operations": server_operations,
            "movements": server_movements,
        },
        "sync_timestamp": datetime.utcnow().isoformat(),
    }


@router.get("/status")
async def sync_status(
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Get sync status information."""
    op_count = await operation_repo.count()
    ledger_count = await ledger_repo.count()

    return {
        "status": "online",
        "server_time": datetime.utcnow().isoformat(),
        "total_operations": op_count,
        "total_ledger_entries": ledger_count,
        "user_id": current_user["id"],
    }

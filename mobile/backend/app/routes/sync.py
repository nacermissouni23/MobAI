"""
Sync routes: offline data synchronization with conflict resolution.
Implements Fetch-Before-Write pattern for mobile offline-first architecture.
"""

from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field

from app.repositories.operation_repository import OperationRepository
from app.repositories.stock_ledger_repository import StockLedgerRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.repositories.product_repository import ProductRepository
from app.repositories.order_repository import OrderRepository
from app.repositories.chariot_repository import ChariotRepository
from app.repositories.user_repository import UserRepository
from app.repositories.operation_log_repository import OperationLogRepository
from app.repositories.order_log_repository import OrderLogRepository
from app.repositories.report_repository import ReportRepository
from app.utils.dependencies import get_current_user
from app.utils.logger import logger

router = APIRouter()
operation_repo = OperationRepository()
ledger_repo = StockLedgerRepository()
emplacement_repo = EmplacementRepository()
product_repo = ProductRepository()
order_repo = OrderRepository()
chariot_repo = ChariotRepository()
user_repo = UserRepository()
operation_log_repo = OperationLogRepository()
order_log_repo = OrderLogRepository()
report_repo = ReportRepository()


# ── Request Schemas ──────────────────────────────────────────────

class SyncItem(BaseModel):
    """A single entity to sync from the mobile client."""
    local_id: Optional[str] = None
    server_id: Optional[str] = None
    data: Dict[str, Any]
    client_timestamp: Optional[str] = None
    is_deleted: bool = False


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
    """Request body for a full bidirectional sync."""
    operations: List[SyncItem] = Field(default_factory=list)
    orders: List[SyncItem] = Field(default_factory=list)
    products: List[SyncItem] = Field(default_factory=list)
    emplacements: List[SyncItem] = Field(default_factory=list)
    chariots: List[SyncItem] = Field(default_factory=list)
    operation_logs: List[SyncItem] = Field(default_factory=list)
    order_logs: List[SyncItem] = Field(default_factory=list)
    reports: List[SyncItem] = Field(default_factory=list)
    stock_movements: List[SyncItem] = Field(default_factory=list)
    last_sync_timestamp: Optional[str] = None


# ── Helper: generic entity sync ─────────────────────────────────

async def _sync_entities(items: List[SyncItem], repo, user_id: str, entity_name: str):
    """Generic sync handler for any entity type."""
    synced = []
    skipped = []
    errors = []

    for item in items:
        try:
            entity_data = item.data
            entity_data["synced_at"] = datetime.utcnow().isoformat()
            entity_data["synced_from"] = user_id

            # Handle delete
            if item.is_deleted and item.server_id:
                try:
                    await repo.delete(item.server_id)
                    synced.append({"local_id": item.local_id, "server_id": item.server_id, "action": "deleted"})
                except Exception:
                    skipped.append({"local_id": item.local_id, "reason": "not_found_for_delete"})
                continue

            # Handle update (has server_id)
            if item.server_id:
                existing = await repo.get_by_id(item.server_id)
                if existing:
                    await repo.update(item.server_id, entity_data)
                    synced.append({"local_id": item.local_id, "server_id": item.server_id, "action": "updated"})
                    continue

            # Check for duplicate using local_id
            if item.local_id:
                existing = await repo.find_one("local_id", item.local_id)
                if existing:
                    skipped.append({"local_id": item.local_id, "server_id": existing["id"]})
                    continue

            # Create new
            entity_data["local_id"] = item.local_id
            created = await repo.create(entity_data)
            synced.append({"local_id": item.local_id, "server_id": created["id"], "action": "created"})

        except Exception as e:
            errors.append({"local_id": item.local_id, "error": str(e)})
            logger.error(f"Sync error for {entity_name} {item.local_id}: {e}")

    return {"synced": synced, "skipped": skipped, "errors": errors}


# ── Endpoints ────────────────────────────────────────────────────

@router.get("/updates")
async def get_updates(
    since: Optional[str] = Query(default=None, description="ISO timestamp to fetch updates since"),
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Step 1 of Fetch-Before-Write: Pull remote changes.
    Returns all entities updated since the given timestamp.
    """
    result = {}

    # Collect all entities from each repo
    repos_map = {
        "users": user_repo,
        "products": product_repo,
        "emplacements": emplacement_repo,
        "chariots": chariot_repo,
        "orders": order_repo,
        "operations": operation_repo,
        "operation_logs": operation_log_repo,
        "order_logs": order_log_repo,
        "reports": report_repo,
        "stock_ledger": ledger_repo,
    }

    for entity_name, repo in repos_map.items():
        try:
            all_records = await repo.get_all()
            if since:
                records = [
                    r for r in all_records
                    if r.get("updated_at", "") > since or r.get("created_at", "") > since
                ]
            else:
                records = all_records
            result[entity_name] = records
        except Exception as e:
            logger.error(f"Error fetching {entity_name} updates: {e}")
            result[entity_name] = []

    result["server_timestamp"] = datetime.utcnow().isoformat()
    return result


@router.post("/batch")
async def sync_batch(
    request: FullSyncRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Step 2 of Fetch-Before-Write: Push local pending changes.
    Accepts all entity types in one batch, returns sync results and server IDs.
    """
    user_id = current_user["id"]
    results = {}

    # Map entity types to repos
    sync_map = [
        ("products", request.products, product_repo),
        ("emplacements", request.emplacements, emplacement_repo),
        ("chariots", request.chariots, chariot_repo),
        ("orders", request.orders, order_repo),
        ("operations", request.operations, operation_repo),
        ("operation_logs", request.operation_logs, operation_log_repo),
        ("order_logs", request.order_logs, order_log_repo),
        ("reports", request.reports, report_repo),
        ("stock_movements", request.stock_movements, ledger_repo),
    ]

    for entity_name, items, repo in sync_map:
        if items:
            results[entity_name] = await _sync_entities(items, repo, user_id, entity_name)
        else:
            results[entity_name] = {"synced": [], "skipped": [], "errors": []}

    # Handle stock movement side effects (update emplacements)
    for item in request.stock_movements:
        if not item.is_deleted:
            try:
                mvmt_data = item.data
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
                logger.error(f"Stock movement side-effect error: {e}")

    results["sync_timestamp"] = datetime.utcnow().isoformat()
    return results


@router.post("/operations")
async def sync_operations(
    request: SyncOperationsRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Sync offline operations from mobile client.
    Conflict resolution: if server already has the operation (matched by local_id), skip.
    """
    synced = []
    skipped = []
    errors = []

    for item in request.operations:
        try:
            op_data = item.data
            op_data["synced_at"] = datetime.utcnow().isoformat()
            op_data["synced_from"] = current_user["id"]

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
    """Sync offline stock movements (ledger entries) from mobile client."""
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

            # Update warehouse stock
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
    Perform a full bidirectional sync.
    Returns both push results and server-side updates since last_sync_timestamp.
    """
    # Push local changes via batch
    push_result = await sync_batch(request, current_user)

    # Pull server updates
    pull_result = await get_updates(since=request.last_sync_timestamp, current_user=current_user)

    return {
        "push_results": push_result,
        "pull_data": pull_result,
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

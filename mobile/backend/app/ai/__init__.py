"""
AI package for warehouse optimization.

Exports lazy singletons / factories so routes can import them directly:

    from app.ai import get_storage_optimizer, get_pathfinder, forecasting_engine
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Optional

if TYPE_CHECKING:
    from app.ai.pathfinding import WarehousePathfinder
    from app.ai.storage_optimizer import StorageOptimizer

# Re-export pathfinder factory
from app.ai.pathfinding import get_pathfinder  # noqa: F401

# Forecasting singleton (may fail on import if repos import Firestore before init)
try:
    from app.ai.forecasting import forecasting_engine  # noqa: F401
except Exception:
    forecasting_engine = None  # type: ignore[assignment]

# Picking functions (no singleton needed – they're stateless)
from app.ai.picking_optimizer import (  # noqa: F401
    plan_product_route,
    check_congestion,
    batch_assign_products,
    optimize_expedition_route,
)

_storage_optimizer: Optional["StorageOptimizer"] = None


def get_storage_optimizer(
    slots_from_db: dict | None = None,
) -> "StorageOptimizer":
    """
    Return (or create) a StorageOptimizer singleton.

    The optimizer is lazily instantiated on first call.  If *slots_from_db*
    is supplied it will be forwarded to the constructor; subsequent calls
    ignore it (the singleton is already alive).
    """
    global _storage_optimizer
    if _storage_optimizer is None:
        from pathlib import Path
        from app.ai.storage_optimizer import StorageOptimizer

        grid_file = str(Path(__file__).parent.parent.parent / "gridItem.json")
        _storage_optimizer = StorageOptimizer(
            grid_file=grid_file,
            receiving_point=(10, 30, 1),
            slots_from_db=slots_from_db,
        )
    return _storage_optimizer

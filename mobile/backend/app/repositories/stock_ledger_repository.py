"""
Stock ledger repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository
from app.core.enums import OperationType


class StockLedgerRepository(BaseRepository):
    """Repository for StockLedger documents (immutable audit trail)."""

    def __init__(self):
        super().__init__("stock_ledger")

    async def get_by_product(self, product_id: str, limit: int = 100) -> List[Dict[str, Any]]:
        """Get ledger entries for a product."""
        return await self.query(
            filters=[("product_id", "==", product_id)],
            order_by="recorded_at",
            direction="DESCENDING",
            limit=limit,
        )

    async def get_by_operation(self, operation_id: str) -> List[Dict[str, Any]]:
        """Get ledger entries for an operation."""
        return await self.query(filters=[("operation_id", "==", operation_id)])

    async def get_by_location(
        self, x: int, y: int, z: int = 0, floor: int = 0, limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get ledger entries for a specific location."""
        return await self.query(
            filters=[
                ("x", "==", x),
                ("y", "==", y),
                ("z", "==", z),
                ("floor", "==", floor),
            ],
            limit=limit,
        )

    async def get_filtered(
        self,
        product_id: Optional[str] = None,
        operation_id: Optional[str] = None,
        limit: int = 100,
    ) -> List[Dict[str, Any]]:
        """Get ledger entries with optional filters."""
        filters = []
        if product_id:
            filters.append(("product_id", "==", product_id))
        if operation_id:
            filters.append(("operation_id", "==", operation_id))
        return await self.query(
            filters=filters if filters else None,
            order_by="recorded_at",
            direction="DESCENDING",
            limit=limit,
        )

    async def get_stock_at_location(
        self, x: int, y: int, z: int, floor: int, product_id: str
    ) -> int:
        """Calculate total stock for a product at a location by summing ledger entries."""
        entries = await self.query(filters=[
            ("x", "==", x),
            ("y", "==", y),
            ("z", "==", z),
            ("floor", "==", floor),
            ("product_id", "==", product_id),
        ])
        return sum(e.get("quantity", 0) for e in entries)

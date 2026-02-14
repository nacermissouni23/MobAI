"""
Order repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository
from app.core.enums import OrderType, OrderStatus


class OrderRepository(BaseRepository):
    """Repository for Order documents."""

    def __init__(self):
        super().__init__("orders")

    async def get_by_type(self, order_type: OrderType) -> List[Dict[str, Any]]:
        """Get orders by type."""
        return await self.query(filters=[("type", "==", order_type.value)])

    async def get_by_supervisor(self, supervisor_id: str) -> List[Dict[str, Any]]:
        """Get orders by supervisor."""
        return await self.query(filters=[("supervisor_id", "==", supervisor_id)])

    async def get_by_status(self, status: OrderStatus) -> List[Dict[str, Any]]:
        """Get orders by status."""
        return await self.query(filters=[("status", "==", status.value)])

    async def get_pending(self) -> List[Dict[str, Any]]:
        """Get all pending orders."""
        return await self.get_by_status(OrderStatus.PENDING)

    async def get_filtered(
        self,
        order_type: Optional[OrderType] = None,
        supervisor_id: Optional[str] = None,
        status: Optional[OrderStatus] = None,
    ) -> List[Dict[str, Any]]:
        """Get orders with optional filters."""
        filters = []
        if order_type:
            filters.append(("type", "==", order_type.value))
        if supervisor_id:
            filters.append(("supervisor_id", "==", supervisor_id))
        if status:
            filters.append(("status", "==", status.value))
        return await self.query(filters=filters if filters else None)

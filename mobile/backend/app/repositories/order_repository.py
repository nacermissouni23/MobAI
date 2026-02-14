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

    async def get_pending_orders(self) -> List[Dict[str, Any]]:
        """Get all pending and AI-generated orders (not yet fully validated)."""
        pending = await self.get_by_status(OrderStatus.PENDING)
        ai_generated = await self.get_by_status(OrderStatus.AI_GENERATED)
        return pending + ai_generated

    async def get_overridden_orders(self) -> List[Dict[str, Any]]:
        """Get all overridden orders."""
        return await self.get_by_status(OrderStatus.OVERRIDDEN)

    async def get_filtered(
        self,
        order_type: Optional[OrderType] = None,
        supervisor_id: Optional[str] = None,
        status: Optional[OrderStatus] = None,
        status_filter: Optional[OrderStatus] = None,
        ai_generated_only: bool = False,
    ) -> List[Dict[str, Any]]:
        """Get orders with optional filters."""
        filters = []
        if order_type:
            filters.append(("type", "==", order_type.value))
        if supervisor_id:
            filters.append(("supervisor_id", "==", supervisor_id))
        if status:
            filters.append(("status", "==", status.value))
        if status_filter:
            filters.append(("status", "==", status_filter.value))
        if ai_generated_only:
            filters.append(("generated_by_ai", "==", True))
        return await self.query(filters=filters if filters else None)

"""
Order log repository for Firestore operations.
"""

from typing import List, Dict, Any

from app.repositories.base_repository import BaseRepository


class OrderLogRepository(BaseRepository):
    """Repository for OrderLog documents."""

    def __init__(self):
        super().__init__("order_logs")

    async def get_by_order(self, order_id: str) -> List[Dict[str, Any]]:
        """Get all logs for a specific order."""
        return await self.query(filters=[("order_id", "==", order_id)])

    async def get_by_supervisor(self, supervisor_id: str) -> List[Dict[str, Any]]:
        """Get all logs by a specific supervisor."""
        return await self.query(filters=[("supervisor_id", "==", supervisor_id)])

    async def get_by_action(self, action: str) -> List[Dict[str, Any]]:
        """Get all logs with a specific action."""
        return await self.query(filters=[("action", "==", action)])

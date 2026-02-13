"""
Operation repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository
from app.core.enums import OperationType, OperationStatus


class OperationRepository(BaseRepository):
    """Repository for Operation documents."""

    def __init__(self):
        super().__init__("operations")

    async def get_by_employee(self, employee_id: str) -> List[Dict[str, Any]]:
        """Get all operations assigned to an employee."""
        return await self.query(filters=[("employee_id", "==", employee_id)])

    async def get_pending(self) -> List[Dict[str, Any]]:
        """Get all pending operations."""
        return await self.query(filters=[("status", "==", OperationStatus.PENDING.value)])

    async def get_by_order(self, order_id: str) -> List[Dict[str, Any]]:
        """Get all operations for a specific order."""
        return await self.query(filters=[("order_id", "==", order_id)])

    async def get_filtered(
        self,
        operation_type: Optional[OperationType] = None,
        status_filter: Optional[OperationStatus] = None,
        employee_id: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """Get operations with optional filters."""
        filters = []
        if operation_type:
            filters.append(("type", "==", operation_type.value))
        if status_filter:
            filters.append(("status", "==", status_filter.value))
        if employee_id:
            filters.append(("employee_id", "==", employee_id))
        return await self.query(filters=filters if filters else None)

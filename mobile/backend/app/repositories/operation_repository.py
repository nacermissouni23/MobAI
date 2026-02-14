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

    async def get_by_order(self, order_id: str) -> List[Dict[str, Any]]:
        """Get all operations for a specific order."""
        return await self.query(filters=[("order_id", "==", order_id)])

    async def get_by_status(self, status: OperationStatus) -> List[Dict[str, Any]]:
        """Get operations by status."""
        return await self.query(filters=[("status", "==", status.value)])

    async def get_pending_for_employee(self, employee_id: str) -> List[Dict[str, Any]]:
        """Get pending operations for a specific employee."""
        return await self.query(filters=[
            ("employee_id", "==", employee_id),
            ("status", "==", OperationStatus.PENDING.value),
        ])

    async def get_validated(self) -> List[Dict[str, Any]]:
        """Get all validated operations (validated_at is not null)."""
        all_ops = await self.get_all()
        return [op for op in all_ops if op.get("validated_at")]

    async def get_filtered(
        self,
        operation_type: Optional[OperationType] = None,
        employee_id: Optional[str] = None,
        status: Optional[OperationStatus] = None,
    ) -> List[Dict[str, Any]]:
        """Get operations with optional filters."""
        filters = []
        if operation_type:
            filters.append(("type", "==", operation_type.value))
        if employee_id:
            filters.append(("employee_id", "==", employee_id))
        if status:
            filters.append(("status", "==", status.value))
        return await self.query(filters=filters if filters else None)

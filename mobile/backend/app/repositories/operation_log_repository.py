"""
Operation log repository for Firestore operations.
"""

from typing import List, Dict, Any

from app.repositories.base_repository import BaseRepository


class OperationLogRepository(BaseRepository):
    """Repository for OperationLog documents."""

    def __init__(self):
        super().__init__("operation_logs")

    async def get_by_operation(self, operation_id: str) -> List[Dict[str, Any]]:
        """Get all logs for a specific operation."""
        return await self.query(filters=[("operation_id", "==", operation_id)])

    async def get_overrides(self) -> List[Dict[str, Any]]:
        """Get all log entries that represent overrides (have overrider_id)."""
        # Firestore doesn't support != null natively, get all and filter
        all_logs = await self.get_all()
        return [log for log in all_logs if log.get("overrider_id")]

    async def get_by_employee(self, employee_id: str) -> List[Dict[str, Any]]:
        """Get all logs for a specific employee."""
        return await self.query(filters=[("employee_id", "==", employee_id)])

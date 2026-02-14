"""
Operation log repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository
from app.core.enums import OperationType


class OperationLogRepository(BaseRepository):
    """Repository for OperationLog documents."""

    def __init__(self):
        super().__init__("operation_logs")

    async def get_by_operation(self, operation_id: str) -> List[Dict[str, Any]]:
        """Get all logs for a specific operation."""
        return await self.query(filters=[("operation_id", "==", operation_id)])

    async def get_by_employee(self, employee_id: str) -> List[Dict[str, Any]]:
        """Get all logs for a specific employee."""
        return await self.query(filters=[("employee_id", "==", employee_id)])

    async def get_overrides(self) -> List[Dict[str, Any]]:
        """Get all log entries that represent overrides (have overridor_id)."""
        all_logs = await self.get_all()
        return [log for log in all_logs if log.get("overridor_id")]

    async def get_validated(self) -> List[Dict[str, Any]]:
        """Get all validated log entries."""
        all_logs = await self.get_all()
        return [log for log in all_logs if log.get("validated_at")]

    async def get_by_type(self, op_type: OperationType) -> List[Dict[str, Any]]:
        """Get all logs for a specific operation type."""
        return await self.query(filters=[("type", "==", op_type.value)])

    async def get_delivery_logs(self) -> List[Dict[str, Any]]:
        """Get validated delivery logs for forecasting."""
        delivery_logs = await self.query(filters=[("type", "==", OperationType.DELIVERY.value)])
        return [log for log in delivery_logs if log.get("validated_at")]

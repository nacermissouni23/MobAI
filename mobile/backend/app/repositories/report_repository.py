"""
Report repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository


class ReportRepository(BaseRepository):
    """Repository for Report documents."""

    def __init__(self):
        super().__init__("reports")

    async def get_by_operation(self, operation_id: str) -> List[Dict[str, Any]]:
        """Get all reports for a specific operation."""
        return await self.query(filters=[("operation_id", "==", operation_id)])

    async def get_damage_reports(self) -> List[Dict[str, Any]]:
        """Get all reports with physical damage."""
        return await self.query(filters=[("physical_damage", "==", True)])

    async def get_filtered(
        self,
        operation_id: Optional[str] = None,
        damage_only: bool = False,
    ) -> List[Dict[str, Any]]:
        """Get reports with optional filters."""
        filters = []
        if operation_id:
            filters.append(("operation_id", "==", operation_id))
        if damage_only:
            filters.append(("physical_damage", "==", True))
        return await self.query(filters=filters if filters else None)

    async def get_by_reporter(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all reports filed by a specific user."""
        return await self.query(filters=[("reported_by", "==", user_id)])

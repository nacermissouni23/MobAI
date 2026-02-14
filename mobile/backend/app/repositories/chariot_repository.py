"""
Chariot repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository


class ChariotRepository(BaseRepository):
    """Repository for Chariot documents."""

    def __init__(self):
        super().__init__("chariots")

    async def get_by_code(self, code: str) -> Optional[Dict[str, Any]]:
        """Find a chariot by its code."""
        return await self.find_one("code", code)

    async def get_active_chariots(self) -> List[Dict[str, Any]]:
        """Get all active chariots."""
        return await self.query(filters=[("is_active", "==", True)])

    async def get_available_chariots(self) -> List[Dict[str, Any]]:
        """Get chariots that are active and not assigned to any operation."""
        # Firestore doesn't support != or null checks easily,
        # so we get active ones and filter in memory
        active = await self.get_active_chariots()
        return [c for c in active if not c.get("assigned_to_operation")]

    async def get_filtered(
        self, is_active: Optional[bool] = None, available_only: bool = False
    ) -> List[Dict[str, Any]]:
        """Get chariots with optional filters."""
        if available_only:
            return await self.get_available_chariots()
        filters = []
        if is_active is not None:
            filters.append(("is_active", "==", is_active))
        return await self.query(filters=filters if filters else None)

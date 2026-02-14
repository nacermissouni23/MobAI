"""
Emplacement repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository


class EmplacementRepository(BaseRepository):
    """Repository for Emplacement location documents."""

    def __init__(self):
        super().__init__("emplacements")

    async def get_by_coordinates(
        self, x: int, y: int, z: int = 0, floor: int = 0
    ) -> Optional[Dict[str, Any]]:
        """Find a location by exact coordinates."""
        results = await self.query(filters=[
            ("x", "==", x),
            ("y", "==", y),
            ("z", "==", z),
            ("floor", "==", floor),
        ])
        return results[0] if results else None

    async def get_slots_by_floor(self, floor: int) -> List[Dict[str, Any]]:
        """Get all storage slots on a specific floor."""
        return await self.query(filters=[
            ("floor", "==", floor),
            ("is_slot", "==", True),
        ])

    async def get_available_slots(self, floor: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get available (unoccupied) storage slots."""
        filters = [("is_slot", "==", True), ("is_occupied", "==", False)]
        if floor is not None:
            filters.append(("floor", "==", floor))
        return await self.query(filters=filters)

    async def get_occupied_slots(self, floor: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get occupied storage slots."""
        filters = [("is_slot", "==", True), ("is_occupied", "==", True)]
        if floor is not None:
            filters.append(("floor", "==", floor))
        return await self.query(filters=filters)

    async def get_expedition_zones(self) -> List[Dict[str, Any]]:
        """Get all expedition zones."""
        return await self.query(filters=[("is_expedition", "==", True)])

    async def get_product_locations(self, product_id: str) -> List[Dict[str, Any]]:
        """Get all locations storing a specific product."""
        return await self.query(filters=[("product_id", "==", product_id)])

    async def get_filtered(
        self,
        floor: Optional[int] = None,
        is_slot: Optional[bool] = None,
        is_occupied: Optional[bool] = None,
    ) -> List[Dict[str, Any]]:
        """Get locations with optional filters."""
        filters = []
        if floor is not None:
            filters.append(("floor", "==", floor))
        if is_slot is not None:
            filters.append(("is_slot", "==", is_slot))
        if is_occupied is not None:
            filters.append(("is_occupied", "==", is_occupied))
        return await self.query(filters=filters if filters else None)

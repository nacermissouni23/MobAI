"""
Product repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository


class ProductRepository(BaseRepository):
    """Repository for Product documents."""

    def __init__(self):
        super().__init__("products")

    async def get_by_sku(self, sku: str) -> Optional[Dict[str, Any]]:
        """Find a product by SKU."""
        return await self.find_one("sku", sku)

    async def get_by_category(self, category: str) -> List[Dict[str, Any]]:
        """Get all products in a category."""
        return await self.query(filters=[("categorie", "==", category)])

    async def get_active_products(self) -> List[Dict[str, Any]]:
        """Get all active products."""
        return await self.query(filters=[("actif", "==", True)])

    async def get_filtered(
        self, category: Optional[str] = None, active_only: bool = False
    ) -> List[Dict[str, Any]]:
        """Get products with optional filters."""
        filters = []
        if category:
            filters.append(("categorie", "==", category))
        if active_only:
            filters.append(("actif", "==", True))
        return await self.query(filters=filters if filters else None)

    async def get_high_demand(self, threshold: float = 1.0) -> List[Dict[str, Any]]:
        """Get products with demand_freq above threshold."""
        return await self.query(filters=[("demand_freq", ">=", threshold)])

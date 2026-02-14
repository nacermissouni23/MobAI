"""
AI-powered storage optimization for warehouse slot assignment.

Scores available slots based on product weight, demand frequency,
and distance from receipt/expedition zones.
"""

from typing import Any, Dict, List, Optional, Tuple

from app.ai.utils import normalize, weighted_score, euclidean_distance_3d
from app.repositories.product_repository import ProductRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.utils.logger import logger


# Default scoring weights
DEFAULT_WEIGHTS = {
    "demand_proximity": 0.40,   # High-demand products near expedition
    "weight_level": 0.30,       # Heavy products at lower shelf levels
    "distance_receipt": 0.20,   # Proximity to receipt zone
    "stackability": 0.10,       # Stackable products on upper levels
}


class StorageOptimizer:
    """
    Scores and ranks available storage slots for product placement.
    """

    def __init__(self):
        self.product_repo = ProductRepository()
        self.emplacement_repo = EmplacementRepository()

    async def suggest_slot(
        self,
        product_id: str,
        weights: Optional[Dict[str, float]] = None,
        top_n: int = 5,
    ) -> List[Dict[str, Any]]:
        """
        Suggest the best storage slots for a product.

        Algorithm:
        1. Load product properties (weight, demand_frequency, is_gerbable)
        2. Get available (unoccupied) slots
        3. Get expedition and receipt zones for distance calculations
        4. Score each slot based on weighted factors
        5. Return top N slots ranked by score

        Args:
            product_id: Product to be stored.
            weights: Custom weights for scoring factors.
            top_n: Number of top slots to return.

        Returns:
            List of scored slot dicts (slot data + score).
        """
        if weights is None:
            weights = DEFAULT_WEIGHTS

        # Load product
        product = await self.product_repo.get_by_id(product_id)
        if not product:
            logger.warning(f"Product {product_id} not found for storage optimization")
            return []

        # Load available slots
        available_slots = await self.emplacement_repo.get_available_slots()
        if not available_slots:
            logger.info("No available slots for storage optimization")
            return []

        # Load reference zones
        expedition_zones = await self.emplacement_repo.get_expedition_zones()
        expedition_center = self._calculate_center(expedition_zones)

        # Get all products for normalization
        all_products = await self.product_repo.get_all()
        max_weight = max((p.get("poids", 0) or 0 for p in all_products), default=1)
        max_demand = max((p.get("demand_frequency", 0) for p in all_products), default=1)

        # Extract product features
        product_weight = product.get("poids", 0) or 0
        product_demand = product.get("demand_frequency", 0)
        product_stackable = product.get("is_gerbable", False)

        # Score each slot
        scored_slots = []
        for slot in available_slots:
            slot_pos = (
                slot.get("x", 0),
                slot.get("y", 0),
                slot.get("z", 0),
                slot.get("floor", 0),
            )

            # Factor 1: Demand proximity (high demand → close to expedition)
            if expedition_center:
                dist_to_expedition = euclidean_distance_3d(slot_pos, expedition_center)
                # Invert: smaller distance = higher score
                demand_score = 1.0 - min(dist_to_expedition / 100.0, 1.0)
                demand_score *= (product_demand / max(max_demand, 1))
            else:
                demand_score = 0.5

            # Factor 2: Weight → lower level score
            shelf_level = slot.get("z", 0)
            if max_weight > 0 and product_weight > 0:
                # Heavy items should go to low z; weight_ratio high → prefer low z
                weight_ratio = product_weight / max_weight
                level_penalty = shelf_level / max(10, 1)  # Normalize shelf level
                weight_score = weight_ratio * (1.0 - level_penalty)
            else:
                weight_score = 0.5

            # Factor 3: Distance from receipt zone (prefer closer for frequent receipts)
            receipt_score = 1.0 - min(slot_pos[1] / 100.0, 1.0)  # Simple Y-based heuristic

            # Factor 4: Stackability
            if product_stackable:
                stack_score = min(shelf_level / 5.0, 1.0)  # Stackable → ok on upper levels
            else:
                stack_score = 1.0 - min(shelf_level / 5.0, 1.0)  # Non-stackable → prefer low

            # Calculate weighted total
            factors = {
                "demand_proximity": demand_score,
                "weight_level": weight_score,
                "distance_receipt": receipt_score,
                "stackability": stack_score,
            }
            total_score = weighted_score(factors, weights)

            scored_slots.append({
                **slot,
                "score": round(total_score, 4),
                "factors": {k: round(v, 4) for k, v in factors.items()},
            })

        # Sort by score descending
        scored_slots.sort(key=lambda s: s["score"], reverse=True)
        best = scored_slots[:top_n]
        logger.info(
            f"Storage optimizer: scored {len(scored_slots)} slots for product {product_id}, "
            f"top score={best[0]['score'] if best else 'N/A'}"
        )
        return best

    def _calculate_center(
        self, locations: List[Dict[str, Any]]
    ) -> Optional[Tuple[float, float, float, float]]:
        """Calculate the centroid of a list of locations."""
        if not locations:
            return None
        n = len(locations)
        cx = sum(loc.get("x", 0) for loc in locations) / n
        cy = sum(loc.get("y", 0) for loc in locations) / n
        cz = sum(loc.get("z", 0) for loc in locations) / n
        cf = sum(loc.get("floor", 0) for loc in locations) / n
        return (cx, cy, cz, cf)


# Module-level singleton
storage_optimizer = StorageOptimizer()

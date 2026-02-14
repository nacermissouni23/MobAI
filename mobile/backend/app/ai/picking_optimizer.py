"""
AI-powered picking route optimization using Nearest Neighbor TSP heuristic.

Generates an optimal picking route to minimize travel distance.
"""

from typing import Any, Dict, List, Optional, Tuple

from app.ai.utils import euclidean_distance_3d, manhattan_distance_3d
from app.repositories.emplacement_repository import EmplacementRepository
from app.utils.logger import logger


class PickingOptimizer:
    """
    Generates optimal picking routes using the nearest-neighbor
    TSP (Travelling Salesman Problem) heuristic.
    """

    def __init__(self):
        self.emplacement_repo = EmplacementRepository()

    async def optimize_route(
        self,
        pick_locations: List[Dict[str, Any]],
        start_position: Optional[Tuple[int, int, int, int]] = None,
        use_manhattan: bool = False,
    ) -> Dict[str, Any]:
        """
        Generate an optimized picking route visiting all pick locations.

        Algorithm: Nearest Neighbor TSP Heuristic
        1. Start from the given position (or first expedition zone)
        2. At each step, move to the nearest unvisited location
        3. Continue until all locations are visited
        4. Return the ordered route with total distance

        Args:
            pick_locations: List of locations to visit. Each must have x, y, z, floor.
            start_position: Starting coordinates (x, y, z, floor). If None, uses first expedition zone.
            use_manhattan: Use Manhattan distance instead of Euclidean.

        Returns:
            Dict with 'route' (ordered locations), 'total_distance', 'step_distances'.
        """
        if not pick_locations:
            return {"route": [], "total_distance": 0, "step_distances": []}

        # Determine starting position
        if start_position is None:
            expedition_zones = await self.emplacement_repo.get_expedition_zones()
            if expedition_zones:
                ez = expedition_zones[0]
                start_position = (
                    ez.get("x", 0),
                    ez.get("y", 0),
                    ez.get("z", 0),
                    ez.get("floor", 0),
                )
            else:
                start_position = (0, 0, 0, 0)

        distance_fn = manhattan_distance_3d if use_manhattan else euclidean_distance_3d

        # Build coordinate list
        points = []
        for loc in pick_locations:
            points.append({
                "data": loc,
                "coords": (
                    loc.get("x", loc.get("source_x", 0)),
                    loc.get("y", loc.get("source_y", 0)),
                    loc.get("z", loc.get("source_z", 0)),
                    loc.get("floor", loc.get("source_floor", 0)),
                ),
            })

        # Nearest neighbor algorithm
        route = []
        step_distances = []
        total_distance = 0.0
        current = start_position
        unvisited = list(range(len(points)))

        while unvisited:
            # Find nearest unvisited point
            best_idx = None
            best_dist = float("inf")

            for idx in unvisited:
                d = distance_fn(current, points[idx]["coords"])
                if d < best_dist:
                    best_dist = d
                    best_idx = idx

            # Visit the nearest
            unvisited.remove(best_idx)
            route.append(points[best_idx]["data"])
            step_distances.append(round(best_dist, 2))
            total_distance += best_dist
            current = points[best_idx]["coords"]

        logger.info(
            f"Picking route optimized: {len(route)} stops, "
            f"total distance={round(total_distance, 2)}"
        )

        return {
            "route": route,
            "total_distance": round(total_distance, 2),
            "step_distances": step_distances,
            "num_stops": len(route),
        }

    async def optimize_order_picking(
        self,
        order_lines: List[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """
        Optimize picking route for a list of order lines.

        For each order line, finds the warehouse location holding the product,
        then optimizes the visiting order.

        Args:
            order_lines: List of order line dicts with product_id, quantity, etc.

        Returns:
            Optimized route information.
        """
        pick_locations = []

        for line in order_lines:
            product_id = line.get("product_id")
            if not product_id:
                continue

            # Find locations for this product
            locations = await self.emplacement_repo.get_product_locations(product_id)
            if locations:
                # Pick the location with the most stock
                best_loc = max(locations, key=lambda l: l.get("quantity", 0))
                pick_locations.append({
                    **best_loc,
                    "product_id": product_id,
                    "pick_quantity": line.get("quantity", 0),
                    "sku": line.get("sku"),
                    "product_name": line.get("product_name"),
                })

        return await self.optimize_route(pick_locations)


# Module-level singleton
picking_optimizer = PickingOptimizer()

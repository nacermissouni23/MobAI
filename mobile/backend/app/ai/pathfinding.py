"""
Pathfinding module — bridge between operations routes and the AI pathfinding engine.

Provides a singleton Pathfinder that wraps the StorageOptimizer's A* capabilities
and the picking_optimizer's astar function for route generation.
"""

import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from app.ai.picking_optimizer import astar, path_cost


class Pathfinder:
    """
    High-level pathfinder that loads the warehouse grid once
    and exposes a simple find_path(start, goal) interface.
    """

    def __init__(self):
        backend_root = Path(__file__).parent.parent.parent

        grid_storage_path = backend_root / "gridItem.json"
        grid_ground_path = backend_root / "grid0.json"

        self.grid: Dict[Tuple[int, int, int], dict] = {}
        self.elevators: List[dict] = []

        # Load storage floors (1-4)
        if grid_storage_path.exists():
            with open(grid_storage_path, encoding="utf-8") as f:
                storage_data = json.load(f)
            for cell in storage_data.get("cells", []):
                key = (cell["x"], cell["y"], cell["floor"])
                self.grid[key] = cell

        # Load ground floor (0)
        if grid_ground_path.exists():
            with open(grid_ground_path, encoding="utf-8") as f:
                ground_data = json.load(f)
            for cell in ground_data.get("cells", []):
                key = (cell["x"], cell["y"], cell["floor"])
                self.grid[key] = cell

        # Identify elevators for inter-floor transitions
        self.elevators = [
            cell for cell in self.grid.values() if cell.get("is_elevator", False)
        ]

    def find_path(
        self,
        start: Tuple[int, int, int],
        goal: Tuple[int, int, int],
    ) -> Optional[Dict]:
        """
        Find a path between two (x, y, floor) coordinates.

        If start and goal are on the same floor, runs A* directly.
        If on different floors, routes through the nearest elevator.

        Returns:
            dict with "path" (list of (x,y,floor) tuples) and "cost" (float),
            or None if no path is found.
        """
        start_cell = self.grid.get(start)
        goal_cell = self.grid.get(goal)

        if not start_cell or not goal_cell:
            return None

        if start[2] == goal[2]:
            # Same floor — direct A*
            path = astar(start_cell, goal_cell, self.grid)
            if not path:
                return None
            return {"path": path, "cost": path_cost(path)}

        # Different floors — route via elevators
        # 1. Find elevator on start floor
        start_elevators = [e for e in self.elevators if e["floor"] == start[2]]
        goal_elevators = [e for e in self.elevators if e["floor"] == goal[2]]

        if not start_elevators or not goal_elevators:
            return None

        best_result = None
        best_cost = float("inf")

        for se in start_elevators:
            for ge in goal_elevators:
                # Only consider elevators at the same (x,y) position
                if se["x"] != ge["x"] or se["y"] != ge["y"]:
                    continue

                # Path from start to elevator on start floor
                path1 = astar(start_cell, se, self.grid)
                if not path1:
                    continue

                # Path from elevator on goal floor to goal
                path2 = astar(ge, goal_cell, self.grid)
                if not path2:
                    continue

                total_cost = path_cost(path1) + 1.0 + path_cost(path2)  # +1 for elevator
                if total_cost < best_cost:
                    best_cost = total_cost
                    # Combine paths (skip duplicate elevator point)
                    combined = path1 + path2[1:] if len(path2) > 1 else path1
                    best_result = {"path": combined, "cost": best_cost}

        return best_result


# ── Singleton ────────────────────────────────────────────────────

_pathfinder_instance: Optional[Pathfinder] = None


def get_pathfinder() -> Pathfinder:
    """Get or create the global Pathfinder instance."""
    global _pathfinder_instance
    if _pathfinder_instance is None:
        _pathfinder_instance = Pathfinder()
    return _pathfinder_instance

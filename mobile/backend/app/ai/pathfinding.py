"""
Warehouse grid pathfinding using A* algorithm.

Adapted from the notebook StorageOptimizer for backend integration.
Loads warehouse grid from JSON and provides pathfinding between grid cells.
"""

import json
import heapq
import math
import os
from typing import Dict, List, Optional, Tuple

from app.utils.logger import logger

# 8-directional movement
DIRECTIONS = [
    (1, 0), (-1, 0), (0, 1), (0, -1),
    (1, 1), (1, -1), (-1, 1), (-1, -1),
]


class WarehousePathfinder:
    """
    Grid-based A* pathfinder for warehouse navigation.
    Supports multi-floor navigation via elevators.
    """

    def __init__(self):
        self.grid: Dict[Tuple[int, int, int], dict] = {}  # (x, y, floor) -> cell
        self.roads: Dict[int, set] = {}                    # floor -> set of (x, y)
        self.elevators: Dict[int, set] = {}                # floor -> set of (x, y)
        self.width = 0
        self.height = 0
        self._loaded = False

    def load_grids(self, grid_files: List[str]) -> None:
        """Load one or more grid JSON files."""
        for path in grid_files:
            if not os.path.exists(path):
                logger.warning(f"Grid file not found: {path}")
                continue
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            self.width = max(self.width, data.get("width", 0))
            self.height = max(self.height, data.get("height", 0))
            for cell in data.get("cells", []):
                floor = cell.get("floor", 0)
                x, y = cell["x"], cell["y"]
                key = (x, y, floor)
                self.grid[key] = cell

                if floor not in self.roads:
                    self.roads[floor] = set()
                if floor not in self.elevators:
                    self.elevators[floor] = set()

                if cell.get("is_road"):
                    self.roads[floor].add((x, y))
                if cell.get("is_elevator"):
                    self.elevators[floor].add((x, y))

        floors = sorted(set(k[2] for k in self.grid))
        logger.info(f"Pathfinder loaded {len(self.grid)} cells across floors {floors}")
        self._loaded = True

    def _get_walkable_neighbors(self, pos: Tuple[int, int, int]) -> List[Tuple[int, int, int]]:
        """Get walkable neighbor cells (roads, elevators). Slots are NOT walkable mid-path."""
        x, y, floor = pos
        neighbors = []
        for dx, dy in DIRECTIONS:
            nx, ny = x + dx, y + dy
            if 0 <= nx < self.width and 0 <= ny < self.height:
                key = (nx, ny, floor)
                cell = self.grid.get(key)
                if cell and (cell.get("is_road") or cell.get("is_elevator")):
                    neighbors.append(key)
        # Elevator connections to other floors
        if (x, y) in self.elevators.get(floor, set()):
            for other_floor in self.elevators:
                if other_floor != floor and (x, y) in self.elevators[other_floor]:
                    neighbors.append((x, y, other_floor))
        return neighbors

    def _heuristic(self, a: Tuple[int, int, int], b: Tuple[int, int, int]) -> float:
        dx = abs(a[0] - b[0])
        dy = abs(a[1] - b[1])
        return max(dx, dy) + (math.sqrt(2) - 1) * min(dx, dy) + 10 * abs(a[2] - b[2])

    def _nearest_road(self, x: int, y: int, floor: int) -> Optional[Tuple[int, int, int]]:
        """Find the nearest road cell adjacent to a slot."""
        for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
            nx, ny = x + dx, y + dy
            if (nx, ny) in self.roads.get(floor, set()):
                return (nx, ny, floor)
        return None

    def find_path(
        self,
        start: Tuple[int, int, int],
        goal: Tuple[int, int, int],
    ) -> Optional[Dict]:
        """
        Find shortest path between two grid positions using A*.

        Args:
            start: (x, y, floor) starting position
            goal: (x, y, floor) destination position

        Returns:
            Dict with 'path' (list of (x,y,floor) tuples), 'cost', or None if no path.
        """
        if not self._loaded:
            return None

        # If start/goal are slots, snap to nearest road
        start_cell = self.grid.get(start)
        goal_cell = self.grid.get(goal)

        actual_start = start
        actual_goal = goal
        extra_start_cost = 0.0
        extra_goal_cost = 0.0

        if start_cell and start_cell.get("is_slot") and not start_cell.get("is_road"):
            road = self._nearest_road(*start)
            if road:
                actual_start = road
                extra_start_cost = 1.0

        if goal_cell and goal_cell.get("is_slot") and not goal_cell.get("is_road"):
            road = self._nearest_road(*goal)
            if road:
                actual_goal = road
                extra_goal_cost = 1.0

        if actual_start == actual_goal:
            path_coords = [start]
            if start != goal:
                path_coords.append(goal)
            return {
                "path": [{"x": p[0], "y": p[1], "floor": p[2]} for p in path_coords],
                "cost": extra_start_cost + extra_goal_cost,
            }

        # A* search
        open_set = []
        counter = 0
        heapq.heappush(open_set, (0, counter, actual_start))
        g_score = {actual_start: 0.0}
        came_from = {}

        while open_set:
            _, _, current = heapq.heappop(open_set)
            if current == actual_goal:
                # Reconstruct path
                path = []
                node = current
                while node in came_from:
                    path.append(node)
                    node = came_from[node]
                path.append(actual_start)
                path.reverse()

                # Add slot endpoints if needed
                full_path = []
                if actual_start != start:
                    full_path.append(start)
                full_path.extend(path)
                if actual_goal != goal:
                    full_path.append(goal)

                total_cost = g_score[actual_goal] + extra_start_cost + extra_goal_cost
                return {
                    "path": [{"x": p[0], "y": p[1], "floor": p[2]} for p in full_path],
                    "cost": round(total_cost, 2),
                }

            for neighbor in self._get_walkable_neighbors(current):
                dx = neighbor[0] - current[0]
                dy = neighbor[1] - current[1]
                dz = neighbor[2] - current[2]
                if dz != 0:
                    move_cost = 1.0  # elevator cost
                else:
                    move_cost = 1.0 if dx == 0 or dy == 0 else math.sqrt(2)
                tentative_g = g_score[current] + move_cost
                if neighbor not in g_score or tentative_g < g_score[neighbor]:
                    g_score[neighbor] = tentative_g
                    f = tentative_g + self._heuristic(neighbor, actual_goal)
                    counter += 1
                    heapq.heappush(open_set, (f, counter, neighbor))
                    came_from[neighbor] = current

        logger.warning(f"No path found from {start} to {goal}")
        return None

    def get_route_coordinates(
        self,
        waypoints: List[Tuple[int, int, int]],
    ) -> Optional[Dict]:
        """
        Calculate a complete route through a list of waypoints.

        Args:
            waypoints: List of (x, y, floor) positions to visit in order.

        Returns:
            Dict with 'full_path', 'total_cost', 'segments'.
        """
        if len(waypoints) < 2:
            return None

        full_path = []
        total_cost = 0.0
        segments = []

        for i in range(len(waypoints) - 1):
            result = self.find_path(waypoints[i], waypoints[i + 1])
            if result is None:
                return None
            segments.append(result)
            total_cost += result["cost"]
            if i == 0:
                full_path.extend(result["path"])
            else:
                full_path.extend(result["path"][1:])  # skip duplicate waypoint

        return {
            "full_path": full_path,
            "total_cost": round(total_cost, 2),
            "segments": segments,
            "num_waypoints": len(waypoints),
        }


def _get_grid_paths() -> List[str]:
    """Get paths to grid files relative to backend directory."""
    base = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    paths = []
    for name in ("grid0.json", "app/gridItem.json"):
        full = os.path.join(base, name)
        if os.path.exists(full):
            paths.append(full)
    return paths


# Module-level singleton (lazy loaded)
_pathfinder: Optional[WarehousePathfinder] = None


def get_pathfinder() -> WarehousePathfinder:
    """Get or create the singleton pathfinder instance."""
    global _pathfinder
    if _pathfinder is None:
        _pathfinder = WarehousePathfinder()
        grid_paths = _get_grid_paths()
        if grid_paths:
            _pathfinder.load_grids(grid_paths)
        else:
            logger.warning("No grid files found for pathfinder")
    return _pathfinder

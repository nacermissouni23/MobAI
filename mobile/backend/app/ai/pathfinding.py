"""
Warehouse grid pathfinding using A* algorithm.

Provides a WarehousePathfinder class that loads the warehouse grid from JSON
and exposes find_path(start, goal) for route generation between emplacements.
"""

import heapq
import math
from typing import Dict, List, Optional, Tuple

from app.ai.utils import load_warehouse_grids
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
        self.grid: Dict[Tuple[int, int, int], dict] = {}
        self.elevators: List[dict] = []
        self._loaded = False

    def load(self) -> None:
        """Load warehouse grids from JSON files."""
        if self._loaded:
            return
        try:
            grids = load_warehouse_grids()
            self.grid = grids["combined"]
            self.elevators = [
                cell for cell in self.grid.values()
                if cell.get("is_elevator", False)
            ]
            self._loaded = True
            logger.info(
                f"Pathfinder loaded: {len(self.grid)} cells, "
                f"{len(self.elevators)} elevators"
            )
        except Exception as e:
            logger.warning(f"Pathfinder grid loading failed: {e}")
            self._loaded = False

    # ── public API ───────────────────────────────────────────────

    def find_path(
        self,
        start: Tuple[int, int, int],
        goal: Tuple[int, int, int],
    ) -> Optional[Dict]:
        """
        Find shortest path between two grid positions.

        Args:
            start: (x, y, floor) tuple.
            goal:  (x, y, floor) tuple.

        Returns:
            Dict with 'path' (list of (x,y,floor) tuples) and 'cost',
            or None if no path exists.
        """
        self.load()
        if not self._loaded:
            return None

        # If same-floor, direct A*
        if start[2] == goal[2]:
            path = self._astar(start, goal)
            if path:
                return {"path": path, "cost": self._path_cost(path)}
            return None

        # Cross-floor: start → elevator → elevator on goal floor → goal
        start_elevators = [
            e for e in self.elevators if e["floor"] == start[2]
        ]
        goal_elevators = [
            e for e in self.elevators if e["floor"] == goal[2]
        ]
        if not start_elevators or not goal_elevators:
            return None

        best_result = None
        best_cost = float("inf")

        for se in start_elevators:
            se_pos = (se["x"], se["y"], se["floor"])
            path1 = self._astar(start, se_pos)
            if not path1:
                continue

            # Find matching elevator on goal floor
            for ge in goal_elevators:
                if ge["x"] == se["x"] and ge["y"] == se["y"]:
                    ge_pos = (ge["x"], ge["y"], ge["floor"])
                    path2 = self._astar(ge_pos, goal)
                    if not path2:
                        continue
                    # Combined: path1 + elevator step + path2 (skip duplicate)
                    full_path = path1 + [ge_pos] + path2[1:]
                    cost = (
                        self._path_cost(path1) + 1.0 + self._path_cost(path2)
                    )
                    if cost < best_cost:
                        best_cost = cost
                        best_result = {"path": full_path, "cost": cost}

        return best_result

    # ── A* implementation ────────────────────────────────────────

    def _is_walkable(self, cell: dict) -> bool:
        if cell.get("is_obstacle"):
            return False
        return bool(
            cell.get("is_road")
            or cell.get("is_slot")
            or cell.get("is_elevator")
            or cell.get("is_expedition_zone")
        )

    def _heuristic(self, a: Tuple[int, int, int], b: Tuple[int, int, int]) -> float:
        dx = abs(a[0] - b[0])
        dy = abs(a[1] - b[1])
        return max(dx, dy) + (math.sqrt(2) - 1) * min(dx, dy)

    def _neighbors(self, pos: Tuple[int, int, int]) -> List[Tuple[int, int, int]]:
        x, y, floor = pos
        result = []
        for dx, dy in DIRECTIONS:
            nx, ny = x + dx, y + dy
            key = (nx, ny, floor)
            cell = self.grid.get(key)
            if cell and self._is_walkable(cell):
                result.append(key)
        return result

    def _astar(
        self,
        start: Tuple[int, int, int],
        goal: Tuple[int, int, int],
    ) -> Optional[List[Tuple[int, int, int]]]:
        """Single-floor A* between two positions."""
        if start == goal:
            return [start]

        open_list: list = []
        counter = 0
        heapq.heappush(open_list, (0.0, counter, start))
        g_score = {start: 0.0}
        came_from: Dict[Tuple, Tuple] = {}

        while open_list:
            _, _, current = heapq.heappop(open_list)

            if current == goal:
                # Reconstruct
                path = []
                node = goal
                while node in came_from:
                    path.append(node)
                    node = came_from[node]
                path.append(start)
                path.reverse()
                return path

            for nb in self._neighbors(current):
                dx = nb[0] - current[0]
                dy = nb[1] - current[1]
                move_cost = math.sqrt(2) if dx != 0 and dy != 0 else 1.0
                tentative = g_score[current] + move_cost
                if tentative < g_score.get(nb, float("inf")):
                    g_score[nb] = tentative
                    f = tentative + self._heuristic(nb, goal)
                    counter += 1
                    heapq.heappush(open_list, (f, counter, nb))
                    came_from[nb] = current

        return None  # no path

    def _path_cost(self, path: List[Tuple[int, int, int]]) -> float:
        cost = 0.0
        for i in range(len(path) - 1):
            x1, y1, _ = path[i]
            x2, y2, _ = path[i + 1]
            dx, dy = abs(x2 - x1), abs(y2 - y1)
            cost += math.sqrt(2) if dx and dy else 1.0
        return cost


# ── Module-level singleton ────────────────────────────────────

_pathfinder: Optional[WarehousePathfinder] = None


def get_pathfinder() -> WarehousePathfinder:
    """Return (or create) the global pathfinder singleton."""
    global _pathfinder
    if _pathfinder is None:
        _pathfinder = WarehousePathfinder()
    return _pathfinder

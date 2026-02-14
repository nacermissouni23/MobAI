"""
PICKING OPTIMIZER — COMBINED WORKFLOW

Includes:
- Multi-floor picking (plan_product_route)
- Congestion detection (check_congestion)
- Rack assignment (batch_assign_products)
- Expedition routing (optimize_expedition_route)

Shared A* pathfinding engine used everywhere.
"""

import math
import heapq
from collections import defaultdict


# ============================================================
# SHARED PATHFINDING (A*)
# ============================================================

directions = [
    (1, 0), (-1, 0),
    (0, 1), (0, -1),
    (1, 1), (1, -1),
    (-1, 1), (-1, -1)
]


def is_walkable(cell):
    if cell.get("is_obstacle"):
        return False
    return (
        cell.get("is_road")
        or cell.get("is_slot")
        or cell.get("is_elevator")
        or cell.get("is_expedition_zone")
    )


def get_neighbors(cell, grid):
    neighbors = []
    x, y, floor = cell["x"], cell["y"], cell["floor"]

    for dx, dy in directions:
        key = (x + dx, y + dy, floor)
        if key in grid and is_walkable(grid[key]):
            neighbors.append((grid[key], dx, dy))

    return neighbors


def heuristic(a, b):
    dx = abs(a["x"] - b["x"])
    dy = abs(a["y"] - b["y"])
    return max(dx, dy) + (math.sqrt(2) - 1) * min(dx, dy)


def astar(start, goal, grid):
    open_list = []
    counter = 0

    heapq.heappush(open_list, (0, counter, start))

    came_from = {}
    g_score = {(start["x"], start["y"], start["floor"]): 0.0}

    while open_list:
        _, _, current = heapq.heappop(open_list)

        if (
            current["x"] == goal["x"]
            and current["y"] == goal["y"]
            and current["floor"] == goal["floor"]
        ):
            break

        for neighbor, dx, dy in get_neighbors(current, grid):
            move_cost = 1.0 if dx == 0 or dy == 0 else math.sqrt(2)

            cur_key = (current["x"], current["y"], current["floor"])
            tentative = g_score[cur_key] + move_cost

            key = (neighbor["x"], neighbor["y"], neighbor["floor"])

            if tentative < g_score.get(key, float("inf")):
                g_score[key] = tentative
                f = tentative + heuristic(neighbor, goal)

                counter += 1
                heapq.heappush(open_list, (f, counter, neighbor))
                came_from[key] = cur_key

    return reconstruct_path(came_from, start, goal)


def reconstruct_path(came_from, start, goal):
    path = []
    current = (goal["x"], goal["y"], goal["floor"])
    start_key = (start["x"], start["y"], start["floor"])

    if current not in came_from and current != start_key:
        return []

    while current in came_from:
        path.append(current)
        current = came_from[current]

    path.append(start_key)
    path.reverse()
    return path


def path_cost(path):
    cost = 0.0
    for i in range(len(path) - 1):
        x1, y1, _ = path[i]
        x2, y2, _ = path[i + 1]
        dx, dy = abs(x2 - x1), abs(y2 - y1)
        cost += math.sqrt(2) if dx and dy else 1.0
    return cost


# ============================================================
# PICKING (MULTI FLOOR)
# ============================================================

def find_all_product_slots(product_id, grid):
    return [
        c for c in grid.values()
        if c.get("product_id") == product_id and c.get("quantity", 0) > 0
    ]


def best_elevator_path(from_cell, elevators, grid):
    best = (None, float("inf"), None)

    for e in elevators:
        if e["floor"] != from_cell["floor"]:
            continue

        path = astar(from_cell, e, grid)
        if not path:
            continue

        cost = path_cost(path)
        if cost < best[1]:
            best = (path, cost, e)

    return best


def get_floor_elevator(floor, elevators):
    for e in elevators:
        if e["floor"] == floor:
            return e
    return None


def plan_product_route(product_id, quantity, start, elevators, grid):

    slots = find_all_product_slots(product_id, grid)

    if not slots:
        return None, f"{product_id} not found"

    available = sum(s.get("quantity", 0) for s in slots)
    if available < quantity:
        return None, f"Only {available} available"

    remaining = quantity
    visited = set()
    current = start
    stops = []

    while remaining > 0:

        scored = []

        for slot in slots:
            key = (slot["x"], slot["y"], slot["floor"])
            if key in visited:
                continue

            eff_start = (
                get_floor_elevator(slot["floor"], elevators)
                if slot["floor"] != current["floor"]
                else current
            )

            if not eff_start:
                continue

            path = astar(eff_start, slot, grid)
            if path:
                scored.append((path_cost(path), slot, path))

        if not scored:
            return None, "Unreachable slots"

        cost, slot, path = min(scored, key=lambda x: x[0])

        take = min(slot["quantity"], remaining)
        remaining -= take
        visited.add((slot["x"], slot["y"], slot["floor"]))

        elev_path, elev_cost, elev = best_elevator_path(slot, elevators, grid)

        stops.append({
            "slot": slot,
            "qty_taken": take,
            "path_to_slot": path,
            "path_to_elevator": elev_path,
            "cost": cost + elev_cost
        })

        current = slot

    total_cost = sum(s["cost"] for s in stops)

    return {
        "mode": "multi",
        "stops": stops,
        "total_cost": total_cost
    }, None


# ============================================================
# CONGESTION
# ============================================================

def check_congestion(routes):

    occupancy = defaultdict(set)

    for rid, route in routes.items():
        for stop in route.get("stops", []):
            for step in stop.get("path_to_slot", []):
                occupancy[step].add(rid)
            for step in stop.get("path_to_elevator", []):
                occupancy[step].add(rid)

    conflicts = {
        cell: ids for cell, ids in occupancy.items()
        if len(ids) > 1
    }

    return conflicts


# ============================================================
# RACK ASSIGNMENT
# ============================================================

def calculate_distance_score(rack, expedition_cells):
    d = min(
        math.hypot(rack["x"] - e["x"], rack["y"] - e["y"])
        for e in expedition_cells
    )
    return 1 / (1 + d), d


def calculate_weight_score(weight, level):
    norm = min(weight / 100, 1)
    ideal = 3 - int(norm * 3)
    return 1 - abs(level - ideal) / 3


def calculate_frequency_score(freq, dist):
    norm = min(freq / 100, 1)
    return norm / (1 + dist)


def find_available_racks(grid):
    return [
        c for c in grid.values()
        if c.get("is_slot")
        and c.get("floor") == 0
        and not c.get("is_occupied")
    ]


def assign_product_to_rack(pid, info, grid, elevator):

    expedition = [
        c for c in grid.values()
        if c.get("is_expedition_zone") and c.get("floor") == 0
    ]

    racks = find_available_racks(grid)
    if not racks:
        return None, "No racks"

    scored = []

    for rack in racks:

        ds, dist = calculate_distance_score(rack, expedition)
        ws = calculate_weight_score(info["weight"], rack.get("z", 0))
        fs = calculate_frequency_score(info["frequency"], dist)

        score = 0.4 * ds + 0.3 * ws + 0.3 * fs

        scored.append((score, rack))

    scored.sort(reverse=True)

    assignments = []

    for score, rack in scored[:info["quantity"]]:

        path = astar(grid[elevator], rack, grid)
        if not path:
            continue

        assignments.append({
            "rack": rack,
            "score": score,
            "path": path,
            "distance": path_cost(path)
        })

    return assignments, None


def batch_assign_products(products, grid, elevator):

    occupied = set()
    results = {}

    ordered = sorted(
        products.items(),
        key=lambda x: x[1]["frequency"],
        reverse=True
    )

    for pid, info in ordered:

        temp = {k: v.copy() for k, v in grid.items()}

        for occ in occupied:
            if occ in temp:
                temp[occ]["is_occupied"] = True

        assign, err = assign_product_to_rack(pid, info, temp, elevator)

        if assign:
            for a in assign:
                r = a["rack"]
                occupied.add((r["x"], r["y"], r["floor"]))

            results[pid] = assign

    return results


# ============================================================
# EXPEDITION OPTIMIZATION
# ============================================================

def find_product_in_racks(pid, grid):
    return [
        c for c in grid.values()
        if c.get("is_slot")
        and c.get("floor") == 0
        and c.get("product_id") == pid
        and c.get("quantity", 0) > 0
    ]


def find_nearest_expedition(start, grid):

    zones = [
        c for c in grid.values()
        if c.get("is_expedition_zone") and c.get("floor") == 0
    ]

    best = (None, None, float("inf"))

    for z in zones:
        p = astar(start, z, grid)
        if p:
            d = path_cost(p)
            if d < best[2]:
                best = (z, p, d)

    return best


def optimize_expedition_route(order, grid):

    zones = [
        c for c in grid.values()
        if c.get("is_expedition_zone") and c.get("floor") == 0
    ]

    if not zones:
        return None, "No expedition zone"

    current = zones[0]
    plan = []
    total = 0

    for pid, qty in order.items():

        racks = find_product_in_racks(pid, grid)
        remaining = qty
        stops = []

        while remaining and racks:

            best = None
            best_p = None
            best_d = float("inf")

            for r in racks:
                p = astar(current, r, grid)
                if p:
                    d = path_cost(p)
                    if d < best_d:
                        best, best_p, best_d = r, p, d

            if not best:
                break

            take = min(best.get("quantity", 0), remaining)
            remaining -= take

            stops.append({
                "rack": best,
                "qty": take,
                "path": best_p,
                "distance": best_d
            })

            total += best_d
            current = best
            racks.remove(best)

        plan.append({"product": pid, "stops": stops})

    zone, path, d = find_nearest_expedition(current, grid)

    total += d

    return {
        "plan": plan,
        "return_path": path,
        "total_distance": total
    }, None

import json
import math
import heapq
from collections import defaultdict

# ======================================
# MOVEMENTS (8-direction, same floor only)
# ======================================
directions = [
    (1, 0), (-1, 0),
    (0, 1), (0, -1),
    (1, 1), (1, -1),
    (-1, 1), (-1, -1)
]

# ======================================
# WALKABLE CHECK
# ======================================
def is_walkable(cell):
    if cell.get("is_obstacle", False):
        return False
    if cell.get("is_road", False):
        return True
    if cell.get("is_slot", False):
        return True
    if cell.get("is_elevator", False):
        return True
    return False

# ======================================
# GET NEIGHBORS (same floor only)
# ======================================
def get_neighbors(cell, grid):
    neighbors = []
    x, y, floor = cell["x"], cell["y"], cell["floor"]
    for dx, dy in directions:
        key = (x + dx, y + dy, floor)
        if key in grid and is_walkable(grid[key]):
            neighbors.append((grid[key], dx, dy))
    return neighbors

# ======================================
# HEURISTIC (Octile Distance)
# ======================================
def heuristic(a, b):
    dx = abs(a["x"] - b["x"])
    dy = abs(a["y"] - b["y"])
    return max(dx, dy) + (math.sqrt(2) - 1) * min(dx, dy)

# ======================================
# A* ALGORITHM
# ======================================
def astar(start, goal, grid):
    open_list = []
    counter = 0
    heapq.heappush(open_list, (0, counter, start))
    came_from = {}
    g_score = {(start["x"], start["y"], start["floor"]): 0.0}

    while open_list:
        _, _, current = heapq.heappop(open_list)
        if (current["x"] == goal["x"] and
            current["y"] == goal["y"] and
            current["floor"] == goal["floor"]):
            break
        for neighbor, dx, dy in get_neighbors(current, grid):
            move_cost = 1.0 if (dx == 0 or dy == 0) else math.sqrt(2)
            cur_key = (current["x"], current["y"], current["floor"])
            tentative_g = g_score.get(cur_key, float("inf")) + move_cost
            key = (neighbor["x"], neighbor["y"], neighbor["floor"])
            if key not in g_score or tentative_g < g_score[key]:
                g_score[key] = tentative_g
                f = tentative_g + heuristic(neighbor, goal)
                counter += 1
                heapq.heappush(open_list, (f, counter, neighbor))
                came_from[key] = cur_key

    return reconstruct_path(came_from, start, goal)

# ======================================
# RECONSTRUCT PATH
# ======================================
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

# ======================================
# PATH COST
# ======================================
def path_cost(path):
    cost = 0.0
    for i in range(len(path) - 1):
        x1, y1, _ = path[i]
        x2, y2, _ = path[i + 1]
        dx, dy = abs(x2 - x1), abs(y2 - y1)
        cost += math.sqrt(2) if dx == 1 and dy == 1 else 1.0
    return cost

# ======================================
# FIND ALL SLOTS FOR A PRODUCT
# ======================================
def find_all_product_slots(product_id, grid):
    return [cell for cell in grid.values()
            if cell.get("product_id") == product_id and cell.get("quantity", 0) > 0]

# ======================================
# FIND NEAREST ELEVATOR ON SAME FLOOR
# ======================================
def best_elevator_path(from_cell, elevators, grid):
    best_cost = float("inf")
    best_path = None
    best_elev = None
    for elevator in elevators:
        if elevator["floor"] != from_cell["floor"]:
            continue
        path = astar(from_cell, elevator, grid)
        if path:
            cost = path_cost(path)
            if cost < best_cost:
                best_cost = cost
                best_path = path
                best_elev = elevator
    return best_path, best_cost, best_elev

# ======================================
# GET ELEVATOR ON A SPECIFIC FLOOR
# ======================================
def get_floor_elevator(floor, elevators):
    candidates = [e for e in elevators if e["floor"] == floor]
    return candidates[0] if candidates else None

# ======================================
# PLAN ROUTE FOR ONE PRODUCT
# Returns a list of floor-groups, each with stops + one elevator exit
# ======================================
def plan_product_route(product_id, quantity, start, elevators, grid):

    all_slots = find_all_product_slots(product_id, grid)

    if not all_slots:
        return None, f"Product '{product_id}' not found."

    total_available = sum(s.get("quantity", 0) for s in all_slots)
    if total_available < quantity:
        return None, f"Only {total_available} available, {quantity} requested."

    # ── CASE 1: Single slot can fulfill ──────────────────────────────────
    single_candidates = [s for s in all_slots if s.get("quantity", 0) >= quantity]
    if single_candidates:
        all_solutions = []
        for slot in single_candidates:
            eff_start = get_floor_elevator(slot["floor"], elevators) if start["floor"] != slot["floor"] else start
            if not eff_start:
                continue
            path_to_slot = astar(eff_start, slot, grid)
            if not path_to_slot:
                continue
            cost1 = path_cost(path_to_slot)
            path_to_elev, cost2, best_elev = best_elevator_path(slot, elevators, grid)
            if not path_to_elev:
                continue
            all_solutions.append({
                "mode": "single",
                "slot_location": (slot["x"], slot["y"], slot["z"]),
                "floor": slot["floor"],
                "qty_taken": quantity,
                "cost_to_slot": cost1,
                "cost_to_elevator": cost2,
                "total_cost": cost1 + cost2,
                "path_to_slot": path_to_slot,
                "path_to_elevator": path_to_elev,
                "floor_groups": None
            })
        if all_solutions:
            return min(all_solutions, key=lambda x: x["total_cost"]), None

    # ── CASE 2: Multi-slot — group stops by floor, ONE elevator per floor ─
    remaining = quantity
    current_pos = start
    visited = set()
    all_stops = []   # flat list of all stops with floor info
    pool = list(all_slots)

    while remaining > 0:
        scored = []
        current_floor = current_pos["floor"]

        for slot in pool:
            slot_key = (slot["x"], slot["y"], slot["floor"])
            if slot_key in visited:
                continue
            eff_start = get_floor_elevator(slot["floor"], elevators) if slot["floor"] != current_floor else current_pos
            if not eff_start:
                continue
            path = astar(eff_start, slot, grid)
            if not path:
                continue
            cost = path_cost(path)
            scored.append((cost, slot, path))

        if not scored:
            return None, f"Cannot reach more slots. Still need {remaining} units."

        # Sort: closer floor first, then nearest path
        scored.sort(key=lambda x: (abs(x[1]["floor"] - current_floor), x[0]))
        best_cost, best_slot, best_path = scored[0]

        take = min(best_slot["quantity"], remaining)
        remaining -= take
        visited.add((best_slot["x"], best_slot["y"], best_slot["floor"]))

        all_stops.append({
            "slot": best_slot,
            "floor": best_slot["floor"],
            "slot_location": (best_slot["x"], best_slot["y"], best_slot["z"]),
            "qty_taken": take,
            "qty_remaining": remaining,
            "cost_to_slot": best_cost,
            "path_to_slot": best_path,
        })

        current_pos = best_slot

    # ── Group stops by floor, compute ONE elevator path per floor group ──
    floor_groups = []
    i = 0
    while i < len(all_stops):
        group_floor = all_stops[i]["floor"]
        group_stops = []

        # Collect all consecutive stops on the same floor
        while i < len(all_stops) and all_stops[i]["floor"] == group_floor:
            group_stops.append(all_stops[i])
            i += 1

        # Elevator path from the LAST slot of this floor group
        last_slot = group_stops[-1]["slot"]
        path_to_elev, cost_elev, best_elev = best_elevator_path(last_slot, elevators, grid)

        floor_groups.append({
            "floor": group_floor,
            "stops": group_stops,
            "path_to_elevator": path_to_elev,
            "cost_to_elevator": cost_elev if path_to_elev else 0,
            "elevator_location": (best_elev["x"], best_elev["y"]) if best_elev else None
        })

    total_cost = (
        sum(s["cost_to_slot"] for g in floor_groups for s in g["stops"]) +
        sum(g["cost_to_elevator"] for g in floor_groups)
    )

    return {
        "mode": "multi",
        "floor_groups": floor_groups,
        "total_stops": len(all_stops),
        "total_cost": total_cost,
    }, None


# ======================================
# PRINT ROUTE FOR ONE PRODUCT
# ======================================
def print_route(product_id, quantity, route):
    print(f"\n{'='*60}")
    print(f"  PRODUCT: {product_id}  |  Requested: {quantity} units")
    print(f"{'='*60}")

    if route["mode"] == "single":
        print(f"  ✓ Single-slot route")
        print(f"  Floor        : {route['floor']}")
        print(f"  Slot         : {route['slot_location']}")
        print(f"  Qty taken    : {route['qty_taken']}")
        print(f"  Cost → slot  : {round(route['cost_to_slot'], 2)}")
        print(f"  Cost → elev  : {round(route['cost_to_elevator'], 2)}")
        print(f"  TOTAL COST   : {round(route['total_cost'], 2)}")
        print(f"  Path to slot : {route['path_to_slot']}")
        print(f"  Path to elev : {route['path_to_elevator']}")
        return

    # Multi-slot: print by floor group
    print(f"  ✓ Multi-slot route  |  Total stops: {route['total_stops']}")
    print(f"  TOTAL COST   : {round(route['total_cost'], 2)}\n")

    stop_num = 1
    for g in route["floor_groups"]:
        print(f"  ── FLOOR {g['floor']} ──────────────────────────────────────")
        for s in g["stops"]:
            print(f"    STOP {stop_num}:")
            print(f"      Slot       : {s['slot_location']} | Floor: {s['floor']}")
            print(f"      Qty taken  : {s['qty_taken']}  (still need: {s['qty_remaining']})")
            print(f"      Cost→ slot : {round(s['cost_to_slot'], 2)}")
            print(f"      Path       : {s['path_to_slot']}")
            stop_num += 1
        print(f"    → ELEVATOR at {g['elevator_location']}  (cost: {round(g['cost_to_elevator'], 2)})")
        print(f"      Path       : {g['path_to_elevator']}")
        print()


# ======================================
# CONGESTION CHECK — detect path conflicts
# ======================================
def check_congestion(routes: dict):
    """
    routes = { "chariot_A": route_result, "chariot_B": route_result, ... }
    Collects all path cells per chariot and finds overlapping cells.
    """
    chariot_cells = {}

    for chariot_id, route in routes.items():
        cells = set()
        if route["mode"] == "single":
            for step in route.get("path_to_slot", []):
                cells.add(step)
            for step in route.get("path_to_elevator", []):
                cells.add(step)
        else:
            for g in route["floor_groups"]:
                for s in g["stops"]:
                    for step in s.get("path_to_slot", []):
                        cells.add(step)
                if g.get("path_to_elevator"):
                    for step in g["path_to_elevator"]:
                        cells.add(step)
        chariot_cells[chariot_id] = cells

    print(f"\n{'='*60}")
    print(f"  CONGESTION CHECK")
    print(f"{'='*60}")

    chariot_ids = list(chariot_cells.keys())
    found_conflict = False

    for i in range(len(chariot_ids)):
        for j in range(i + 1, len(chariot_ids)):
            a, b = chariot_ids[i], chariot_ids[j]
            overlap = chariot_cells[a] & chariot_cells[b]
            if overlap:
                found_conflict = True
                print(f"  ⚠ CONFLICT: {a} ↔ {b}")
                print(f"    {len(overlap)} shared cell(s) on floors: "
                      f"{sorted(set(c[2] for c in overlap))}")
                print(f"    Cells: {sorted(overlap)[:10]}"
                      f"{'...' if len(overlap) > 10 else ''}")
                print(f"    → Suggestion: delay {b} at elevator until {a} clears floor(s) "
                      f"{sorted(set(c[2] for c in overlap))}")
            else:
                print(f"  ✓ No conflict: {a} ↔ {b}")

    if not found_conflict:
        print("  All chariots have conflict-free paths.")


# ======================================
# MAIN PROGRAM
# ======================================
if __name__ == "__main__":

    with open("gridItem.json", encoding="utf-8") as f:
        data = json.load(f)

    cells = data["cells"]
    grid = {(cell["x"], cell["y"], cell["floor"]): cell for cell in cells}

    floors = sorted(set(c["floor"] for c in cells))
    print(f"Grid loaded: {len(grid)} cells across floors {floors}")

    elevators = [c for c in grid.values() if c.get("is_elevator", False)]
    # print(f"Elevators found: {len(elevators)}")
    # for e in elevators:
    #     print(f"  Elevator at ({e['x']}, {e['y']}) — Floor {e['floor']}")

    # Start = elevator on floor 1
    current_floor = 1
    start_cands = [e for e in elevators if e["floor"] == current_floor]
    if not start_cands:
        print(f"No elevator on floor {current_floor}. "
              f"Available: {sorted(set(e['floor'] for e in elevators))}")
        exit(1)
    start = start_cands[0]
    print(f"Start: ({start['x']}, {start['y']}) — Floor {start['floor']}")

    # ── Define orders: product_id → quantity ─────────────────────────────
    orders = {
        "Chariot_A": ("31798", 200),
        "Chariot_B": ("31858", 50),   
        "Chariot_C": ("31860", 400),
    }

    # ── Plan route for each chariot ───────────────────────────────────────
    all_routes = {}

    for chariot_id, (product_id, quantity) in orders.items():
        route, error = plan_product_route(product_id, quantity, start, elevators, grid)
        if error:
            print(f"\n[{chariot_id}] ERROR: {error}")
        else:
            print_route(product_id, quantity, route)
            all_routes[chariot_id] = route

    # ── Congestion check across all chariots ──────────────────────────────
    if len(all_routes) > 1:
        check_congestion(all_routes)
    else:
        print("\n(Add more chariots to the 'orders' dict to enable congestion check)")
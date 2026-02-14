"""
EXPEDITION ROUTE OPTIMIZER
===========================

This is the FINAL step in the workflow:
After products are stored in racks, this algorithm picks them 
and delivers them to the expedition zone when orders come in.

WORKFLOW POSITION:
1. grok.py         → Storage floors → Elevator
2. racks.py        → Elevator → Racks (storage)
3. expedition.py   → Racks → Expedition Zone (THIS FILE!)

"""

import json
import math
import heapq
from collections import defaultdict

# ======================================
# PATHFINDING FUNCTIONS (A*)
# ======================================

directions = [
    (1, 0), (-1, 0),
    (0, 1), (0, -1),
    (1, 1), (1, -1),
    (-1, 1), (-1, -1)
]

def is_walkable(cell):
    if cell.get("is_obstacle", False):
        return False
    if cell.get("is_road", False):
        return True
    if cell.get("is_slot", False):
        return True
    if cell.get("is_expedition_zone", False):
        return True
    return False

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
        cost += math.sqrt(2) if dx == 1 and dy == 1 else 1.0
    return cost


# ======================================
# FIND PRODUCTS IN RACKS
# ======================================

def find_product_in_racks(product_id, grid):
    """
    Find all rack locations containing a specific product.
    
    Args:
        product_id: the product to find
        grid: warehouse grid
        
    Returns:
        List of rack cells containing the product
    """
    rack_locations = []
    
    for cell in grid.values():
        # Check if it's a rack slot on ground floor
        if not cell.get('is_slot', False):
            continue
        if cell.get('floor', -1) != 0:
            continue
        
        # Check if it contains the product
        if cell.get('product_id') == product_id and cell.get('quantity', 0) > 0:
            rack_locations.append(cell)
    
    return rack_locations


# ======================================
# FIND NEAREST EXPEDITION ZONE
# ======================================

def find_nearest_expedition_zone(start_cell, grid):
    """
    Find the nearest expedition zone from a given location.
    
    Args:
        start_cell: starting position
        grid: warehouse grid
        
    Returns:
        (expedition_cell, path, distance)
    """
    expedition_zones = [
        cell for cell in grid.values()
        if cell.get('is_expedition_zone', False) and cell.get('floor', -1) == 0
    ]
    
    if not expedition_zones:
        return None, None, float('inf')
    
    best_zone = None
    best_path = None
    best_distance = float('inf')
    
    for zone in expedition_zones:
        path = astar(start_cell, zone, grid)
        if path:
            distance = path_cost(path)
            if distance < best_distance:
                best_distance = distance
                best_path = path
                best_zone = zone
    
    return best_zone, best_path, best_distance


# ======================================
# EXPEDITION ORDER OPTIMIZATION
# ======================================

def optimize_expedition_route(order_items, grid, start_position=None):
    """
    Optimize the route to pick products from racks and deliver to expedition.
    
    Args:
        order_items: {product_id: quantity_needed}
        grid: warehouse grid
        start_position: optional starting position (x, y, floor)
        
    Returns:
        Optimized picking route with all stops
    """
    
    print(f"\n{'='*70}")
    print(f"  EXPEDITION ROUTE OPTIMIZATION")
    print(f"{'='*70}")
    
    # Find expedition zones
    expedition_zones = [
        cell for cell in grid.values()
        if cell.get('is_expedition_zone', False) and cell.get('floor', -1) == 0
    ]
    
    if not expedition_zones:
        return None, "No expedition zone found on ground floor"
    
    # Default start: first expedition zone (like a worker starting from expedition area)
    if start_position:
        current_pos = grid.get(start_position)
    else:
        current_pos = expedition_zones[0]
    
    print(f"\nStarting position: ({current_pos['x']}, {current_pos['y']})")
    
    # Build picking plan
    picking_plan = []
    total_distance = 0
    
    for product_id, quantity_needed in order_items.items():
        print(f"\n  Processing: {product_id} x{quantity_needed}")
        
        # Find all racks with this product
        rack_locations = find_product_in_racks(product_id, grid)
        
        if not rack_locations:
            print(f"  ✗ ERROR: Product {product_id} not found in any rack")
            continue
        
        print(f"    Found in {len(rack_locations)} rack location(s)")
        
        # Collect from racks (greedy nearest-first approach)
        remaining = quantity_needed
        product_stops = []
        
        while remaining > 0 and rack_locations:
            # Find nearest rack with this product
            best_rack = None
            best_path = None
            best_distance = float('inf')
            
            for rack in rack_locations:
                path = astar(current_pos, rack, grid)
                if path:
                    distance = path_cost(path)
                    if distance < best_distance:
                        best_distance = distance
                        best_path = path
                        best_rack = rack
            
            if not best_rack:
                print(f"  ✗ Cannot reach remaining racks")
                break
            
            # Pick from this rack
            available = best_rack.get('quantity', 0)
            pick_qty = min(available, remaining)
            remaining -= pick_qty
            
            product_stops.append({
                'rack_location': (best_rack['x'], best_rack['y'], best_rack['z']),
                'rack_level': best_rack.get('z', 0),
                'quantity_picked': pick_qty,
                'quantity_remaining': remaining,
                'path_to_rack': best_path,
                'distance': best_distance
            })
            
            total_distance += best_distance
            current_pos = best_rack
            rack_locations.remove(best_rack)
        
        if remaining > 0:
            print(f"  ⚠ WARNING: Still need {remaining} units of {product_id}")
        
        picking_plan.append({
            'product_id': product_id,
            'quantity_requested': quantity_needed,
            'quantity_collected': quantity_needed - remaining,
            'stops': product_stops
        })
    
    # Final step: route to expedition zone
    print(f"\n  Planning route to expedition zone...")
    expedition_zone, path_to_expedition, exp_distance = find_nearest_expedition_zone(
        current_pos, grid
    )
    
    if not expedition_zone:
        return None, "Cannot find path to expedition zone"
    
    total_distance += exp_distance
    
    print(f"    Distance to expedition: {exp_distance:.2f}m")
    
    # Build complete result
    result = {
        'order_items': order_items,
        'picking_plan': picking_plan,
        'expedition_zone': (expedition_zone['x'], expedition_zone['y']),
        'path_to_expedition': path_to_expedition,
        'expedition_distance': exp_distance,
        'total_distance': total_distance,
        'total_stops': sum(len(p['stops']) for p in picking_plan)
    }
    
    return result, None


# ======================================
# PRINT EXPEDITION ROUTE
# ======================================

def print_expedition_route(result):
    """Pretty print the expedition route"""
    
    print(f"\n{'='*70}")
    print(f"  EXPEDITION ROUTE DETAILS")
    print(f"{'='*70}")
    
    stop_number = 1
    
    for product in result['picking_plan']:
        print(f"\n  Product: {product['product_id']}")
        print(f"  Requested: {product['quantity_requested']} | Collected: {product['quantity_collected']}")
        
        for stop in product['stops']:
            print(f"\n    STOP {stop_number}:")
            print(f"      Rack Location : {stop['rack_location']} (Level {stop['rack_level']})")
            print(f"      Pick Quantity : {stop['quantity_picked']}")
            print(f"      Distance      : {stop['distance']:.2f}m")
            print(f"      Still Need    : {stop['quantity_remaining']}")
            stop_number += 1
    
    print(f"\n  FINAL DELIVERY:")
    print(f"    Expedition Zone : {result['expedition_zone']}")
    print(f"    Distance        : {result['expedition_distance']:.2f}m")
    
    print(f"\n{'='*70}")
    print(f"  SUMMARY")
    print(f"{'='*70}")
    print(f"  Total Products    : {len(result['picking_plan'])}")
    print(f"  Total Stops       : {result['total_stops']}")
    print(f"  Total Distance    : {result['total_distance']:.2f}m")
    print(f"  Avg Distance/Stop : {result['total_distance'] / result['total_stops']:.2f}m" 
          if result['total_stops'] > 0 else "  Avg Distance/Stop : N/A")


# ======================================
# MULTI-ORDER BATCH OPTIMIZATION
# ======================================

def batch_expedition_orders(orders_list, grid):
    """
    Optimize multiple delivery orders.
    Can either:
    - Process sequentially (one worker, multiple orders)
    - Process in parallel (multiple workers, one order each)
    
    Args:
        orders_list: [
            {"order_id": "ORD001", "items": {product_id: quantity}},
            {"order_id": "ORD002", "items": {product_id: quantity}}
        ]
        grid: warehouse grid
        
    Returns:
        Results for all orders
    """
    
    print(f"\n{'='*70}")
    print(f"  BATCH EXPEDITION OPTIMIZATION")
    print(f"{'='*70}")
    print(f"  Total Orders: {len(orders_list)}")
    
    all_results = {}
    
    for order in orders_list:
        order_id = order['order_id']
        items = order['items']
        
        print(f"\n  ── Processing Order: {order_id}")
        
        result, error = optimize_expedition_route(items, grid)
        
        if error:
            print(f"  ✗ ERROR: {error}")
            continue
        
        all_results[order_id] = result
        print(f"  ✓ Order {order_id}: {result['total_stops']} stops, {result['total_distance']:.2f}m")
    
    return all_results


# ======================================
# EXAMPLE USAGE
# ======================================

if __name__ == "__main__":
    
    # Load ground floor grid
    with open("grid0.json", encoding="utf-8") as f:
        data = json.load(f)
    
    cells = data["cells"]
    grid = {(cell["x"], cell["y"], cell["floor"]): cell for cell in cells}
    
    print(f"Grid loaded: {len(grid)} cells")
    
    # ── EXAMPLE 1: Single Delivery Order ──
    
    delivery_order = {
        "31798": 3,  # Need 3 units of product 31798
        "31858": 2,  # Need 2 units of product 31858
        "31860": 5   # Need 5 units of product 31860
    }
    
    print("\n" + "="*70)
    print("  SINGLE ORDER EXPEDITION")
    print("="*70)
    
    result, error = optimize_expedition_route(delivery_order, grid)
    
    if error:
        print(f"ERROR: {error}")
    else:
        print_expedition_route(result)
    
    
    # ── EXAMPLE 2: Multiple Orders (Batch) ──
    
    print("\n\n" + "="*70)
    print("  BATCH ORDERS EXPEDITION")
    print("="*70)
    
    orders = [
        {
            "order_id": "ORD001",
            "items": {"31798": 2, "31860": 3}
        },
        {
            "order_id": "ORD002",
            "items": {"31858": 1, "31860": 2}
        },
        {
            "order_id": "ORD003",
            "items": {"31798": 5}
        }
    ]
    
    batch_results = batch_expedition_orders(orders, grid)
    
    # Print summary
    print(f"\n{'='*70}")
    print(f"  BATCH SUMMARY")
    print(f"{'='*70}")
    print(f"  Orders Processed  : {len(batch_results)}")
    print(f"  Total Distance    : {sum(r['total_distance'] for r in batch_results.values()):.2f}m")
    print(f"  Total Stops       : {sum(r['total_stops'] for r in batch_results.values())}")
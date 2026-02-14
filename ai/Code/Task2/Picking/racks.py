import json
import math
import heapq
from collections import defaultdict

# ======================================
# RACK ASSIGNMENT OPTIMIZATION
# Ground Floor: Elevator → Picking Racks → Expedition Zone
# ======================================

"""
ALGORITHM OVERVIEW:
After products arrive at ground floor elevator from upper floors,
we need to assign them to picking racks (4 levels: 0-3) based on:
1. Distance to expedition zone (minimize travel)
2. Product weight (heavy items on lower levels)
3. Product demand frequency (high-demand near expedition)
4. Rack availability (check occupied slots)
5. Rack level optimization (distribute across 4 levels)
"""

# ======================================
# SCORING FUNCTIONS
# ======================================

def calculate_distance_score(rack_cell, expedition_zone_cells):
    """
    Calculate minimum distance from rack to any expedition zone cell.
    Lower distance = Higher score (inverse scoring)
    """
    min_distance = float('inf')
    for exp_cell in expedition_zone_cells:
        dist = math.sqrt(
            (rack_cell['x'] - exp_cell['x'])**2 + 
            (rack_cell['y'] - exp_cell['y'])**2
        )
        min_distance = min(min_distance, dist)
    
    # Convert to score (inverse): closer = higher score
    # Using 1/(1+distance) to normalize between 0 and 1
    distance_score = 1.0 / (1.0 + min_distance)
    return distance_score, min_distance


def calculate_weight_score(product_weight, rack_level):
    """
    Heavy products should be on lower levels (0=ground, 3=top).
    Score is higher when heavy products are on lower levels.
    
    Args:
        product_weight: weight in kg (e.g., 0-100)
        rack_level: 0 (ground) to 3 (top)
    """
    # Normalize weight (assuming max weight = 100kg)
    normalized_weight = min(product_weight / 100.0, 1.0)
    
    # Ideal level for this weight (0 for heavy, 3 for light)
    ideal_level = 3 - int(normalized_weight * 3)
    
    # Score based on how close actual level is to ideal
    level_diff = abs(rack_level - ideal_level)
    weight_score = 1.0 - (level_diff / 3.0)
    
    return weight_score


def calculate_frequency_score(product_frequency, distance_to_expedition):
    """
    High-frequency products should be closer to expedition zone.
    
    Args:
        product_frequency: picks per day (e.g., 0-100)
        distance_to_expedition: already calculated distance
    """
    # Normalize frequency (assuming max = 100 picks/day)
    normalized_freq = min(product_frequency / 100.0, 1.0)
    
    # High frequency + low distance = high score
    # Low frequency can be farther away
    frequency_score = normalized_freq * (1.0 / (1.0 + distance_to_expedition))
    
    return frequency_score


# ======================================
# RACK SLOT EVALUATION
# ======================================

def evaluate_rack_slot(rack_cell, product_info, expedition_zone_cells):
    """
    Comprehensive scoring for a potential rack slot assignment.
    
    Args:
        rack_cell: the rack location cell
        product_info: dict with {weight, frequency, quantity}
        expedition_zone_cells: list of expedition zone cells
    
    Returns:
        total_score, score_breakdown
    """
    # Extract rack level (z coordinate)
    rack_level = rack_cell.get('z', 0)
    
    # Calculate individual scores
    distance_score, distance = calculate_distance_score(rack_cell, expedition_zone_cells)
    weight_score = calculate_weight_score(product_info['weight'], rack_level)
    frequency_score = calculate_frequency_score(product_info['frequency'], distance)
    
    # Weighted combination (you can adjust these weights)
    WEIGHT_DISTANCE = 0.4
    WEIGHT_WEIGHT = 0.3
    WEIGHT_FREQUENCY = 0.3
    
    total_score = (
        WEIGHT_DISTANCE * distance_score +
        WEIGHT_WEIGHT * weight_score +
        WEIGHT_FREQUENCY * frequency_score
    )
    
    breakdown = {
        'distance_score': distance_score,
        'distance_meters': distance,
        'weight_score': weight_score,
        'frequency_score': frequency_score,
        'rack_level': rack_level,
        'total_score': total_score
    }
    
    return total_score, breakdown


# ======================================
# FIND AVAILABLE RACKS
# ======================================

def find_available_racks(grid, required_quantity):
    """
    Find all available rack slots that can accommodate the product.
    
    Args:
        grid: the warehouse grid
        required_quantity: number of units to store
    
    Returns:
        list of available rack cells
    """
    available_racks = []
    
    for cell in grid.values():
        # Check if it's a rack slot (picking location)
        if not cell.get('is_slot', False):
            continue
        
        # Check if on ground floor (floor 0)
        if cell.get('floor', -1) != 0:
            continue
        
        # Check if not occupied
        if cell.get('is_occupied', False):
            continue
        
        # Check if has capacity (assuming 1 product per slot for now)
        # You can modify this based on your capacity model
        available_racks.append(cell)
    
    return available_racks


# ======================================
# RACK ASSIGNMENT ALGORITHM
# ======================================

def assign_product_to_rack(product_id, product_info, grid, elevator_location):
    """
    Main algorithm: Assign product from elevator to optimal rack.
    
    Args:
        product_id: unique product identifier
        product_info: {quantity, weight, frequency}
        grid: warehouse grid
        elevator_location: (x, y, floor) of ground floor elevator
    
    Returns:
        assignment_result or error
    """
    
    # 1. Find expedition zone cells
    expedition_zone_cells = [
        cell for cell in grid.values() 
        if cell.get('is_expedition_zone', False) and cell.get('floor', -1) == 0
    ]
    
    if not expedition_zone_cells:
        return None, "No expedition zone found on ground floor"
    
    # 2. Find available racks
    available_racks = find_available_racks(grid, product_info['quantity'])
    
    if not available_racks:
        return None, "No available rack slots on ground floor"
    
    # 3. Score all available racks
    scored_racks = []
    
    for rack in available_racks:
        score, breakdown = evaluate_rack_slot(rack, product_info, expedition_zone_cells)
        
        scored_racks.append({
            'rack_cell': rack,
            'location': (rack['x'], rack['y'], rack['z']),
            'score': score,
            'breakdown': breakdown
        })
    
    # 4. Sort by score (highest first)
    scored_racks.sort(key=lambda x: x['score'], reverse=True)
    
    # 5. Select best racks based on quantity needed
    # For simplicity, assume 1 unit per rack slot
    # Modify this based on your capacity model
    
    num_slots_needed = min(product_info['quantity'], len(scored_racks))
    selected_racks = scored_racks[:num_slots_needed]
    
    # 6. Calculate path from elevator to each rack
    from grok import astar, path_cost  # Import from your existing code
    
    elevator_cell = grid.get(elevator_location)
    if not elevator_cell:
        return None, "Elevator location not found in grid"
    
    assignments = []
    total_distance = 0
    
    for i, rack_assignment in enumerate(selected_racks):
        rack_cell = rack_assignment['rack_cell']
        
        # Calculate path from elevator to rack
        path = astar(elevator_cell, rack_cell, grid)
        
        if not path:
            continue  # Skip if no path found
        
        distance = path_cost(path)
        total_distance += distance
        
        assignments.append({
            'assignment_order': i + 1,
            'rack_location': rack_assignment['location'],
            'rack_level': rack_assignment['breakdown']['rack_level'],
            'distance_to_expedition': rack_assignment['breakdown']['distance_meters'],
            'optimization_score': rack_assignment['score'],
            'score_breakdown': rack_assignment['breakdown'],
            'path_from_elevator': path,
            'path_distance': distance
        })
    
    if not assignments:
        return None, "Could not find paths from elevator to any rack"
    
    # 7. Return comprehensive assignment result
    result = {
        'product_id': product_id,
        'quantity_requested': product_info['quantity'],
        'quantity_assigned': len(assignments),
        'assignments': assignments,
        'total_travel_distance': total_distance,
        'average_distance_per_slot': total_distance / len(assignments) if assignments else 0,
        'product_characteristics': {
            'weight': product_info['weight'],
            'frequency': product_info['frequency']
        }
    }
    
    return result, None


# ======================================
# MULTI-PRODUCT BATCH ASSIGNMENT
# ======================================

def batch_assign_products(products_dict, grid, elevator_location):
    """
    Assign multiple products to racks in priority order.
    
    Args:
        products_dict: {product_id: {quantity, weight, frequency}}
        grid: warehouse grid
        elevator_location: (x, y, floor)
    
    Returns:
        dict of all assignments
    """
    
    # Priority: High frequency products get first pick of best racks
    sorted_products = sorted(
        products_dict.items(),
        key=lambda x: x[1]['frequency'],
        reverse=True
    )
    
    all_assignments = {}
    occupied_slots = set()  # Track assigned slots
    
    for product_id, product_info in sorted_products:
        
        # Temporarily mark occupied slots
        temp_grid = {k: v.copy() for k, v in grid.items()}
        for occupied_loc in occupied_slots:
            if occupied_loc in temp_grid:
                temp_grid[occupied_loc]['is_occupied'] = True
        
        # Assign product
        result, error = assign_product_to_rack(
            product_id, 
            product_info, 
            temp_grid, 
            elevator_location
        )
        
        if error:
            print(f"  ⚠ {product_id}: {error}")
            continue
        
        # Mark newly assigned slots as occupied
        for assignment in result['assignments']:
            rack_loc = assignment['rack_location']
            occupied_slots.add((rack_loc[0], rack_loc[1], rack_loc[2]))
        
        all_assignments[product_id] = result
    
    return all_assignments


# ======================================
# PRINT ASSIGNMENT RESULTS
# ======================================

def print_assignment_result(product_id, result):
    """Pretty print assignment results"""
    
    print(f"\n{'='*70}")
    print(f"  RACK ASSIGNMENT: {product_id}")
    print(f"{'='*70}")
    print(f"  Requested Quantity : {result['quantity_requested']}")
    print(f"  Assigned Slots     : {result['quantity_assigned']}")
    print(f"  Total Distance     : {result['total_travel_distance']:.2f}m")
    print(f"  Avg Distance/Slot  : {result['average_distance_per_slot']:.2f}m")
    print(f"  Product Weight     : {result['product_characteristics']['weight']} kg")
    print(f"  Product Frequency  : {result['product_characteristics']['frequency']} picks/day")
    print(f"\n  SLOT ASSIGNMENTS:")
    
    for a in result['assignments']:
        print(f"\n    Slot #{a['assignment_order']}:")
        print(f"      Location       : {a['rack_location']} (Level {a['rack_level']})")
        print(f"      Distance→Exped : {a['distance_to_expedition']:.2f}m")
        print(f"      Path Distance  : {a['path_distance']:.2f}m")
        print(f"      Optim. Score   : {a['optimization_score']:.3f}")
        print(f"      Score Details  :")
        breakdown = a['score_breakdown']
        print(f"        - Distance Score  : {breakdown['distance_score']:.3f}")
        print(f"        - Weight Score    : {breakdown['weight_score']:.3f}")
        print(f"        - Frequency Score : {breakdown['frequency_score']:.3f}")


# ======================================
# EXAMPLE USAGE
# ======================================

if __name__ == "__main__":
    
    # Load grid
    with open("grid0.json", encoding="utf-8") as f:
        data = json.load(f)
    
    cells = data["cells"]
    grid = {(cell["x"], cell["y"], cell["floor"]): cell for cell in cells}
    
    print(f"Grid loaded: {len(grid)} cells")
    
    # Find ground floor elevator
    elevators = [c for c in grid.values() if c.get("is_elevator", False)]
    ground_elevators = [e for e in elevators if e["floor"] == 0]
    
    if not ground_elevators:
        print("ERROR: No elevator found on ground floor")
        exit(1)
    
    elevator_location = (ground_elevators[0]['x'], ground_elevators[0]['y'], ground_elevators[0]['floor'])
    print(f"Ground floor elevator at: {elevator_location}")
    
    # Define products to assign (after arriving from upper floors)
    # These would come from your grok.py picking optimization output
    products_to_assign = {
        "31798": {
            "quantity": 5,  # Number of rack slots needed
            "weight": 25,   # kg
            "frequency": 80  # picks per day
        },
        "31858": {
            "quantity": 3,
            "weight": 45,
            "frequency": 30
        },
        "31860": {
            "quantity": 4,
            "weight": 15,
            "frequency": 95
        }
    }
    
    # Batch assign all products
    print("\n" + "="*70)
    print("  BATCH RACK ASSIGNMENT OPTIMIZATION")
    print("="*70)
    
    all_assignments = batch_assign_products(products_to_assign, grid, elevator_location)
    
    # Print results for each product
    for product_id, result in all_assignments.items():
        print_assignment_result(product_id, result)
    
    # Summary statistics
    print(f"\n{'='*70}")
    print(f"  SUMMARY")
    print(f"{'='*70}")
    print(f"  Total Products Assigned : {len(all_assignments)}")
    print(f"  Total Rack Slots Used   : {sum(r['quantity_assigned'] for r in all_assignments.values())}")
    print(f"  Total Travel Distance   : {sum(r['total_travel_distance'] for r in all_assignments.values()):.2f}m")
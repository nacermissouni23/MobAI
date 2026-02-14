"""
MASTER WORKFLOW - COMPLETE SYSTEM
==================================

This script runs the COMPLETE warehouse workflow:
1. Load grids
2. Run grok.py (pick from storage)
3. Run racks.py (assign to racks)
4. Simulate rack stocking
5. Run expedition.py (deliver orders)

"""

import json
import copy

# Import your algorithms
try:
    from grok import plan_product_route, check_congestion
    from racks import batch_assign_products
    from expedition import optimize_expedition_route, print_expedition_route
except ImportError as e:
    print(f"ERROR: Missing required module: {e}")
    print("Make sure grok.py, rack_assignment_optimizer.py, and expedition.py are in the same directory")
    exit(1)


def load_grids():
    """Load both grid files"""
    print("="*70)
    print("  LOADING WAREHOUSE GRIDS")
    print("="*70)
    
    # Load storage floors
    with open("gridItem.json", encoding="utf-8") as f:
        storage_data = json.load(f)
    storage_cells = storage_data["cells"]
    print(f"✓ Storage grid (floors 1-4): {len(storage_cells)} cells")
    
    # Load ground floor
    with open("grid0.json", encoding="utf-8") as f:
        ground_data = json.load(f)
    ground_cells = ground_data["cells"]
    print(f"✓ Ground grid (floor 0): {len(ground_cells)} cells")
    
    # Create separate grids
    storage_grid = {(c["x"], c["y"], c["floor"]): c for c in storage_cells}
    ground_grid = {(c["x"], c["y"], c["floor"]): c for c in ground_cells}
    
    # Combined grid for grok.py
    all_cells = storage_cells + ground_cells
    combined_grid = {(c["x"], c["y"], c["floor"]): c for c in all_cells}
    
    return combined_grid, storage_grid, ground_grid


def run_preparation_phase(orders, product_metadata, combined_grid):
    """
    Phase 1+2: Pick from storage and assign to racks
    """
    print("\n" + "="*70)
    print("  PREPARATION PHASE (Steps 1 & 2)")
    print("="*70)
    
    elevators = [c for c in combined_grid.values() if c.get("is_elevator", False)]
    
    # STEP 1: Multi-floor picking (grok.py)
    print("\n┌─ STEP 1: PICKING FROM STORAGE FLOORS")
    print("└" + "─"*68)
    
    start_floor = 1
    start_candidates = [e for e in elevators if e["floor"] == start_floor]
    if not start_candidates:
        print(f"ERROR: No elevator on floor {start_floor}")
        return None
    
    start = start_candidates[0]
    
    phase1_routes = {}
    products_collected = {}
    
    for chariot_id, (product_id, quantity) in orders.items():
        print(f"\n  Planning route for {chariot_id}: {product_id} x{quantity}")
        
        route, error = plan_product_route(product_id, quantity, start, elevators, combined_grid)
        
        if error:
            print(f"  ✗ ERROR: {error}")
            continue
        
        phase1_routes[chariot_id] = route
        products_collected[product_id] = quantity
        
        if route["mode"] == "single":
            print(f"  ✓ Single-slot route | Cost: {route['total_cost']:.2f}")
        else:
            print(f"  ✓ Multi-slot route | Stops: {route['total_stops']} | Cost: {route['total_cost']:.2f}")
    
    if len(phase1_routes) > 1:
        print("\n  Checking for path conflicts...")
        check_congestion(phase1_routes)
    
    print(f"\n  ✓ Phase 1 Complete: {len(products_collected)} products collected")
    
    # STEP 2: Rack assignment (racks.py)
    print("\n┌─ STEP 2: ASSIGNING TO GROUND FLOOR RACKS")
    print("└" + "─"*68)
    
    ground_elevators = [e for e in elevators if e["floor"] == 0]
    if not ground_elevators:
        print("ERROR: No elevator on ground floor")
        return None
    
    elevator_location = (ground_elevators[0]['x'], ground_elevators[0]['y'], ground_elevators[0]['floor'])
    
    # Prepare for rack assignment
    products_to_assign = {}
    for product_id, quantity in products_collected.items():
        metadata = product_metadata.get(product_id, {"weight": 20, "frequency": 50})
        products_to_assign[product_id] = {
            "quantity": min(quantity // 40, 10),
            "weight": metadata["weight"],
            "frequency": metadata["frequency"]
        }
    
    rack_assignments = batch_assign_products(products_to_assign, combined_grid, elevator_location)
    
    print(f"\n  ✓ Phase 2 Complete: {len(rack_assignments)} products assigned to racks")
    
    return {
        'phase1': phase1_routes,
        'phase2': rack_assignments,
        'products_collected': products_collected
    }


def update_ground_grid_with_assignments(ground_grid, rack_assignments):
    """
    Update the ground floor grid with product assignments
    """
    print("\n" + "="*70)
    print("  UPDATING GRID WITH RACK ASSIGNMENTS")
    print("="*70)
    
    products_placed = 0
    
    for product_id, assignment in rack_assignments.items():
        for slot_assignment in assignment['assignments']:
            rack_loc = slot_assignment['rack_location']
            
            # Find the cell
            cell_key = (rack_loc[0], rack_loc[1], 0)
            
            if cell_key in ground_grid:
                ground_grid[cell_key]['product_id'] = product_id
                ground_grid[cell_key]['quantity'] = 1  # 1 unit per slot
                ground_grid[cell_key]['is_occupied'] = True
                products_placed += 1
    
    print(f"  ✓ Updated {products_placed} rack slots with products")
    
    return ground_grid


def run_delivery_phase(delivery_orders, updated_ground_grid):
    """
    Phase 3: Pick from racks and deliver to expedition
    """
    print("\n" + "="*70)
    print("  DELIVERY PHASE (Step 3)")
    print("="*70)
    
    all_deliveries = {}
    
    for order_id, items in delivery_orders.items():
        print(f"\n┌─ PROCESSING DELIVERY ORDER: {order_id}")
        print("└" + "─"*68)
        
        result, error = optimize_expedition_route(items, updated_ground_grid)
        
        if error:
            print(f"  ✗ ERROR: {error}")
            continue
        
        all_deliveries[order_id] = result
        print_expedition_route(result)
    
    return all_deliveries


def main():
    """
    Complete workflow execution
    """
    print("\n" + "="*70)
    print("  MOBAI WAREHOUSE - COMPLETE WORKFLOW")
    print("="*70)
    
    # Load grids
    combined_grid, storage_grid, ground_grid = load_grids()
    
    # Define preparation orders (forecasting output)
    preparation_orders = {
        "Chariot_A": ("31798", 200),
        "Chariot_B": ("31858", 50),
        "Chariot_C": ("31860", 40),
    }
    
    # Product metadata
    product_metadata = {
        "31798": {"weight": 25, "frequency": 80},
        "31858": {"weight": 45, "frequency": 30},
        "31860": {"weight": 15, "frequency": 95},
    }
    
    # PREPARATION PHASE (Steps 1 & 2)
    prep_result = run_preparation_phase(preparation_orders, product_metadata, combined_grid)
    
    if not prep_result:
        print("\n✗ Preparation phase failed")
        return
    
    # Update ground grid with rack assignments
    updated_ground_grid = update_ground_grid_with_assignments(
        ground_grid, 
        prep_result['phase2']
    )
    
    # Simulate some time passing...
    print("\n" + "="*70)
    print("  ⏰ PRODUCTS NOW IN RACKS - WAITING FOR DELIVERY ORDERS...")
    print("="*70)
    
    # DELIVERY PHASE (Step 3)
    # Customer orders arrive
    delivery_orders = {
        "ORDER_001": {
            "31798": 3,  # Need 3 units
            "31860": 5   # Need 5 units
        },
        "ORDER_002": {
            "31858": 2,  # Need 2 units
            "31860": 2   # Need 2 units
        }
    }
    
    delivery_results = run_delivery_phase(delivery_orders, updated_ground_grid)
    
    # Final summary
    print("\n" + "="*70)
    print("  COMPLETE WORKFLOW SUMMARY")
    print("="*70)
    
    print("\n  PREPARATION PHASE:")
    print(f"    Products collected: {len(prep_result['products_collected'])}")
    print(f"    Rack slots used: {sum(a['quantity_assigned'] for a in prep_result['phase2'].values())}")
    
    print("\n  DELIVERY PHASE:")
    print(f"    Orders processed: {len(delivery_results)}")
    print(f"    Total delivery distance: {sum(d['total_distance'] for d in delivery_results.values()):.2f}m")
    
    print("\n  ✓ WORKFLOW COMPLETE - ALL ORDERS DELIVERED\n")


if __name__ == "__main__":
    main()
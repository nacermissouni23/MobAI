"""
AI Utility Functions
Place in: app/ai/utils.py
"""

import json
from typing import Dict, List
from pathlib import Path

def load_warehouse_grids() -> Dict:
    """Load all warehouse grid files"""
    backend_root = Path(__file__).parent.parent.parent
    
    grid_storage_path = backend_root / "gridItem.json"
    grid_ground_path = backend_root / "grid0.json"
    
    with open(grid_storage_path, encoding="utf-8") as f:
        storage_data = json.load(f)
    storage_cells = storage_data["cells"]
    
    with open(grid_ground_path, encoding="utf-8") as f:
        ground_data = json.load(f)
    ground_cells = ground_data["cells"]
    
    all_cells = storage_cells + ground_cells
    combined_grid = {(c["x"], c["y"], c["floor"]): c for c in all_cells}
    storage_grid = {(c["x"], c["y"], c["floor"]): c for c in storage_cells}
    ground_grid = {(c["x"], c["y"], c["floor"]): c for c in ground_cells}
    
    return {
        'combined': combined_grid,
        'storage': storage_grid,
        'ground': ground_grid
    }

def find_elevators(grid: Dict) -> List[Dict]:
    """Find all elevators in the grid"""
    return [cell for cell in grid.values() if cell.get("is_elevator", False)]
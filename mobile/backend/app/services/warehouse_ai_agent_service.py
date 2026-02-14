"""
Warehouse AI Agent Service - Fixed File Paths
=============================================

Place in: app/services/warehouse_ai_agent_service.py

Fixed: Correct paths for grid files and forecast script
"""

import subprocess
import csv
import json
import os
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from pathlib import Path

# Import AI modules
from app.ai.storage_optimizer import StorageOptimizer

class WarehouseAIAgent:
    """
    Main AI Agent - Coordinates all warehouse operations
    
    Fixed: Uses correct file paths relative to backend root
    """
    
    def __init__(self):
        """
        Initialize the AI Agent
        """
        print("🤖 Initializing Warehouse AI Agent...")
        
        # Get backend root directory (where main.py is)
        self.backend_root = Path(__file__).parent.parent.parent
        
        # Define file paths
        self.grid_storage_path = self.backend_root / "gridItem.json"
        self.grid_ground_path = self.backend_root / "grid0.json"
        self.forecast_script_path = self.backend_root / "run_forecast.py"
        self.forecast_input_path = self.backend_root / "historique_demande.csv"
        
        print(f"   Backend root: {self.backend_root}")
        print(f"   Grid storage: {self.grid_storage_path}")
        print(f"   Grid ground: {self.grid_ground_path}")
        
        # Load warehouse grids
        try:
            self.grids = self._load_warehouse_grids()
            self.combined_grid = self.grids['combined']
            self.ground_grid = self.grids['ground']
            self.storage_grid = self.grids['storage']
            self.elevators = self._find_elevators(self.combined_grid)
            print(f"   ✅ Grid loaded: {len(self.combined_grid)} cells")
            print(f"   ✅ Elevators: {len(self.elevators)}")
        except Exception as e:
            print(f"   ⚠️  Grid loading failed: {e}")
            self.combined_grid = {}
            self.elevators = []
        
        # Initialize YOUR storage optimizer
        try:
            # Your optimizer needs: grid_file, receiving_point, slots_from_db
            self.storage_optimizer = StorageOptimizer(
                grid_file=str(self.grid_storage_path),  # Use absolute path
                receiving_point=(10, 30, 1),
                slots_from_db=None
            )
            print(f"   ✅ Storage optimizer initialized")
        except Exception as e:
            print(f"   ⚠️  Storage optimizer failed: {e}")
            self.storage_optimizer = None
        
        # Decision tracking
        self.decision_history = []
        
        print("✅ Warehouse AI Agent ready")
    
    def _load_warehouse_grids(self) -> Dict:
        """Load warehouse grid files"""
        
        # Check if files exist
        if not self.grid_storage_path.exists():
            raise FileNotFoundError(
                f"Storage grid file not found at: {self.grid_storage_path}\n"
                f"Please place gridItem.json in the backend root directory"
            )
        
        if not self.grid_ground_path.exists():
            raise FileNotFoundError(
                f"Ground grid file not found at: {self.grid_ground_path}\n"
                f"Please place grid0.json in the backend root directory"
            )
        
        try:
            # Load storage floors (1-4)
            with open(self.grid_storage_path, encoding="utf-8") as f:
                storage_data = json.load(f)
            storage_cells = storage_data["cells"]
            
            # Load ground floor (0)
            with open(self.grid_ground_path, encoding="utf-8") as f:
                ground_data = json.load(f)
            ground_cells = ground_data["cells"]
            
            # Create grid dictionaries
            all_cells = storage_cells + ground_cells
            combined_grid = {(c["x"], c["y"], c["floor"]): c for c in all_cells}
            storage_grid = {(c["x"], c["y"], c["floor"]): c for c in storage_cells}
            ground_grid = {(c["x"], c["y"], c["floor"]): c for c in ground_cells}
            
            return {
                'combined': combined_grid,
                'storage': storage_grid,
                'ground': ground_grid
            }
        except Exception as e:
            raise Exception(f"Failed to load grid files: {e}")
    
    def _find_elevators(self, grid: Dict) -> List[Dict]:
        """Find all elevators in the grid"""
        return [cell for cell in grid.values() if cell.get("is_elevator", False)]
    
    # ============= 1. RECEIPT WORKFLOW =============
    
    async def handle_receipt(self, product_id: str, quantity_palettes: int, product_data: Optional[Dict] = None) -> Dict:
        """
        Handle product receipt - decide where to store
        """
        if not self.storage_optimizer:
            raise Exception("Storage optimizer not initialized")
        
        # Prepare product data for YOUR optimizer
        if product_data is None:
            product_data = {
                'poids': 10,
                'volume': 0.01,
                'fragile': False,
                'frequence': 2
            }
        
        products_to_store = [{
            'id': product_id,
            'poids': product_data.get('poids', 10),
            'volume': product_data.get('volume', 0.01),
            'fragile': product_data.get('fragile', False),
            'quantite': quantity_palettes,
            'frequence': product_data.get('frequence', 2)
        }]
        
        try:
            assignments = self.storage_optimizer.assign_storage(products_to_store)
            
            if not assignments:
                raise Exception("No storage locations available")
            
            best = assignments[0]
            
            decision = {
                'decision_id': f"STORAGE-{datetime.now().strftime('%Y%m%d%H%M%S')}",
                'product_id': product_id,
                'quantity_palettes': quantity_palettes,
                'recommended_location': {
                    'x': best['slot'][0],
                    'y': best['slot'][1],
                    'floor': best['slot'][2]
                },
                'path': best['path'],
                'path_cost': best['path_cost'],
                'quantity_assigned': best['quantite'],
                'alternatives': [
                    {
                        'x': a['slot'][0],
                        'y': a['slot'][1],
                        'floor': a['slot'][2],
                        'quantity': a['quantite'],
                        'cost': a['path_cost']
                    }
                    for a in assignments[1:3]
                ] if len(assignments) > 1 else [],
                'reasoning': f"Optimal location on floor {best['slot'][2]} with path cost {best['path_cost']:.2f}",
                'confidence': 0.85,
                'ai_generated': True,
                'timestamp': datetime.now().isoformat()
            }
            
            self.decision_history.append(decision)
            return decision
            
        except Exception as e:
            raise Exception(f"Storage optimization failed: {str(e)}")
    
    # ============= 2. FORECASTING WORKFLOW =============
    
    async def run_daily_forecast(self, target_date: Optional[str] = None) -> Dict:
        """
        Run daily demand forecasting using YOUR Hurdle Model
        """
        if not target_date:
            target_date = (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%d')
        
        print(f"🤖 Running forecast for {target_date}...")
        
        # Check if forecast script exists
        if not self.forecast_script_path.exists():
            raise FileNotFoundError(
                f"Forecast script not found at: {self.forecast_script_path}\n"
                f"Please place run_forecast.py in the backend root directory"
            )
        
        # Check if input file exists
        if not self.forecast_input_path.exists():
            raise FileNotFoundError(
                f"Historical data not found at: {self.forecast_input_path}\n"
                f"Please place historique_demande.csv in the backend root directory"
            )
        
        # Prepare paths
        temp_input_path = self.backend_root / "temp_forecast_input.csv"
        output_path = self.backend_root / f"forecast_{datetime.now().strftime('%Y%m%d%H%M%S')}.csv"
        
        # Copy input file
        import shutil
        shutil.copy(str(self.forecast_input_path), str(temp_input_path))
        
        # Run forecast script
        cmd = [
            "python",
            str(self.forecast_script_path),
            str(temp_input_path),
            str(output_path)
        ]
        
        print(f"   Running: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300,
                cwd=str(self.backend_root)  # Run in backend root directory
            )
            
            if result.returncode != 0:
                raise Exception(f"Forecast script failed:\nSTDOUT: {result.stdout}\nSTDERR: {result.stderr}")
            
            # Read results
            if not output_path.exists():
                raise Exception(f"Forecast output file not created at: {output_path}")
            
            predictions = []
            with open(output_path, newline='', encoding='utf-8') as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    predictions.append({
                        'product_id': str(row['product_id']),
                        'predicted_quantity': int(row['quantity']),
                        'order_date': row['order_date'],
                        'confidence': 0.8,
                        'source': row['source'],
                        'status': row.get('status', 'to_validate')
                    })
            
            decision = {
                'forecast_id': f"FORECAST-{datetime.now().strftime('%Y%m%d%H%M%S')}",
                'target_date': target_date,
                'method': 'Hurdle_RandomForest',
                'predictions': predictions,
                'total_predicted_quantity': sum(p['predicted_quantity'] for p in predictions),
                'ai_generated': True,
                'timestamp': datetime.now().isoformat()
            }
            
            self.decision_history.append(decision)
            
            # Clean up temp files
            if temp_input_path.exists():
                temp_input_path.unlink()
            
            print(f"   ✅ Forecast complete: {len(predictions)} products predicted")
            
            return decision
            
        except subprocess.TimeoutExpired:
            raise Exception("Forecast timeout (>5 minutes)")
        except Exception as e:
            raise Exception(f"Forecasting failed: {str(e)}")
    
    # ============= HELPER METHODS =============
    
    def get_decision_history(self, limit: int = 10) -> List[Dict]:
        """Get recent AI decisions"""
        return self.decision_history[-limit:]
    
    async def handle_override(
        self,
        decision_id: str,
        overridden_by: str,
        override_reason: str,
        new_decision: Dict
    ) -> Dict:
        """Handle supervisor/admin override of AI decision"""
        override = {
            'override_id': f"OVERRIDE-{datetime.now().strftime('%Y%m%d%H%M%S')}",
            'decision_id': decision_id,
            'overridden_by': overridden_by,
            'override_reason': override_reason,
            'new_decision': new_decision,
            'timestamp': datetime.now().isoformat()
        }
        
        return override


# ============= SINGLETON INSTANCE =============

_agent_instance: Optional[WarehouseAIAgent] = None

def get_ai_agent() -> WarehouseAIAgent:
    """
    Get or create the global AI agent instance
    """
    global _agent_instance
    
    if _agent_instance is None:
        _agent_instance = WarehouseAIAgent()
    
    return _agent_instance

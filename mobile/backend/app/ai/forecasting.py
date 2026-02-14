"""
AI-powered demand forecasting for warehouse preparation orders.

Uses historical data and demand frequency to predict upcoming preparation needs.
"""

from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

import numpy as np

from app.config.settings import settings
from app.repositories.product_repository import ProductRepository
from app.repositories.stock_ledger_repository import StockLedgerRepository
from app.repositories.emplacement_repository import EmplacementRepository
from app.utils.logger import logger


class ForecastingEngine:
    """
    Predicts preparation orders based on historical stock movements
    and product demand frequency.
    """

    def __init__(self):
        self.product_repo = ProductRepository()
        self.ledger_repo = StockLedgerRepository()
        self.emplacement_repo = EmplacementRepository()

    async def predict_preparation_orders(
        self,
        days: int = None,
        min_demand_frequency: float = 0.5,
    ) -> List[Dict[str, Any]]:
        """
        Predict which products need preparation orders.

        Algorithm:
        1. Get all active products with demand_frequency >= threshold
        2. Analyse historical consumption from stock ledger (last N days)
        3. Estimate daily consumption rate
        4. Compare with current stock levels
        5. Generate order lines for products with predicted shortfall

        Args:
            days: Number of historical days to analyze.
            min_demand_frequency: Minimum demand_frequency to consider.

        Returns:
            List of dicts with product_id, sku, product_name, predicted_quantity,
            current_stock, daily_consumption_rate, days_until_stockout.
        """
        if days is None:
            days = settings.FORECASTING_DAYS

        logger.info(f"Running forecasting: {days} days lookback, min_freq={min_demand_frequency}")

        # Step 1: Get high-demand products
        all_products = await self.product_repo.get_all()
        products = [
            p for p in all_products
            if p.get("actif", True) and p.get("demand_freq", 0) >= min_demand_frequency
        ]

        if not products:
            logger.info("No products meet forecasting criteria")
            return []

        cutoff_date = (datetime.utcnow() - timedelta(days=days)).isoformat()
        predictions = []

        for product in products:
            product_id = product["id"]

            # Step 2: Get historical outbound movements (negative quantities)
            ledger_entries = await self.ledger_repo.get_by_product(product_id, limit=500)

            # Filter to recent entries
            recent_outbound = []
            for entry in ledger_entries:
                recorded = entry.get("recorded_at", "")
                qty = entry.get("quantity", 0)
                if recorded >= cutoff_date and qty < 0:
                    recent_outbound.append(abs(qty))

            # Step 3: Calculate daily consumption rate
            total_consumed = sum(recent_outbound) if recent_outbound else 0
            daily_rate = total_consumed / max(days, 1)

            # Apply demand_freq as a weight
            demand_freq = product.get("demand_freq", 1.0)
            weighted_rate = daily_rate * (1 + demand_freq * 0.1)

            # Step 4: Get current stock
            current_stock = await self._get_product_stock(product_id)

            # Step 5: Predict shortfall
            if weighted_rate > 0:
                days_until_stockout = current_stock / weighted_rate
            else:
                days_until_stockout = float("inf")

            # Generate order if stockout predicted within forecast window
            if days_until_stockout < days:
                predicted_qty = max(
                    int(np.ceil(weighted_rate * days - current_stock)),
                    1,
                )
                predictions.append({
                    "product_id": product_id,
                    "sku": product.get("sku"),
                    "product_name": product.get("nom_produit"),
                    "predicted_quantity": predicted_qty,
                    "current_stock": current_stock,
                    "daily_consumption_rate": round(weighted_rate, 2),
                    "days_until_stockout": round(days_until_stockout, 1),
                })

        # Sort by urgency (lowest days_until_stockout first)
        predictions.sort(key=lambda x: x["days_until_stockout"])
        logger.info(f"Forecasting complete: {len(predictions)} products need preparation")
        return predictions

    async def _get_product_stock(self, product_id: str) -> int:
        """Get total stock for a product across all emplacement locations."""
        locations = await self.emplacement_repo.get_product_locations(product_id)
        return sum(loc.get("quantity", 0) for loc in locations)


# Module-level singleton
forecasting_engine = ForecastingEngine()

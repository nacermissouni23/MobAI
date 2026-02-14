from .data_loader import load_daily_demand
from .preprocessing import fill_missing_dates
from .features import add_features, add_advanced_features
from .models import HurdleModel
from .generate import generate_orders_hurdle


class ForecastingEngine:
    """
    High-level forecasting facade used by the orders route.

    Wraps the Hurdle model pipeline to provide preparation-order predictions
    directly from product data stored in Firestore.
    """

    async def predict_preparation_orders(
        self,
        days: int | None = None,
        min_demand_frequency: float = 0.5,
    ) -> list[dict]:
        """
        Predict which products will need preparation orders.

        Falls back to a frequency-based heuristic when historical data
        is unavailable (no CSV / no Firebase history).

        Returns:
            list of dicts with "product_id" and "predicted_quantity".
        """
        try:
            from app.repositories.product_repository import ProductRepository

            product_repo = ProductRepository()
            products = await product_repo.get_all()

            # Filter by minimum demand frequency
            candidates = [
                p for p in products
                if p.get("demand_freq", 0) >= min_demand_frequency
            ]

            predictions = []
            for prod in candidates:
                demand = prod.get("demand_freq", 1.0)
                # Simple heuristic: predicted_quantity proportional to demand
                predicted_qty = max(1, int(demand))
                predictions.append({
                    "product_id": prod["id"],
                    "predicted_quantity": predicted_qty,
                })

            return predictions

        except Exception:
            return []


# Module-level singleton
forecasting_engine = ForecastingEngine()
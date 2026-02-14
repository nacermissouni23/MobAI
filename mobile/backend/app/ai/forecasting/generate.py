import numpy as np
import pandas as pd
from .features import FEATURE_COLS, add_features, add_advanced_features
from .models import HurdleModel

def generate_orders_hurdle(daily_full: pd.DataFrame, cap_quantile: float = 0.99) -> pd.DataFrame:
    """
    Entraîne le modèle Hurdle sur tout l'historique et génère les ordres pour le lendemain.
    Applique un plafonnement optionnel par le 99e percentile de chaque produit.
    """
    # Ajout des features
    daily_feat = add_features(daily_full)
    daily_feat = add_advanced_features(daily_feat)
    daily_feat = daily_feat.dropna(subset=['lag_1']).copy()

    if len(daily_feat) == 0:
        return pd.DataFrame()

    # Features disponibles (les colonnes effectivement présentes)
    base_features = FEATURE_COLS + ['prop_demand_7', 'prop_demand_30', 'avg_quantity_7', 'avg_quantity_30',
                                     'week_sin', 'week_cos', 'ewma_7']
    available = [f for f in base_features if f in daily_feat.columns]

    X_all = daily_feat[available]
    y_all = daily_feat['quantity']

    # Entraînement du modèle Hurdle
    model = HurdleModel()
    model.fit(X_all, y_all)

    # Dernière date disponible
    last_date = daily_full['date'].max()
    forecast_date = last_date + pd.Timedelta(days=1)

    # Lignes correspondant à cette dernière date
    last_rows = daily_feat[daily_feat['date'] == last_date]
    if len(last_rows) == 0:
        return pd.DataFrame()

    X_last = last_rows[available]
    preds = model.predict(X_last)

    # Plafonnement par le 99e percentile de chaque produit
    caps = daily_full.groupby('product_id')['quantity'].quantile(cap_quantile)
    caps_aligned = last_rows['product_id'].map(caps).fillna(caps.max()).values
    preds = np.minimum(preds, caps_aligned)

    # Construction du DataFrame des ordres
    orders = pd.DataFrame({
        'product_id': last_rows['product_id'].values,
        'quantity': np.maximum(0, np.round(preds)).astype(int),
        'order_date': forecast_date,
        'generated_at': pd.Timestamp.now(),
        'status': 'to_validate',
        'source': 'Hurdle_RF'
    })
    orders = orders[orders['quantity'] > 0].reset_index(drop=True)
    return orders
import numpy as np
import pandas as pd

FEATURE_COLS = [
    'lag_1', 'lag_2', 'lag_3', 'lag_7', 'lag_14', 'lag_28',
    'rolling_mean_7', 'rolling_mean_28',
    'dayofweek', 'month', 'quarter', 'product_enc'
]

def add_features(df: pd.DataFrame) -> pd.DataFrame:
    """Ajoute les features de base (lags, rolling means, variables calendaires)."""
    df = df.copy()
    df = df.sort_values(['product_id', 'date'])
    for lag in [1, 2, 3, 7, 14, 28]:
        df[f'lag_{lag}'] = df.groupby('product_id')['quantity'].shift(lag)
    df['rolling_mean_7'] = df.groupby('product_id')['quantity'].transform(
        lambda x: x.rolling(7, min_periods=1).mean().shift(1)
    )
    df['rolling_mean_28'] = df.groupby('product_id')['quantity'].transform(
        lambda x: x.rolling(28, min_periods=1).mean().shift(1)
    )
    df['dayofweek'] = df['date'].dt.dayofweek
    df['month'] = df['date'].dt.month
    df['quarter'] = df['date'].dt.quarter
    df['product_enc'] = df['product_id'].astype('category').cat.codes
    return df

def add_advanced_features(df: pd.DataFrame) -> pd.DataFrame:
    """Ajoute des features spécifiques à l'intermittence."""
    df = df.copy()
    df = df.sort_values(['product_id', 'date'])

    # Indicateur binaire de demande
    df['demand_binary'] = (df['quantity'] > 0).astype(int)

    # Proportion de jours avec demande sur 7 et 30 derniers jours
    for window in [7, 30]:
        df[f'prop_demand_{window}'] = df.groupby('product_id')['demand_binary'].transform(
            lambda x: x.rolling(window, min_periods=1).mean().shift(1)
        )

    # Quantité moyenne sur les jours avec demande (fenêtres glissantes)
    for window in [7, 30]:
        df[f'avg_quantity_{window}'] = df.groupby('product_id')['quantity'].transform(
            lambda x: x.where(x > 0).rolling(window, min_periods=1).mean().shift(1)
        )

    # Variables cycliques de semaine
    df['week_of_year'] = df['date'].dt.isocalendar().week
    df['week_sin'] = np.sin(2 * np.pi * df['week_of_year'] / 52)
    df['week_cos'] = np.cos(2 * np.pi * df['week_of_year'] / 52)

    # Moyenne exponentielle (EWMA) sur 7 jours
    df['ewma_7'] = df.groupby('product_id')['quantity'].transform(
        lambda x: x.ewm(span=7, adjust=False).mean().shift(1)
    )

    return df
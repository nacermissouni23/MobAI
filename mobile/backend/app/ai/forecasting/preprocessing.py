import pandas as pd

def fill_missing_dates(df: pd.DataFrame) -> pd.DataFrame:
    """
    Pour chaque produit, ajoute les dates manquantes avec quantity = 0.
    """
    all_dates = pd.date_range(start=df['date'].min(), end=df['date'].max(), freq='D')
    filled = []
    for pid, group in df.groupby('product_id'):
        group = group.set_index('date').reindex(all_dates, fill_value=0)
        group['product_id'] = pid
        group = group.reset_index().rename(columns={'index': 'date'})
        filled.append(group)
    return pd.concat(filled, ignore_index=True)
import pandas as pd

def load_daily_demand(excel_path: str) -> pd.DataFrame:
    """
    Charge les données depuis le fichier Excel fourni par le hackathon.
    Retourne un DataFrame avec colonnes ['date', 'product_id', 'quantity'].
    """
    trans = pd.read_excel(excel_path, sheet_name="transactions", skiprows=[1, 2])
    lignes = pd.read_excel(excel_path, sheet_name="lignes_transaction", skiprows=[1, 2])

    # Conversion de la date
    trans['cree_le'] = pd.to_datetime(trans['cree_le'], errors='coerce')
    trans = trans.dropna(subset=['cree_le'])

    # Garder uniquement les livraisons
    delivery = trans[trans['type_transaction'].str.upper() == 'DELIVERY'].copy()

    # Fusion avec les lignes
    delivery['id_transaction'] = delivery['id_transaction'].astype(str)
    lignes['id_transaction'] = lignes['id_transaction'].astype(str)
    merged = delivery.merge(lignes, on='id_transaction', how='inner')

    # Agrégation quotidienne par produit (id_produit)
    merged['product_id'] = merged['id_produit'].astype(str)
    daily = merged.groupby(
        [pd.Grouper(key='cree_le', freq='D'), 'product_id']
    )['quantite'].sum().reset_index()
    daily.columns = ['date', 'product_id', 'quantity']
    daily = daily.sort_values(['product_id', 'date']).reset_index(drop=True)

    return daily
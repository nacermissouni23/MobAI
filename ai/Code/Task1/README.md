
# Service de Forecasting – Hurdle Model

## Description
Ce module génère quotidiennement les ordres de préparation (Preparation Orders) à partir de l'historique des livraisons clients.

## Modèle utilisé
**Hurdle (deux étapes)** : classifieur RandomForest pour prédire la présence de demande, régresseur RandomForest pour la quantité.
Performances validées :
- WAPE moyen < 0.5 sur 75% des fenêtres de test
- Biais relatif < 5% sur 73% des fenêtres

## Installation 
```bash
pip install -r requirements.txt
```

## Utilisation :  python run_forecast.py <input_data_path> <output_csv_path>

py run_forecast.py WMS_Hackathon_DataPack_Templates_FR_FV_B7_ONLY.xlsx ordres_du_jour.csv  



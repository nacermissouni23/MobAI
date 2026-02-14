#!/usr/bin/env python
import sys
import os
import traceback

def main():
    print("=== Démarrage du service de prévision ===")
    if len(sys.argv) < 3:
        print("Usage: python run_forecast.py <input_data_path> <output_csv_path>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    # Ajout du dossier courant au chemin Python
    sys.path.insert(0, os.path.dirname(__file__))

    try:
        from forecasting.data_loader import load_daily_demand
        from forecasting.preprocessing import fill_missing_dates
        from forecasting.features import add_features, add_advanced_features
        from forecasting.generate import generate_orders_hurdle
        print("✅ Modules importés avec succès.")
    except Exception as e:
        print(f"❌ Erreur d'import : {e}")
        traceback.print_exc()
        sys.exit(1)

    if not os.path.isfile(input_path):
        print(f"❌ Le fichier d'entrée n'existe pas : {input_path}")
        sys.exit(1)

    print(f"📂 Chargement des données depuis : {input_path}")
    try:
        daily_raw = load_daily_demand(input_path)
        print(f"✅ Données brutes : {len(daily_raw)} lignes")
    except Exception as e:
        print(f"❌ Erreur lors du chargement : {e}")
        traceback.print_exc()
        sys.exit(1)

    print("🔧 Ajout des jours sans livraison...")
    daily = fill_missing_dates(daily_raw)
    print(f"✅ Après remplissage : {len(daily)} lignes")

    print("🔧 Création des features...")
    daily = add_features(daily)
    daily = add_advanced_features(daily)
    print("✅ Features ajoutées.")

    print("🤖 Génération des ordres avec le modèle Hurdle...")
    try:
        orders = generate_orders_hurdle(daily)
        print(f"✅ Ordres générés : {len(orders)} lignes")
    except Exception as e:
        print(f"❌ Erreur lors de la génération : {e}")
        traceback.print_exc()
        sys.exit(1)

    print(f"💾 Sauvegarde dans : {output_path}")
    orders.to_csv(output_path, index=False)
    print("✅ Terminé avec succès.")

if __name__ == "__main__":
    main()
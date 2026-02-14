"""
Seed script: reads grid0.json and uploads all cells as emplacement documents to Firestore.

Usage:
    python seed_emplacements.py
"""

import json
import os
import sys

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore import SERVER_TIMESTAMP

# ── Firebase init ────────────────────────────────────────────────
SERVICE_ACCOUNT_PATH = os.path.join(
    os.path.dirname(__file__), "app", "serviceAccountKey.json"
)

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

db = firestore.client()
COLLECTION = "emplacements"

# ── Load grid ────────────────────────────────────────────────────
GRID_PATH = os.path.join(os.path.dirname(__file__), "grid0.json")


def seed():
    with open(GRID_PATH, "r", encoding="utf-8") as f:
        grid = json.load(f)

    cells = grid.get("cells", [])
    print(f"Found {len(cells)} cells in grid0.json")

    # Use batched writes (max 500 per batch)
    batch = db.batch()
    count = 0

    for cell in cells:
        doc_ref = db.collection(COLLECTION).document()

        emplacement = {
            "x": cell.get("x", 0),
            "y": cell.get("y", 0),
            "z": cell.get("z", 0),
            "floor": cell.get("floor", 0),
            "is_obstacle": cell.get("is_obstacle", False),
            "is_slot": cell.get("is_slot", False),
            "is_elevator": cell.get("is_elevator", False),
            "is_road": cell.get("is_road", False),
            "is_expedition": cell.get("is_expedition_zone", False),
            "product_id": cell.get("product_id"),
            "quantity": cell.get("quantity", 0),
            "is_occupied": cell.get("is_occupied", False),
            "created_at": SERVER_TIMESTAMP,
            "updated_at": SERVER_TIMESTAMP,
        }

        batch.set(doc_ref, emplacement)
        count += 1

        # Firestore batch limit is 500
        if count % 500 == 0:
            batch.commit()
            print(f"  Committed {count} documents...")
            batch = db.batch()

    # Commit remaining
    if count % 500 != 0:
        batch.commit()

    print(f"Done! Seeded {count} emplacement documents into '{COLLECTION}' collection.")


if __name__ == "__main__":
    seed()

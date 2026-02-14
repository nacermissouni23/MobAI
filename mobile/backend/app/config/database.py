"""
Database helpers and Firestore utilities.
"""

from app.config.firebase import get_db


def get_collection(collection_name: str):
    """Get a Firestore collection reference."""
    return get_db().collection(collection_name)


def get_document(collection_name: str, document_id: str):
    """Get a single Firestore document reference."""
    return get_db().collection(collection_name).document(document_id)

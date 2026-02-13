"""
Firebase initialization and Firestore client access.
"""

import os
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.client import Client as FirestoreClient

from app.config.settings import settings
from app.utils.logger import logger

_db: FirestoreClient | None = None
_firebase_enabled = False


def initialize_firebase() -> None:
    """Initialize Firebase Admin SDK. Gracefully handles missing credentials."""
    global _db, _firebase_enabled
    
    if not firebase_admin._apps:
        try:
            # Check if credentials file exists
            if not os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                logger.warning(
                    f"Firebase credentials file not found at '{settings.FIREBASE_CREDENTIALS_PATH}'. "
                    "Running in development mode without Firebase. "
                    "Create the credentials file to enable Firestore."
                )
                _firebase_enabled = False
                return
            
            # Check if project ID is configured
            if not settings.FIREBASE_PROJECT_ID:
                logger.warning(
                    "FIREBASE_PROJECT_ID not configured. "
                    "Running without Firebase. Set FIREBASE_PROJECT_ID in .env file."
                )
                _firebase_enabled = False
                return
            
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, {
                "projectId": settings.FIREBASE_PROJECT_ID,
            })
            _db = firestore.client()
            _firebase_enabled = True
            logger.info("Firebase initialized successfully.")
            
        except Exception as e:
            logger.warning(f"Failed to initialize Firebase: {e}. Running without Firebase.")
            _firebase_enabled = False


def get_db() -> FirestoreClient:
    """Return the Firestore client instance."""
    global _db, _firebase_enabled
    
    if not _firebase_enabled:
        from app.core.exceptions import ValidationError
        raise ValidationError(
            "Firebase/Firestore is not configured. Please set up Firebase credentials to use database operations."
        )
    
    if _db is None:
        _db = firestore.client()
    return _db


def is_firebase_enabled() -> bool:
    """Check if Firebase is properly configured and enabled."""
    return _firebase_enabled

"""
Application settings loaded from environment variables.
"""

from typing import List
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application configuration settings."""

    # Application
    APP_NAME: str = "WarehouseAI"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # Firebase
    FIREBASE_CREDENTIALS_PATH: str = "./firebase-credentials.json"
    FIREBASE_PROJECT_ID: str = ""

    # JWT
    JWT_SECRET_KEY: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_MINUTES: int = 480

    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "http://localhost:8000",
        "http://10.0.2.2:8000",
        "http://127.0.0.1:8000",
    ]

    # AI Settings
    FORECASTING_DAYS: int = 30
    LOW_STOCK_THRESHOLD: int = 10

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()

"""
Base model with common fields for all Firestore documents.
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel as PydanticBaseModel, Field


class BaseModel(PydanticBaseModel):
    """Base model providing common Firestore document fields."""

    id: Optional[str] = Field(default=None, description="Firestore document ID")
    created_at: datetime = Field(default_factory=datetime.utcnow, description="Creation timestamp")
    updated_at: datetime = Field(default_factory=datetime.utcnow, description="Last update timestamp")

    class Config:
        from_attributes = True
        populate_by_name = True

    def to_firestore(self) -> dict:
        """Convert model to a dict suitable for Firestore storage."""
        data = self.model_dump(exclude={"id"})
        # Convert datetime objects to ISO strings for Firestore
        for key, value in data.items():
            if isinstance(value, datetime):
                data[key] = value.isoformat()
        return data

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "BaseModel":
        """Create a model instance from Firestore document data."""
        data["id"] = doc_id
        return cls(**data)

"""
Chariot schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel


class ChariotCreate(BaseModel):
    """Schema for creating a chariot."""
    is_active: bool = True


class ChariotUpdate(BaseModel):
    """Schema for updating a chariot."""
    is_active: Optional[bool] = None


class ChariotResponse(BaseModel):
    """Schema for chariot response."""
    id: str
    is_active: bool
    assigned_to_operation_id: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

"""
Chariot schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field


class ChariotCreate(BaseModel):
    """Schema for creating a chariot."""
    code: str = Field(..., min_length=1)
    is_active: bool = True
    current_x: int = Field(default=0, ge=0)
    current_y: int = Field(default=0, ge=0)
    current_z: int = Field(default=0, ge=0)
    current_floor: int = Field(default=0, ge=0)


class ChariotUpdate(BaseModel):
    """Schema for updating a chariot."""
    code: Optional[str] = Field(default=None, min_length=1)
    is_active: Optional[bool] = None
    current_x: Optional[int] = Field(default=None, ge=0)
    current_y: Optional[int] = Field(default=None, ge=0)
    current_z: Optional[int] = Field(default=None, ge=0)
    current_floor: Optional[int] = Field(default=None, ge=0)
    assigned_to_operation: Optional[str] = None


class ChariotResponse(BaseModel):
    """Schema for chariot response."""
    id: str
    code: str
    is_active: bool
    current_x: int
    current_y: int
    current_z: int
    current_floor: int
    assigned_to_operation: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

"""
Emplacement schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field


class EmplacementCreate(BaseModel):
    """Schema for creating an emplacement."""
    x: int = Field(..., ge=0)
    y: int = Field(..., ge=0)
    z: int = Field(default=0, ge=0)
    floor: int = Field(default=0, ge=0)
    is_obstacle: bool = False
    is_slot: bool = False
    is_elevator: bool = False
    is_road: bool = False
    is_expedition: bool = False
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    is_occupied: bool = False


class EmplacementUpdate(BaseModel):
    """Schema for updating an emplacement."""
    is_obstacle: Optional[bool] = None
    is_slot: Optional[bool] = None
    is_elevator: Optional[bool] = None
    is_road: Optional[bool] = None
    is_expedition: Optional[bool] = None
    product_id: Optional[str] = None
    quantity: Optional[int] = Field(default=None, ge=0)
    is_occupied: Optional[bool] = None


class EmplacementResponse(BaseModel):
    """Schema for emplacement response."""
    id: str
    x: int
    y: int
    z: int
    floor: int
    is_obstacle: bool
    is_slot: bool
    is_elevator: bool
    is_road: bool
    is_expedition: bool
    product_id: Optional[str] = None
    quantity: int
    is_occupied: bool
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

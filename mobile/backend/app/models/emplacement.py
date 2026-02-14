"""
Emplacement model representing storage grid cells / locations.
"""

from typing import Optional
from pydantic import Field

from app.models.base import BaseModel


class Emplacement(BaseModel):
    """Represents a single emplacement grid cell / storage location."""

    x: int = Field(..., ge=0, description="X coordinate")
    y: int = Field(..., ge=0, description="Y coordinate")
    z: int = Field(default=0, ge=0, description="Z coordinate (shelf level)")
    floor: int = Field(default=0, ge=0, description="Floor number")
    is_obstacle: bool = Field(default=False, description="Cell is an obstacle")
    is_slot: bool = Field(default=False, description="Cell is a storage slot")
    is_elevator: bool = Field(default=False, description="Cell is an elevator")
    is_road: bool = Field(default=False, description="Cell is a road / aisle")
    is_expedition: bool = Field(default=False, description="Cell is an expedition zone")
    product_id: Optional[str] = Field(default=None, description="Stored product ID")
    quantity: int = Field(default=0, ge=0, description="Quantity stored")
    is_occupied: bool = Field(default=False, description="Whether slot is occupied")

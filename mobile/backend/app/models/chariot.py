"""
Chariot (forklift / transport vehicle) model.
"""

from typing import Optional
from pydantic import Field

from app.models.base import BaseModel


class Chariot(BaseModel):
    """Represents a warehouse chariot / forklift."""

    code: str = Field(..., min_length=1, description="Unique chariot code")
    is_active: bool = Field(default=True, description="Whether chariot is operational")
    current_x: int = Field(default=0, ge=0, description="Current X position")
    current_y: int = Field(default=0, ge=0, description="Current Y position")
    current_z: int = Field(default=0, ge=0, description="Current Z position")
    current_floor: int = Field(default=0, ge=0, description="Current floor")
    assigned_to_operation: Optional[str] = Field(default=None, description="Currently assigned operation ID")

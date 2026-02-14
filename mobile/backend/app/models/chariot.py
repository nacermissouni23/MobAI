"""
Chariot (forklift / transport vehicle) model.
"""

from typing import Optional
from pydantic import Field

from app.models.base import BaseModel


class Chariot(BaseModel):
    """Represents a warehouse chariot / forklift."""

    is_active: bool = Field(default=True, description="Whether chariot is operational")
    assigned_to_operation_id: Optional[str] = Field(default=None, description="Currently assigned operation ID")

"""
Report model for operation anomalies and issues.
"""

from pydantic import Field

from app.models.base import BaseModel


class Report(BaseModel):
    """Represents an anomaly report for an operation."""

    operation_id: str = Field(..., description="Related operation ID")
    missing_quantity: int = Field(default=0, ge=0, description="Missing quantity")
    physical_damage: bool = Field(default=False, description="Whether physical damage was found")
    extra_quality: int = Field(default=0, ge=0, description="Extra quality score")

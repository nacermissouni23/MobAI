"""
Report schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field


class ReportCreate(BaseModel):
    """Schema for creating a report."""
    operation_id: str
    missing_quantity: int = Field(default=0, ge=0)
    physical_damage: bool = False
    extra_quality: int = Field(default=0, ge=0)


class ReportResponse(BaseModel):
    """Schema for report response."""
    id: str
    operation_id: str
    missing_quantity: int
    physical_damage: bool
    extra_quality: int
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

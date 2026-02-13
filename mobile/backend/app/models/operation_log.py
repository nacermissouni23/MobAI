"""
Operation log model for tracking overrides and AI suggestions.
"""

from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import OperationType


class OperationLog(BaseModel):
    """Immutable log entry for operation overrides and AI suggestions."""

    operation_id: str = Field(..., description="Related operation ID")
    employee_id: Optional[str] = Field(default=None, description="Employee who performed the operation")
    product_id: Optional[str] = Field(default=None, description="Product ID")
    quantity: int = Field(default=0, ge=0, description="Quantity involved")
    type: Optional[OperationType] = Field(default=None, description="Operation type")
    overrider_id: Optional[str] = Field(default=None, description="User who overrode AI suggestion")
    chariot_id: Optional[str] = Field(default=None, description="Chariot used")
    storage_floor: Optional[int] = Field(default=None, description="Actual storage floor")
    storage_row: Optional[int] = Field(default=None, description="Actual storage row (Y)")
    storage_col: Optional[int] = Field(default=None, description="Actual storage column (X)")
    override_reason: Optional[str] = Field(default=None, description="Reason for override")
    ai_suggested_floor: Optional[int] = Field(default=None, description="AI suggested floor")
    ai_suggested_row: Optional[int] = Field(default=None, description="AI suggested row (Y)")
    ai_suggested_col: Optional[int] = Field(default=None, description="AI suggested column (X)")

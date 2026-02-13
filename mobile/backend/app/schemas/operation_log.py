"""
Operation log schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import OperationType


class OperationLogCreate(BaseModel):
    """Schema for creating an operation log entry."""
    operation_id: str
    employee_id: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    type: Optional[OperationType] = None
    overrider_id: Optional[str] = None
    chariot_id: Optional[str] = None
    storage_floor: Optional[int] = None
    storage_row: Optional[int] = None
    storage_col: Optional[int] = None
    override_reason: Optional[str] = None
    ai_suggested_floor: Optional[int] = None
    ai_suggested_row: Optional[int] = None
    ai_suggested_col: Optional[int] = None


class OperationLogResponse(BaseModel):
    """Schema for operation log response."""
    id: str
    operation_id: str
    employee_id: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = 0
    type: Optional[OperationType] = None
    overrider_id: Optional[str] = None
    chariot_id: Optional[str] = None
    storage_floor: Optional[int] = None
    storage_row: Optional[int] = None
    storage_col: Optional[int] = None
    override_reason: Optional[str] = None
    ai_suggested_floor: Optional[int] = None
    ai_suggested_row: Optional[int] = None
    ai_suggested_col: Optional[int] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

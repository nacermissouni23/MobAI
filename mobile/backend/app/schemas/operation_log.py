"""
Operation log schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import OperationType


class OperationLogCreate(BaseModel):
    """Schema for creating an operation log entry."""
    operation_id: Optional[str] = None
    action: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    type: Optional[OperationType] = None
    employee_id: Optional[str] = None
    overridor_id: Optional[str] = None
    overriden_at: Optional[str] = None
    validator_id: Optional[str] = None
    validated_at: Optional[str] = None
    chariot_id: Optional[str] = None
    order_id: Optional[str] = None
    emplacement_id: Optional[str] = None
    date: Optional[str] = None


class OperationLogResponse(BaseModel):
    """Schema for operation log response."""
    id: str
    operation_id: Optional[str] = None
    action: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = 0
    type: Optional[OperationType] = None
    employee_id: Optional[str] = None
    overridor_id: Optional[str] = None
    overriden_at: Optional[str] = None
    validator_id: Optional[str] = None
    validated_at: Optional[str] = None
    chariot_id: Optional[str] = None
    order_id: Optional[str] = None
    emplacement_id: Optional[str] = None
    date: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

"""
Operation schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import OperationType, OperationStatus


class OperationCreate(BaseModel):
    """Schema for creating an operation."""
    type: OperationType
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    employee_id: Optional[str] = None
    chariot_id: Optional[str] = None
    order_id: Optional[str] = None
    emplacement_id: Optional[str] = None
    source_emplacement_id: Optional[str] = None


class OperationApprove(BaseModel):
    """Schema for supervisor approval (optionally with override values)."""
    emplacement_id: Optional[str] = None
    source_emplacement_id: Optional[str] = None
    quantity: Optional[int] = None


class OperationResponse(BaseModel):
    """Schema for operation response."""
    id: str
    product_id: Optional[str] = None
    quantity: int
    type: OperationType
    status: OperationStatus = OperationStatus.PENDING
    employee_id: Optional[str] = None
    validator_id: Optional[str] = None
    validated_at: Optional[str] = None
    chariot_id: Optional[str] = None
    order_id: Optional[str] = None
    emplacement_id: Optional[str] = None
    source_emplacement_id: Optional[str] = None
    suggested_route: Optional[list] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

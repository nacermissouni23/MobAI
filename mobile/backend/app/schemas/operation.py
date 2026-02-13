"""
Operation schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import OperationType, OperationStatus


class OperationCreate(BaseModel):
    """Schema for creating an operation."""
    type: OperationType
    employee_id: Optional[str] = None
    chariot_id: Optional[str] = None
    order_id: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    source_x: Optional[int] = None
    source_y: Optional[int] = None
    source_z: Optional[int] = None
    source_floor: Optional[int] = None
    destination_x: Optional[int] = None
    destination_y: Optional[int] = None
    destination_z: Optional[int] = None
    destination_floor: Optional[int] = None
    warehouse_id: Optional[str] = None


class OperationResponse(BaseModel):
    """Schema for operation response."""
    id: str
    type: OperationType
    employee_id: Optional[str] = None
    validator_id: Optional[str] = None
    validated_at: Optional[str] = None
    chariot_id: Optional[str] = None
    order_id: Optional[str] = None
    destination_x: Optional[int] = None
    destination_y: Optional[int] = None
    destination_z: Optional[int] = None
    destination_floor: Optional[int] = None
    source_x: Optional[int] = None
    source_y: Optional[int] = None
    source_z: Optional[int] = None
    source_floor: Optional[int] = None
    emplacement_id: Optional[str] = None
    status: OperationStatus
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

"""
Order schemas for request/response validation.
"""

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field

from app.core.enums import OrderType, OrderStatus


class OrderLineSchema(BaseModel):
    """Schema for a single order line."""
    product_id: str
    sku: Optional[str] = None
    product_name: Optional[str] = None
    quantity: int = Field(..., gt=0)
    source_x: Optional[int] = None
    source_y: Optional[int] = None
    source_z: Optional[int] = None
    source_floor: Optional[int] = None
    destination_x: Optional[int] = None
    destination_y: Optional[int] = None
    destination_z: Optional[int] = None
    destination_floor: Optional[int] = None


class OrderCreate(BaseModel):
    """Schema for creating a manual command order."""
    type: OrderType = Field(default=OrderType.COMMAND)
    lines: List[OrderLineSchema] = Field(..., min_length=1)


class OrderOverride(BaseModel):
    """Schema for overriding an AI-generated order."""
    override_reason: str = Field(..., min_length=1)
    lines: Optional[List[OrderLineSchema]] = None


class OrderResponse(BaseModel):
    """Schema for order response."""
    id: str
    type: OrderType
    status: OrderStatus
    lines: List[OrderLineSchema] = []
    generated_by_ai: bool
    overridden_by: Optional[str] = None
    override_reason: Optional[str] = None
    completed_at: Optional[str] = None
    completed_by: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

"""
Order schemas for request/response validation.
"""

from typing import Optional, List
from pydantic import BaseModel, Field

from app.core.enums import OrderType, OrderStatus


class OrderLineSchema(BaseModel):
    """Schema for a single order line (product + quantity + location)."""
    product_id: str
    sku: Optional[str] = None
    product_name: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    source_x: Optional[int] = None
    source_y: Optional[int] = None
    source_z: Optional[int] = None
    source_floor: Optional[int] = None
    destination_x: Optional[int] = None
    destination_y: Optional[int] = None
    destination_z: Optional[int] = None
    destination_floor: Optional[int] = None


class OrderCreate(BaseModel):
    """Schema for creating an order."""
    type: OrderType = Field(default=OrderType.COMMAND)
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    lines: List[OrderLineSchema] = Field(default_factory=list)


class OrderOverride(BaseModel):
    """Schema for overriding an AI-generated order."""
    override_reason: str = Field(..., min_length=1, description="Justification for override")
    lines: Optional[List[OrderLineSchema]] = None


class OrderResponse(BaseModel):
    """Schema for order response."""
    id: str
    type: OrderType
    status: OrderStatus = OrderStatus.PENDING
    supervisor_id: Optional[str] = None
    validator_id: Optional[str] = None
    validated_at: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = 0
    lines: Optional[list] = None
    generated_by_ai: bool = False
    overridden_by: Optional[str] = None
    override_reason: Optional[str] = None
    completed_at: Optional[str] = None
    completed_by: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

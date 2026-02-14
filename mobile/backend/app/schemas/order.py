"""
Order schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import OrderType, OrderStatus


class OrderCreate(BaseModel):
    """Schema for creating an order."""
    type: OrderType = Field(default=OrderType.COMMAND)
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)


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
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

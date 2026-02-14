"""
Order log schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import OrderType


class OrderLogCreate(BaseModel):
    """Schema for creating an order log entry."""
    order_id: str
    action: str
    order_type: Optional[OrderType] = None
    supervisor_id: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = Field(default=0, ge=0)
    date: Optional[str] = None


class OrderLogResponse(BaseModel):
    """Schema for order log response."""
    id: str
    order_id: str
    action: str
    order_type: Optional[OrderType] = None
    supervisor_id: Optional[str] = None
    product_id: Optional[str] = None
    quantity: int = 0
    date: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

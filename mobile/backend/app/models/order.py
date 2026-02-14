"""
Order model for warehouse commands.
"""

from datetime import datetime
from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import OrderType, OrderStatus


class Order(BaseModel):
    """Represents a warehouse order."""

    type: OrderType = Field(..., description="Order type")
    status: OrderStatus = Field(default=OrderStatus.PENDING, description="Order status")
    supervisor_id: Optional[str] = Field(default=None, description="Supervisor who created the order")
    validator_id: Optional[str] = Field(default=None, description="Supervisor who validated")
    validated_at: Optional[datetime] = Field(default=None, description="Validation timestamp")
    product_id: Optional[str] = Field(default=None, description="Product ID")
    quantity: int = Field(default=0, ge=0, description="Ordered quantity")

    def to_firestore(self) -> dict:
        """Convert to Firestore-compatible dict."""
        data = super().to_firestore()
        if self.validated_at:
            data["validated_at"] = self.validated_at.isoformat()
        return data

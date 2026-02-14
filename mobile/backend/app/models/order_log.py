"""
Order log model for tracking order lifecycle events.
"""

from datetime import datetime
from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import OrderType


class OrderLog(BaseModel):
    """Immutable log entry for order events."""

    order_id: str = Field(..., description="Related order ID")
    action: str = Field(..., description="Action: created, validated")
    order_type: Optional[OrderType] = Field(default=None, description="Order type")
    supervisor_id: Optional[str] = Field(default=None, description="Supervisor who performed action")
    product_id: Optional[str] = Field(default=None, description="Product ID")
    quantity: int = Field(default=0, ge=0, description="Quantity")
    date: Optional[datetime] = Field(default_factory=datetime.utcnow, description="Log date")

    def to_firestore(self) -> dict:
        """Convert to Firestore-compatible dict."""
        data = super().to_firestore()
        if self.date:
            data["date"] = self.date.isoformat()
        return data

"""
Stock ledger model for immutable inventory audit trail.
"""

from datetime import datetime
from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import OperationType


class StockLedger(BaseModel):
    """Immutable stock movement record for audit trail."""

    x: int = Field(..., ge=0, description="Location X")
    y: int = Field(..., ge=0, description="Location Y")
    z: int = Field(default=0, ge=0, description="Location Z (shelf)")
    floor: int = Field(default=0, ge=0, description="Floor")
    product_id: str = Field(..., description="Product ID")
    quantity: int = Field(..., description="Quantity change (positive=in, negative=out)")
    recorded_at: datetime = Field(default_factory=datetime.utcnow, description="Timestamp")
    operation_id: Optional[str] = Field(default=None, description="Related operation ID")
    operation_type: Optional[OperationType] = Field(default=None, description="Type of operation")
    user_id: Optional[str] = Field(default=None, description="User who performed the movement")

    def to_firestore(self) -> dict:
        """Convert to Firestore-compatible dict."""
        data = super().to_firestore()
        if self.recorded_at:
            data["recorded_at"] = self.recorded_at.isoformat()
        return data

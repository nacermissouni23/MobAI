"""
Operation log model for tracking operations, overrides, and validations.
"""

from datetime import datetime
from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import OperationType


class OperationLog(BaseModel):
    """Immutable log entry for operations."""

    operation_id: Optional[str] = Field(default=None, description="Related operation ID")
    action: Optional[str] = Field(default=None, description="Action: created, validated, approved, overridden")
    product_id: Optional[str] = Field(default=None, description="Product ID")
    quantity: int = Field(default=0, ge=0, description="Quantity involved")
    type: Optional[OperationType] = Field(default=None, description="Operation type")
    employee_id: Optional[str] = Field(default=None, description="Employee who performed the operation")
    overridor_id: Optional[str] = Field(default=None, description="User who overrode AI suggestion")
    overriden_at: Optional[datetime] = Field(default=None, description="Override timestamp")
    validator_id: Optional[str] = Field(default=None, description="Supervisor who validated")
    validated_at: Optional[datetime] = Field(default=None, description="Validation timestamp")
    chariot_id: Optional[str] = Field(default=None, description="Chariot used")
    order_id: Optional[str] = Field(default=None, description="Related order ID")
    emplacement_id: Optional[str] = Field(default=None, description="Emplacement location ID")
    date: Optional[datetime] = Field(default_factory=datetime.utcnow, description="Log date")

    def to_firestore(self) -> dict:
        """Convert to Firestore-compatible dict."""
        data = super().to_firestore()
        for dt_field in ("overriden_at", "validated_at", "date"):
            val = getattr(self, dt_field)
            if val:
                data[dt_field] = val.isoformat()
        return data

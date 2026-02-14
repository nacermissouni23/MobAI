"""
Operation model representing warehouse tasks (receipt, transfer, picking, delivery).
"""

from datetime import datetime
from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import OperationType, OperationStatus


class Operation(BaseModel):
    """Represents a single warehouse operation."""

    product_id: Optional[str] = Field(default=None, description="Product ID")
    quantity: int = Field(default=0, ge=0, description="Quantity")
    type: OperationType = Field(..., description="Operation type")
    status: OperationStatus = Field(default=OperationStatus.PENDING, description="Lifecycle status")
    employee_id: Optional[str] = Field(default=None, description="Assigned employee ID")
    validator_id: Optional[str] = Field(default=None, description="Supervisor who validated")
    validated_at: Optional[datetime] = Field(default=None, description="Validation timestamp")
    chariot_id: Optional[str] = Field(default=None, description="Assigned chariot ID")
    order_id: Optional[str] = Field(default=None, description="Parent order ID")
    emplacement_id: Optional[str] = Field(default=None, description="Destination emplacement ID")
    source_emplacement_id: Optional[str] = Field(default=None, description="Source emplacement ID")
    suggested_route: Optional[list] = Field(default=None, description="AI-suggested route coordinates")

    def to_firestore(self) -> dict:
        """Convert to Firestore-compatible dict."""
        data = super().to_firestore()
        if self.validated_at:
            data["validated_at"] = self.validated_at.isoformat()
        return data

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

    type: OperationType = Field(..., description="Operation type")
    employee_id: Optional[str] = Field(default=None, description="Assigned employee ID")
    validator_id: Optional[str] = Field(default=None, description="Supervisor who validated")
    validated_at: Optional[datetime] = Field(default=None, description="Validation timestamp")
    chariot_id: Optional[str] = Field(default=None, description="Assigned chariot ID")
    order_id: Optional[str] = Field(default=None, description="Parent order ID")
    destination_x: Optional[int] = Field(default=None, description="Destination X")
    destination_y: Optional[int] = Field(default=None, description="Destination Y")
    destination_z: Optional[int] = Field(default=None, description="Destination Z")
    destination_floor: Optional[int] = Field(default=None, description="Destination floor")
    source_x: Optional[int] = Field(default=None, description="Source X")
    source_y: Optional[int] = Field(default=None, description="Source Y")
    source_z: Optional[int] = Field(default=None, description="Source Z")
    source_floor: Optional[int] = Field(default=None, description="Source floor")
    warehouse_id: Optional[str] = Field(default=None, description="Emplacement location ID")
    status: OperationStatus = Field(default=OperationStatus.PENDING, description="Operation status")
    started_at: Optional[datetime] = Field(default=None, description="Start timestamp")
    completed_at: Optional[datetime] = Field(default=None, description="Completion timestamp")
    product_id: Optional[str] = Field(default=None, description="Product ID")
    quantity: int = Field(default=0, ge=0, description="Quantity to move")

    def to_firestore(self) -> dict:
        """Convert to Firestore-compatible dict."""
        data = super().to_firestore()
        for dt_field in ("validated_at", "started_at", "completed_at"):
            val = getattr(self, dt_field)
            if val:
                data[dt_field] = val.isoformat()
        return data

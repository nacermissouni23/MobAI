"""
Stock ledger schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field


class StockAdjustment(BaseModel):
    """Schema for manual stock adjustment."""
    x: int = Field(..., ge=0)
    y: int = Field(..., ge=0)
    z: int = Field(default=0, ge=0)
    floor: int = Field(default=0, ge=0)
    product_id: str
    quantity: int = Field(..., description="Positive to add, negative to remove")


class StockLedgerResponse(BaseModel):
    """Schema for stock ledger entry response."""
    id: str
    x: int
    y: int
    z: int
    floor: int
    product_id: str
    quantity: int
    recorded_at: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True


class StockSummaryResponse(BaseModel):
    """Schema for stock summary per product."""
    product_id: str
    total_quantity: int
    location_count: int

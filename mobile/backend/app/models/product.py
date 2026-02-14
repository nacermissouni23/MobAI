"""
Product model for warehouse inventory items.
"""

from typing import Optional
from pydantic import Field

from app.models.base import BaseModel


class Product(BaseModel):
    """Represents a product stored in the warehouse."""

    sku: str = Field(..., min_length=1, description="Stock Keeping Unit")
    nom_produit: str = Field(..., min_length=1, description="Product name")
    unite_mesure: str = Field(default="pcs", description="Unit of measure")
    categorie: Optional[str] = Field(default=None, description="Product category")
    actif: bool = Field(default=True, description="Whether product is active")
    colisage_fardeau: Optional[int] = Field(default=None, ge=0, description="Units per bundle")
    colisage_palette: Optional[int] = Field(default=None, ge=0, description="Units per pallet")
    volume_pcs: Optional[float] = Field(default=None, ge=0, description="Volume per unit (m³)")
    poids: Optional[float] = Field(default=None, ge=0, description="Weight per unit (kg)")
    is_gerbable: bool = Field(default=False, description="Whether product is stackable")
    demand_freq: float = Field(default=0.0, ge=0, description="Average demand frequency")
    reception_freq: float = Field(default=0.0, ge=0, description="Average reception frequency")
    delivery_freq: float = Field(default=0.0, ge=0, description="Average delivery frequency")

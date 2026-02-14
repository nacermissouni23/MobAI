"""
Product schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field


class ProductCreate(BaseModel):
    """Schema for creating a product."""
    sku: str = Field(..., min_length=1)
    nom_produit: str = Field(..., min_length=1)
    unite_mesure: str = Field(default="pcs")
    categorie: Optional[str] = None
    actif: bool = True
    colisage_fardeau: Optional[int] = Field(default=None, ge=0)
    colisage_palette: Optional[int] = Field(default=None, ge=0)
    volume_pcs: Optional[float] = Field(default=None, ge=0)
    poids: Optional[float] = Field(default=None, ge=0)
    is_gerbable: bool = False
    demand_freq: float = Field(default=0.0, ge=0)
    reception_freq: float = Field(default=0.0, ge=0)
    delivery_freq: float = Field(default=0.0, ge=0)


class ProductUpdate(BaseModel):
    """Schema for updating a product."""
    nom_produit: Optional[str] = Field(default=None, min_length=1)
    unite_mesure: Optional[str] = None
    categorie: Optional[str] = None
    actif: Optional[bool] = None
    colisage_fardeau: Optional[int] = Field(default=None, ge=0)
    colisage_palette: Optional[int] = Field(default=None, ge=0)
    volume_pcs: Optional[float] = Field(default=None, ge=0)
    poids: Optional[float] = Field(default=None, ge=0)
    is_gerbable: Optional[bool] = None
    demand_freq: Optional[float] = Field(default=None, ge=0)
    reception_freq: Optional[float] = Field(default=None, ge=0)
    delivery_freq: Optional[float] = Field(default=None, ge=0)


class ProductResponse(BaseModel):
    """Schema for product response."""
    id: str
    sku: str
    nom_produit: str
    unite_mesure: str
    categorie: Optional[str] = None
    actif: bool
    colisage_fardeau: Optional[int] = None
    colisage_palette: Optional[int] = None
    volume_pcs: Optional[float] = None
    poids: Optional[float] = None
    is_gerbable: bool
    demand_freq: float
    reception_freq: float
    delivery_freq: float
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True

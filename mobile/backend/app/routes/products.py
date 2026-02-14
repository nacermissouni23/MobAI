"""
Product routes: CRUD operations for warehouse products.
"""

from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.exceptions import ConflictError
from app.repositories.product_repository import ProductRepository
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
product_repo = ProductRepository()


@router.get("/", response_model=List[ProductResponse])
async def list_products(
    category: Optional[str] = Query(default=None, description="Filter by category"),
    active_only: bool = Query(default=False, description="Only active products"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all products with optional filters."""
    products = await product_repo.get_filtered(category=category, active_only=active_only)
    return [ProductResponse(**p) for p in products]


@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a single product by ID."""
    product = await product_repo.get_by_id_or_raise(product_id)
    return ProductResponse(**product)


@router.get("/sku/{sku}", response_model=ProductResponse)
async def get_product_by_sku(
    sku: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a product by its SKU."""
    product = await product_repo.get_by_sku(sku)
    if not product:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Product", sku)
    return ProductResponse(**product)


@router.post("/", response_model=ProductResponse, status_code=201)
async def create_product(
    data: ProductCreate,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Create a new product. Supervisor/Admin only."""
    # Check SKU uniqueness
    existing = await product_repo.get_by_sku(data.sku)
    if existing:
        raise ConflictError(f"Product with SKU '{data.sku}' already exists")

    product_data = data.model_dump()
    created = await product_repo.create(product_data)
    return ProductResponse(**created)


@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: str,
    data: ProductUpdate,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Update a product. Supervisor/Admin only."""
    update_data = data.model_dump(exclude_unset=True)
    updated = await product_repo.update(product_id, update_data)
    return ProductResponse(**updated)


@router.delete("/{product_id}", status_code=204)
async def delete_product(
    product_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete a product. Supervisor/Admin only."""
    await product_repo.delete(product_id)

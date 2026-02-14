"""
Emplacement routes: CRUD and query operations for emplacement grid cells.
"""

from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.exceptions import NotFoundError
from app.repositories.emplacement_repository import EmplacementRepository
from app.schemas.emplacement import (
    EmplacementCreate,
    EmplacementUpdate,
    EmplacementResponse,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
emplacement_repo = EmplacementRepository()


@router.get("/locations", response_model=List[EmplacementResponse])
async def list_locations(
    floor: Optional[int] = Query(default=None, description="Filter by floor"),
    is_slot: Optional[bool] = Query(default=None, description="Filter by slot type"),
    is_occupied: Optional[bool] = Query(default=None, description="Filter by occupied status"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get emplacement locations with optional filters."""
    locations = await emplacement_repo.get_filtered(
        floor=floor, is_slot=is_slot, is_occupied=is_occupied
    )
    return [EmplacementResponse(**loc) for loc in locations]


@router.get("/locations/{location_id}", response_model=EmplacementResponse)
async def get_location(
    location_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a single emplacement location by ID."""
    location = await emplacement_repo.get_by_id_or_raise(location_id)
    return EmplacementResponse(**location)


@router.get("/locations/code/{location_code}", response_model=EmplacementResponse)
async def get_location_by_code(
    location_code: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get an emplacement location by its human-readable code."""
    location = await emplacement_repo.get_by_location_code(location_code)
    if not location:
        raise NotFoundError("Emplacement location", location_code)
    return EmplacementResponse(**location)


@router.get("/available-slots", response_model=List[EmplacementResponse])
async def get_available_slots(
    floor: Optional[int] = Query(default=None, description="Filter by floor"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all available (unoccupied) storage slots."""
    slots = await emplacement_repo.get_available_slots(floor=floor)
    return [EmplacementResponse(**s) for s in slots]


@router.get("/occupied-slots", response_model=List[EmplacementResponse])
async def get_occupied_slots(
    floor: Optional[int] = Query(default=None, description="Filter by floor"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all occupied storage slots."""
    slots = await emplacement_repo.get_occupied_slots(floor=floor)
    return [EmplacementResponse(**s) for s in slots]


@router.get("/expedition-zones", response_model=List[EmplacementResponse])
async def get_expedition_zones(
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all expedition zones."""
    zones = await emplacement_repo.get_expedition_zones()
    return [EmplacementResponse(**z) for z in zones]


@router.get("/product/{product_id}/locations", response_model=List[EmplacementResponse])
async def get_product_locations(
    product_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all locations storing a specific product."""
    locations = await emplacement_repo.get_product_locations(product_id)
    return [EmplacementResponse(**loc) for loc in locations]


@router.post("/locations", response_model=EmplacementResponse, status_code=201)
async def create_location(
    data: EmplacementCreate,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Create a new emplacement location. Supervisor/Admin only."""
    location_data = data.model_dump()
    created = await emplacement_repo.create(location_data)
    return EmplacementResponse(**created)


@router.put("/locations/{location_id}", response_model=EmplacementResponse)
async def update_location(
    location_id: str,
    data: EmplacementUpdate,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Update an emplacement location. Supervisor/Admin only."""
    update_data = data.model_dump(exclude_unset=True)
    updated = await emplacement_repo.update(location_id, update_data)
    return EmplacementResponse(**updated)


@router.delete("/locations/{location_id}", status_code=204)
async def delete_location(
    location_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete an emplacement location. Supervisor/Admin only."""
    await emplacement_repo.delete(location_id)

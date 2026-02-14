"""
Chariot (forklift) routes: CRUD operations.
"""

from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.repositories.chariot_repository import ChariotRepository
from app.schemas.chariot import ChariotCreate, ChariotUpdate, ChariotResponse
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
chariot_repo = ChariotRepository()


@router.get("/", response_model=List[ChariotResponse])
async def list_chariots(
    is_active: Optional[bool] = Query(default=None, description="Filter by active status"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all chariots with optional filters."""
    chariots = await chariot_repo.get_filtered(is_active=is_active)
    return [ChariotResponse(**c) for c in chariots]


@router.get("/{chariot_id}", response_model=ChariotResponse)
async def get_chariot(
    chariot_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get a single chariot by ID."""
    chariot = await chariot_repo.get_by_id_or_raise(chariot_id)
    return ChariotResponse(**chariot)


@router.post("/", response_model=ChariotResponse, status_code=201)
async def create_chariot(
    data: ChariotCreate,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Create a new chariot. Supervisor/Admin only."""
    chariot_data = data.model_dump()
    created = await chariot_repo.create(chariot_data)
    return ChariotResponse(**created)


@router.put("/{chariot_id}", response_model=ChariotResponse)
async def update_chariot(
    chariot_id: str,
    data: ChariotUpdate,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Update a chariot. Supervisor/Admin only."""
    update_data = data.model_dump(exclude_unset=True)
    updated = await chariot_repo.update(chariot_id, update_data)
    return ChariotResponse(**updated)


@router.delete("/{chariot_id}", status_code=204)
async def delete_chariot(
    chariot_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete a chariot. Supervisor/Admin only."""
    await chariot_repo.delete(chariot_id)

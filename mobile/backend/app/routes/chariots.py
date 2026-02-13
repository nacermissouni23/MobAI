"""
Chariot (forklift) routes: CRUD, assignment, and release operations.
"""

from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.exceptions import ConflictError, NotFoundError, ValidationError
from app.repositories.chariot_repository import ChariotRepository
from app.repositories.operation_repository import OperationRepository
from app.schemas.chariot import ChariotCreate, ChariotUpdate, ChariotResponse
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
chariot_repo = ChariotRepository()
operation_repo = OperationRepository()


@router.get("/", response_model=List[ChariotResponse])
async def list_chariots(
    is_active: Optional[bool] = Query(default=None, description="Filter by active status"),
    available_only: bool = Query(default=False, description="Only available chariots"),
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all chariots with optional filters."""
    chariots = await chariot_repo.get_filtered(is_active=is_active, available_only=available_only)
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
    existing = await chariot_repo.get_by_code(data.code)
    if existing:
        raise ConflictError(f"Chariot with code '{data.code}' already exists")

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
    chariot = await chariot_repo.get_by_id_or_raise(chariot_id)
    if chariot.get("assigned_to_operation"):
        raise ConflictError("Cannot delete a chariot currently assigned to an operation")
    await chariot_repo.delete(chariot_id)


@router.post("/{chariot_id}/assign/{operation_id}", response_model=ChariotResponse)
async def assign_chariot(
    chariot_id: str,
    operation_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Assign a chariot to an operation."""
    chariot = await chariot_repo.get_by_id_or_raise(chariot_id)

    if not chariot.get("is_active", True):
        raise ValidationError("Chariot is not active")

    if chariot.get("assigned_to_operation"):
        raise ConflictError(
            f"Chariot is already assigned to operation '{chariot['assigned_to_operation']}'"
        )

    # Verify operation exists
    await operation_repo.get_by_id_or_raise(operation_id)

    updated = await chariot_repo.update(chariot_id, {"assigned_to_operation": operation_id})

    # Also update operation with chariot_id
    await operation_repo.update(operation_id, {"chariot_id": chariot_id})

    return ChariotResponse(**updated)


@router.post("/{chariot_id}/release", response_model=ChariotResponse)
async def release_chariot(
    chariot_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Release a chariot from its current operation assignment."""
    chariot = await chariot_repo.get_by_id_or_raise(chariot_id)

    if not chariot.get("assigned_to_operation"):
        raise ValidationError("Chariot is not assigned to any operation")

    updated = await chariot_repo.update(chariot_id, {"assigned_to_operation": None})
    return ChariotResponse(**updated)

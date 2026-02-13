"""
User management routes. Admin only + real-time employee tracking.
"""

from datetime import datetime
from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.core.enums import UserRole
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserResponse, UserUpdate
from app.utils.dependencies import get_admin_user, get_current_user

router = APIRouter()
user_repo = UserRepository()


@router.get("/", response_model=List[UserResponse])
async def list_users(
    role: Optional[UserRole] = Query(default=None, description="Filter by role"),
    _admin: Dict[str, Any] = Depends(get_admin_user),
):
    """Get all users with optional filters. Admin only."""
    users = await user_repo.get_filtered(role=role)
    return [UserResponse(**u) for u in users]


@router.get("/employees", response_model=List[UserResponse])
async def get_employees(
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all employees."""
    employees = await user_repo.get_employees()
    return [UserResponse(**e) for e in employees]


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    _admin: Dict[str, Any] = Depends(get_admin_user),
):
    """Get a single user by ID. Admin only."""
    user = await user_repo.get_by_id_or_raise(user_id)
    return UserResponse(**user)


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    data: UserUpdate,
    _admin: Dict[str, Any] = Depends(get_admin_user),
):
    """Update a user. Admin only."""
    update_data = data.model_dump(exclude_unset=True)
    if "role" in update_data and update_data["role"] is not None:
        update_data["role"] = update_data["role"].value
    updated = await user_repo.update(user_id, update_data)
    return UserResponse(**updated)


@router.delete("/{user_id}", status_code=204)
async def delete_user(
    user_id: str,
    _admin: Dict[str, Any] = Depends(get_admin_user),
):
    """Delete a user. Admin only."""
    await user_repo.delete(user_id)

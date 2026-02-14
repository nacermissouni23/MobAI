"""
Authentication routes: register, login, get current user.
"""

from typing import Dict, Any

from fastapi import APIRouter, Depends

from app.schemas.user import UserRegister, UserLogin, UserResponse, TokenResponse
from app.services.auth_service import AuthService
from app.utils.dependencies import get_current_user, get_admin_user

router = APIRouter()
auth_service = AuthService()


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(
    data: UserRegister,
    current_user: Dict[str, Any] = Depends(get_admin_user),
):
    """
    Register a new user. Admin only.
    """
    return await auth_service.register(data, current_user)


@router.post("/login", response_model=TokenResponse)
async def login(data: UserLogin):
    """
    Authenticate and receive a JWT token.
    """
    return await auth_service.login(data)


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: Dict[str, Any] = Depends(get_current_user)):
    """
    Get the current authenticated user's profile.
    """
    return await auth_service.get_current_user_data(current_user["id"])

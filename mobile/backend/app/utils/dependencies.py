"""
FastAPI dependency injection utilities for authentication and authorization.
"""

from typing import Dict, Any

from fastapi import Depends, Header
from jose import JWTError

from app.core.enums import UserRole
from app.core.exceptions import AuthenticationError, AuthorizationError
from app.repositories.user_repository import UserRepository
from app.utils.security import decode_access_token


async def get_token(authorization: str = Header(..., description="Bearer <token>")) -> str:
    """Extract JWT token from Authorization header."""
    if not authorization.startswith("Bearer "):
        raise AuthenticationError("Invalid authorization header format. Use 'Bearer <token>'")
    return authorization[7:]


async def get_current_user(token: str = Depends(get_token)) -> Dict[str, Any]:
    """
    Decode JWT and return the current authenticated user.

    Returns:
        User dict from Firestore including 'id', 'role', etc.
    """
    try:
        payload = decode_access_token(token)
    except JWTError:
        raise AuthenticationError("Invalid or expired token")

    user_id = payload.get("sub")
    if not user_id:
        raise AuthenticationError("Invalid token payload")

    user_repo = UserRepository()
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise AuthenticationError("User not found")

    if not user.get("is_active", True):
        raise AuthorizationError("Account is deactivated")

    return user


async def get_admin_user(current_user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """Dependency that requires the current user to be an Admin."""
    if current_user.get("role") != UserRole.ADMIN.value:
        raise AuthorizationError("Admin access required")
    return current_user


async def get_supervisor_user(current_user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """Dependency that requires the current user to be a Supervisor or Admin."""
    role = current_user.get("role")
    if role not in (UserRole.ADMIN.value, UserRole.SUPERVISOR.value):
        raise AuthorizationError("Supervisor or Admin access required")
    return current_user

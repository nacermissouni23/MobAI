"""
Authentication service handling user registration, login, and JWT operations.
"""

from datetime import datetime
from typing import Dict, Any, Optional

from app.core.enums import UserRole
from app.core.exceptions import (
    AuthenticationError,
    ConflictError,
    NotFoundError,
    AuthorizationError,
)
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserRegister, UserLogin, UserResponse, TokenResponse
from app.utils.security import hash_password, verify_password, create_access_token
from app.utils.logger import logger


class AuthService:
    """Handles authentication and user management logic."""

    def __init__(self):
        self.user_repo = UserRepository()

    async def register(
        self, data: UserRegister, current_user: Optional[Dict[str, Any]] = None
    ) -> UserResponse:
        """
        Register a new user. Only admins can register new users.

        Args:
            data: Registration data.
            current_user: The authenticated admin user.

        Returns:
            UserResponse for the created user.
        """
        # Check for existing email
        existing = await self.user_repo.get_by_email(data.email)
        if existing:
            raise ConflictError(f"User with email '{data.email}' already exists")

        # Hash password
        hashed = hash_password(data.password)

        user_data = {
            "name": data.name,
            "email": data.email,
            "password": hashed,
            "role": data.role.value,
            "is_active": True,
        }

        created = await self.user_repo.create(user_data)
        logger.info(f"User registered: {created['email']} (role: {data.role.value})")
        return UserResponse(**created)

    async def login(self, data: UserLogin) -> TokenResponse:
        """
        Authenticate a user and return a JWT token.

        Args:
            data: Login credentials.

        Returns:
            TokenResponse with JWT and user info.
        """
        user = await self.user_repo.get_by_email(data.email)
        if not user:
            raise AuthenticationError("Invalid email or password")

        if not verify_password(data.password, user["password"]):
            raise AuthenticationError("Invalid email or password")

        if not user.get("is_active", True):
            raise AuthorizationError("Account is deactivated")

        # Create JWT
        token = create_access_token(
            subject=user["id"],
            role=user["role"],
            extra={"email": user["email"], "name": user["name"]},
        )

        user_response = UserResponse(**user)
        logger.info(f"User logged in: {user['email']}")
        return TokenResponse(access_token=token, user=user_response)

    async def get_current_user_data(self, user_id: str) -> UserResponse:
        """
        Get the current user's profile.

        Args:
            user_id: The authenticated user's ID.

        Returns:
            UserResponse.
        """
        user = await self.user_repo.get_by_id_or_raise(user_id)
        return UserResponse(**user)

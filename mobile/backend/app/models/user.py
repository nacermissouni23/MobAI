"""
User model for warehouse personnel.
"""

from typing import Optional
from pydantic import Field

from app.models.base import BaseModel
from app.core.enums import UserRole


class User(BaseModel):
    """Represents a warehouse system user."""

    name: str = Field(..., min_length=1, max_length=100, description="Full name")
    email: str = Field(..., description="Email address")
    password: str = Field(..., min_length=6, description="Hashed password")
    role: UserRole = Field(default=UserRole.EMPLOYEE, description="User role")
    is_active: bool = Field(default=True, description="Whether user account is active")

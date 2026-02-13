"""
User model for warehouse personnel.
"""

from datetime import datetime
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
    emplacement_id: Optional[str] = Field(default=None, description="Assigned emplacement/zone ID")

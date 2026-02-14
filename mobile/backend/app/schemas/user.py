"""
User schemas for request/response validation.
"""

from typing import Optional
from pydantic import BaseModel, Field

from app.core.enums import UserRole


# ── Request Schemas ──────────────────────────────────────────────

class UserRegister(BaseModel):
    """Schema for user registration."""
    id: Optional[str] = None  # Auto-incremented by DB
    name: str = Field(..., min_length=1, max_length=100)
    email: str = Field(...)
    password: str = Field(..., min_length=6)
    role: UserRole = Field(default=UserRole.EMPLOYEE)
    emplacement_id: Optional[int] = None


class UserLogin(BaseModel):
    """Schema for user login."""
    email: str = Field(...)
    password: str = Field(...)


class UserUpdate(BaseModel):
    """Schema for updating a user."""
    name: Optional[str] = Field(default=None, min_length=1, max_length=100)
    role: Optional[UserRole] = None
    emplacement_id: Optional[int] = None


# ── Response Schemas ─────────────────────────────────────────────

class UserResponse(BaseModel):
    """Schema for user response (no password)."""
    id: str
    name: str
    email: str
    role: UserRole
    emplacement_id: Optional[int] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """Schema for JWT token response."""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

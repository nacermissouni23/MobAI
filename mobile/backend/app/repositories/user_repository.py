"""
User repository for Firestore operations.
"""

from typing import List, Optional, Dict, Any

from app.repositories.base_repository import BaseRepository
from app.core.enums import UserRole


class UserRepository(BaseRepository):
    """Repository for User documents."""

    def __init__(self):
        super().__init__("users")

    async def get_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Find a user by email address."""
        return await self.find_one("email", email)

    async def get_by_role(self, role: UserRole) -> List[Dict[str, Any]]:
        """Get all users with a specific role."""
        return await self.query(filters=[("role", "==", role.value)])

    async def get_employees(self) -> List[Dict[str, Any]]:
        """Get all employees."""
        return await self.query(filters=[("role", "==", UserRole.EMPLOYEE.value)])

    async def get_active_employees(self) -> List[Dict[str, Any]]:
        """Get all active employees (is_active=True)."""
        employees = await self.get_employees()
        return [e for e in employees if e.get("is_active", True)]

    async def get_filtered(
        self, role: Optional[UserRole] = None
    ) -> List[Dict[str, Any]]:
        """Get users with optional role filter."""
        filters = []
        if role is not None:
            filters.append(("role", "==", role.value))
        return await self.query(filters=filters if filters else None)

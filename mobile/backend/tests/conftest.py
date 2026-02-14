"""
Shared test fixtures and configuration for API endpoint tests.
"""

import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from fastapi.testclient import TestClient
from httpx import AsyncClient, ASGITransport

from main import create_app
from app.core.enums import UserRole


# ── Mock user data ───────────────────────────────────────────────

MOCK_ADMIN = {
    "id": "admin-001",
    "name": "Admin User",
    "email": "admin@test.com",
    "role": UserRole.ADMIN.value,
    "is_active": True,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}

MOCK_SUPERVISOR = {
    "id": "supervisor-001",
    "name": "Supervisor User",
    "email": "supervisor@test.com",
    "role": UserRole.SUPERVISOR.value,
    "is_active": True,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}

MOCK_EMPLOYEE = {
    "id": "employee-001",
    "name": "Employee User",
    "email": "employee@test.com",
    "role": UserRole.EMPLOYEE.value,
    "is_active": True,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}

AUTH_HEADER = {"Authorization": "Bearer test-token"}


# ── Fixtures ─────────────────────────────────────────────────────

@pytest.fixture
def app():
    """Create a test FastAPI app with Firebase initialization mocked."""
    with patch("main.initialize_firebase"):
        return create_app()


@pytest.fixture
def client(app):
    """Synchronous test client."""
    return TestClient(app)


@pytest.fixture
async def async_client(app):
    """Async test client for async endpoint tests."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


def override_current_user(mock_user):
    """Create a dependency override that returns the given mock user."""
    async def _override():
        return mock_user
    return _override


def override_admin_user(mock_user=None):
    """Create a dependency override for admin user."""
    user = mock_user or MOCK_ADMIN
    async def _override():
        return user
    return _override


def override_supervisor_user(mock_user=None):
    """Create a dependency override for supervisor user."""
    user = mock_user or MOCK_SUPERVISOR
    async def _override():
        return user
    return _override

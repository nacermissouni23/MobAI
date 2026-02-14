"""
Tests for Authentication endpoints: POST /api/auth/register, /login, /me
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_ADMIN, MOCK_EMPLOYEE, AUTH_HEADER,
    override_current_user, override_admin_user,
)
from app.utils.dependencies import get_current_user, get_admin_user


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_admin_user] = override_admin_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestRegister:
    """Tests for POST /api/auth/register"""

    @patch("app.routes.auth.auth_service")
    def test_register_success(self, mock_service, client):
        mock_service.register = AsyncMock(return_value=MOCK_EMPLOYEE)
        response = client.post(
            "/api/auth/register",
            json={
                "name": "New User",
                "email": "new@test.com",
                "password": "password123",
                "role": "employee",
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == MOCK_EMPLOYEE["email"]

    @patch("app.routes.auth.auth_service")
    def test_register_missing_fields(self, mock_service, client):
        response = client.post(
            "/api/auth/register",
            json={"email": "new@test.com"},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 422


class TestLogin:
    """Tests for POST /api/auth/login"""

    @patch("app.routes.auth.auth_service")
    def test_login_success(self, mock_service, client):
        mock_service.login = AsyncMock(return_value={
            "access_token": "fake-jwt-token",
            "token_type": "bearer",
            "user": MOCK_EMPLOYEE,
        })
        response = client.post(
            "/api/auth/login",
            json={"email": "employee@test.com", "password": "password123"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data

    @patch("app.routes.auth.auth_service")
    def test_login_missing_password(self, mock_service, client):
        response = client.post(
            "/api/auth/login",
            json={"email": "employee@test.com"},
        )
        assert response.status_code == 422


class TestGetMe:
    """Tests for GET /api/auth/me"""

    @patch("app.routes.auth.auth_service")
    def test_get_me_success(self, mock_service, client):
        mock_service.get_current_user_data = AsyncMock(return_value=MOCK_EMPLOYEE)
        response = client.get("/api/auth/me", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == MOCK_EMPLOYEE["email"]

    def test_get_me_no_token(self, app):
        app.dependency_overrides.clear()
        c = TestClient(app, raise_server_exceptions=False)
        response = c.get("/api/auth/me")
        assert response.status_code in (401, 422)

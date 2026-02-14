"""
Tests for User endpoints: GET/PUT/DELETE /api/users/...
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_ADMIN, MOCK_EMPLOYEE, MOCK_SUPERVISOR, AUTH_HEADER,
    override_current_user, override_admin_user,
)
from app.utils.dependencies import get_current_user, get_admin_user


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_admin_user] = override_admin_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListUsers:
    """Tests for GET /api/users/"""

    @patch("app.routes.users.user_repo")
    def test_list_users_success(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_ADMIN, MOCK_EMPLOYEE])
        response = client.get("/api/users/", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2

    @patch("app.routes.users.user_repo")
    def test_list_users_filter_by_role(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_EMPLOYEE])
        response = client.get("/api/users/?role=employee", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["role"] == "employee"


class TestGetUser:
    """Tests for GET /api/users/{user_id}"""

    @patch("app.routes.users.user_repo")
    def test_get_user_success(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_EMPLOYEE)
        response = client.get("/api/users/employee-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["id"] == "employee-001"


class TestUpdateUser:
    """Tests for PUT /api/users/{user_id}"""

    @patch("app.routes.users.user_repo")
    def test_update_user_success(self, mock_repo, client):
        updated = {**MOCK_EMPLOYEE, "name": "Updated Name"}
        mock_repo.update = AsyncMock(return_value=updated)
        response = client.put(
            "/api/users/employee-001",
            json={"name": "Updated Name"},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert response.json()["name"] == "Updated Name"


class TestDeleteUser:
    """Tests for DELETE /api/users/{user_id}"""

    @patch("app.routes.users.user_repo")
    def test_delete_user_success(self, mock_repo, client):
        mock_repo.delete = AsyncMock(return_value=True)
        response = client.delete("/api/users/employee-001", headers=AUTH_HEADER)
        assert response.status_code == 204


class TestGetEmployees:
    """Tests for GET /api/users/employees"""

    @patch("app.routes.users.user_repo")
    def test_get_employees(self, mock_repo, client):
        mock_repo.get_employees = AsyncMock(return_value=[MOCK_EMPLOYEE])
        response = client.get("/api/users/employees", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1

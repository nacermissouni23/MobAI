"""
Tests for Chariot endpoints: GET/POST/PUT/DELETE /api/chariots/...
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_CHARIOT = {
    "id": "chariot-001",
    "is_active": True,
    "assigned_to_operation_id": None,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListChariots:
    """Tests for GET /api/chariots/"""

    @patch("app.routes.chariots.chariot_repo")
    def test_list_chariots(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_CHARIOT])
        response = client.get("/api/chariots/", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1

    @patch("app.routes.chariots.chariot_repo")
    def test_list_chariots_filter_active(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_CHARIOT])
        response = client.get("/api/chariots/?is_active=true", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestGetChariot:
    """Tests for GET /api/chariots/{chariot_id}"""

    @patch("app.routes.chariots.chariot_repo")
    def test_get_chariot_success(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_CHARIOT)
        response = client.get("/api/chariots/chariot-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["id"] == "chariot-001"


class TestCreateChariot:
    """Tests for POST /api/chariots/"""

    @patch("app.routes.chariots.chariot_repo")
    def test_create_chariot_success(self, mock_repo, client):
        mock_repo.create = AsyncMock(return_value=MOCK_CHARIOT)
        response = client.post(
            "/api/chariots/",
            json={"is_active": True},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201


class TestUpdateChariot:
    """Tests for PUT /api/chariots/{chariot_id}"""

    @patch("app.routes.chariots.chariot_repo")
    def test_update_chariot(self, mock_repo, client):
        updated = {**MOCK_CHARIOT, "is_active": False}
        mock_repo.update = AsyncMock(return_value=updated)
        response = client.put(
            "/api/chariots/chariot-001",
            json={"is_active": False},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert response.json()["is_active"] is False


class TestDeleteChariot:
    """Tests for DELETE /api/chariots/{chariot_id}"""

    @patch("app.routes.chariots.chariot_repo")
    def test_delete_chariot_success(self, mock_repo, client):
        mock_repo.delete = AsyncMock(return_value=True)
        response = client.delete("/api/chariots/chariot-001", headers=AUTH_HEADER)
        assert response.status_code == 204

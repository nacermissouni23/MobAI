"""
Tests for Emplacement endpoints: GET/POST/PUT/DELETE /api/emplacements/...
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_EMPLACEMENT = {
    "id": "emp-001",
    "x": 5,
    "y": 10,
    "z": 0,
    "floor": 1,
    "is_obstacle": False,
    "is_slot": True,
    "is_elevator": False,
    "is_road": False,
    "is_expedition": False,
    "product_id": "prod-001",
    "quantity": 50,
    "is_occupied": True,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListLocations:
    """Tests for GET /api/emplacements/locations"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_list_locations(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_EMPLACEMENT])
        response = client.get("/api/emplacements/locations", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1

    @patch("app.routes.emplacement.emplacement_repo")
    def test_list_locations_filter_floor(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_EMPLACEMENT])
        response = client.get("/api/emplacements/locations?floor=1", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestGetLocation:
    """Tests for GET /api/emplacements/locations/{location_id}"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_get_location_success(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_EMPLACEMENT)
        response = client.get("/api/emplacements/locations/emp-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["id"] == "emp-001"


class TestAvailableSlots:
    """Tests for GET /api/emplacements/available-slots"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_available_slots(self, mock_repo, client):
        mock_repo.get_available_slots = AsyncMock(return_value=[])
        response = client.get("/api/emplacements/available-slots", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestOccupiedSlots:
    """Tests for GET /api/emplacements/occupied-slots"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_occupied_slots(self, mock_repo, client):
        mock_repo.get_occupied_slots = AsyncMock(return_value=[MOCK_EMPLACEMENT])
        response = client.get("/api/emplacements/occupied-slots", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestExpeditionZones:
    """Tests for GET /api/emplacements/expedition-zones"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_expedition_zones(self, mock_repo, client):
        mock_repo.get_expedition_zones = AsyncMock(return_value=[])
        response = client.get("/api/emplacements/expedition-zones", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestCreateLocation:
    """Tests for POST /api/emplacements/locations"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_create_location(self, mock_repo, client):
        mock_repo.create = AsyncMock(return_value=MOCK_EMPLACEMENT)
        response = client.post(
            "/api/emplacements/locations",
            json={"x": 5, "y": 10, "floor": 1, "is_slot": True},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201


class TestUpdateLocation:
    """Tests for PUT /api/emplacements/locations/{location_id}"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_update_location(self, mock_repo, client):
        updated = {**MOCK_EMPLACEMENT, "quantity": 100}
        mock_repo.update = AsyncMock(return_value=updated)
        response = client.put(
            "/api/emplacements/locations/emp-001",
            json={"quantity": 100},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200


class TestDeleteLocation:
    """Tests for DELETE /api/emplacements/locations/{location_id}"""

    @patch("app.routes.emplacement.emplacement_repo")
    def test_delete_location(self, mock_repo, client):
        mock_repo.delete = AsyncMock(return_value=True)
        response = client.delete("/api/emplacements/locations/emp-001", headers=AUTH_HEADER)
        assert response.status_code == 204

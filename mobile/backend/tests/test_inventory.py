"""
Tests for Inventory endpoints: GET/POST /api/inventory/...
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_LOCATION = {
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

MOCK_LEDGER = {
    "id": "ledger-001",
    "x": 5,
    "y": 10,
    "z": 0,
    "floor": 1,
    "product_id": "prod-001",
    "quantity": 50,
    "recorded_at": "2026-01-01T00:00:00",
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestGetStock:
    """Tests for GET /api/inventory/stock"""

    @patch("app.routes.inventory.emplacement_repo")
    def test_get_stock(self, mock_repo, client):
        mock_repo.query = AsyncMock(return_value=[MOCK_LOCATION])
        response = client.get("/api/inventory/stock", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestGetProductStock:
    """Tests for GET /api/inventory/stock/product/{product_id}"""

    @patch("app.routes.inventory.emplacement_repo")
    def test_get_product_stock(self, mock_repo, client):
        mock_repo.get_product_locations = AsyncMock(return_value=[MOCK_LOCATION])
        response = client.get("/api/inventory/stock/product/prod-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestGetLedger:
    """Tests for GET /api/inventory/ledger"""

    @patch("app.routes.inventory.ledger_repo")
    def test_get_ledger(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_LEDGER])
        response = client.get("/api/inventory/ledger", headers=AUTH_HEADER)
        assert response.status_code == 200

    @patch("app.routes.inventory.ledger_repo")
    def test_get_ledger_filter_product(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_LEDGER])
        response = client.get("/api/inventory/ledger?product_id=prod-001", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestGetLedgerByLocation:
    """Tests for GET /api/inventory/ledger/location"""

    @patch("app.routes.inventory.ledger_repo")
    def test_get_ledger_by_location(self, mock_repo, client):
        mock_repo.get_by_location = AsyncMock(return_value=[MOCK_LEDGER])
        response = client.get(
            "/api/inventory/ledger/location?x=5&y=10&z=0&floor=1",
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200


class TestAdjustStock:
    """Tests for POST /api/inventory/adjust"""

    @patch("app.routes.inventory.ledger_repo")
    @patch("app.routes.inventory.emplacement_repo")
    def test_adjust_stock(self, mock_emp_repo, mock_ledger_repo, client):
        mock_emp_repo.get_by_coordinates = AsyncMock(return_value=MOCK_LOCATION)
        mock_emp_repo.update = AsyncMock(return_value={})
        mock_ledger_repo.create = AsyncMock(return_value=MOCK_LEDGER)
        response = client.post(
            "/api/inventory/adjust",
            json={
                "x": 5,
                "y": 10,
                "z": 0,
                "floor": 1,
                "product_id": "prod-001",
                "quantity": 10,
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201


class TestLowStock:
    """Tests for GET /api/inventory/low-stock"""

    @patch("app.routes.inventory.emplacement_repo")
    def test_low_stock(self, mock_repo, client):
        low = {**MOCK_LOCATION, "quantity": 2}
        mock_repo.get_occupied_slots = AsyncMock(return_value=[low])
        response = client.get("/api/inventory/low-stock?threshold=5", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestStockSummary:
    """Tests for GET /api/inventory/stock-summary"""

    @patch("app.routes.inventory.emplacement_repo")
    def test_stock_summary(self, mock_repo, client):
        mock_repo.get_occupied_slots = AsyncMock(return_value=[MOCK_LOCATION])
        response = client.get("/api/inventory/stock-summary", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["product_id"] == "prod-001"

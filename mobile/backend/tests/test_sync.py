"""
Tests for Sync endpoints: operations sync, stock-movement sync, full sync, status.
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, AUTH_HEADER,
    override_current_user,
)
from app.utils.dependencies import get_current_user

MOCK_OPERATION = {
    "id": "op-001",
    "type": "receipt",
    "status": "pending",
    "product_id": "prod-001",
    "quantity": 100,
    "local_id": "local-op-001",
    "synced_at": "2026-01-01T00:00:00",
    "synced_from": "employee-001",
    "updated_at": "2026-06-01T00:00:00",
    "created_at": "2026-01-01T00:00:00",
}

MOCK_LEDGER = {
    "id": "ledger-001",
    "product_id": "prod-001",
    "quantity": 50,
    "x": 5,
    "y": 10,
    "z": 0,
    "floor": 1,
    "local_id": "local-mvmt-001",
    "synced_at": "2026-01-01T00:00:00",
    "created_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestSyncOperations:
    """Tests for POST /api/sync/operations"""

    @patch("app.routes.sync.operation_repo")
    def test_sync_new_operations(self, mock_repo, client):
        mock_repo.find_one = AsyncMock(return_value=None)
        mock_repo.create = AsyncMock(return_value=MOCK_OPERATION)
        response = client.post(
            "/api/sync/operations",
            json={
                "operations": [
                    {
                        "local_id": "local-op-001",
                        "data": {"type": "receipt", "product_id": "prod-001", "quantity": 100},
                    }
                ]
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        body = response.json()
        assert len(body["synced"]) == 1
        assert body["synced"][0]["local_id"] == "local-op-001"

    @patch("app.routes.sync.operation_repo")
    def test_sync_duplicate_skipped(self, mock_repo, client):
        mock_repo.find_one = AsyncMock(return_value=MOCK_OPERATION)
        response = client.post(
            "/api/sync/operations",
            json={
                "operations": [
                    {
                        "local_id": "local-op-001",
                        "data": {"type": "receipt"},
                    }
                ]
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        body = response.json()
        assert len(body["skipped"]) == 1

    @patch("app.routes.sync.operation_repo")
    def test_sync_empty_list(self, mock_repo, client):
        response = client.post(
            "/api/sync/operations",
            json={"operations": []},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        body = response.json()
        assert body["synced"] == []
        assert body["skipped"] == []
        assert body["errors"] == []


class TestSyncStockMovements:
    """Tests for POST /api/sync/stock-movements"""

    @patch("app.routes.sync.emplacement_repo")
    @patch("app.routes.sync.ledger_repo")
    def test_sync_new_movements(self, mock_ledger, mock_emp, client):
        mock_ledger.find_one = AsyncMock(return_value=None)
        mock_ledger.create = AsyncMock(return_value=MOCK_LEDGER)
        mock_emp.get_by_coordinates = AsyncMock(return_value={
            "id": "emp-001", "quantity": 50, "product_id": "prod-001"
        })
        mock_emp.update = AsyncMock(return_value={})
        response = client.post(
            "/api/sync/stock-movements",
            json={
                "movements": [
                    {
                        "local_id": "local-mvmt-001",
                        "data": {
                            "product_id": "prod-001",
                            "quantity": 10,
                            "x": 5, "y": 10, "z": 0, "floor": 1,
                        },
                    }
                ]
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        body = response.json()
        assert len(body["synced"]) == 1


class TestFullSync:
    """Tests for POST /api/sync/full-sync"""

    @patch("app.routes.sync.emplacement_repo")
    @patch("app.routes.sync.ledger_repo")
    @patch("app.routes.sync.operation_repo")
    def test_full_sync(self, mock_op, mock_ledger, mock_emp, client):
        # Operations: one new
        mock_op.find_one = AsyncMock(return_value=None)
        mock_op.create = AsyncMock(return_value=MOCK_OPERATION)
        mock_op.get_all = AsyncMock(return_value=[MOCK_OPERATION])

        # Movements: none
        mock_ledger.get_all = AsyncMock(return_value=[])

        response = client.post(
            "/api/sync/full-sync",
            json={
                "operations": [
                    {
                        "local_id": "local-op-001",
                        "data": {"type": "receipt"},
                    }
                ],
                "movements": [],
                "last_sync_timestamp": "2026-05-01T00:00:00",
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        body = response.json()
        assert "operations_sync" in body
        assert "movements_sync" in body
        assert "server_updates" in body
        # server_updates should include the operation updated after last_sync_timestamp
        assert len(body["server_updates"]["operations"]) == 1


class TestSyncStatus:
    """Tests for GET /api/sync/status"""

    @patch("app.routes.sync.ledger_repo")
    @patch("app.routes.sync.operation_repo")
    def test_status(self, mock_op, mock_ledger, client):
        mock_op.count = AsyncMock(return_value=42)
        mock_ledger.count = AsyncMock(return_value=100)
        response = client.get("/api/sync/status", headers=AUTH_HEADER)
        assert response.status_code == 200
        body = response.json()
        assert body["status"] == "online"
        assert body["total_operations"] == 42
        assert body["total_ledger_entries"] == 100
        assert body["user_id"] == "employee-001"

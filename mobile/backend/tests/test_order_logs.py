"""
Tests for OrderLog endpoints: GET /api/order-logs/...
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, MOCK_SUPERVISOR, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_ORDER_LOG = {
    "id": "olog-001",
    "order_id": "order-001",
    "action": "created",
    "order_type": "command",
    "supervisor_id": "supervisor-001",
    "product_id": "prod-001",
    "quantity": 10,
    "date": "2026-01-01T00:00:00",
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListOrderLogs:
    """Tests for GET /api/order-logs/"""

    @patch("app.routes.order_logs.order_log_repo")
    def test_list_logs(self, mock_repo, client):
        mock_repo.get_all = AsyncMock(return_value=[MOCK_ORDER_LOG])
        response = client.get("/api/order-logs/", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestGetOrderLogs:
    """Tests for GET /api/order-logs/order/{order_id}"""

    @patch("app.routes.order_logs.order_log_repo")
    def test_get_logs_by_order(self, mock_repo, client):
        mock_repo.get_by_order = AsyncMock(return_value=[MOCK_ORDER_LOG])
        response = client.get(
            "/api/order-logs/order/order-001",
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert len(response.json()) == 1
        assert response.json()[0]["order_id"] == "order-001"

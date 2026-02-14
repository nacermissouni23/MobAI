"""
Tests for Order endpoints: GET/POST/DELETE/PUT /api/orders/...
Including validation workflow and preparation generation.
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, MOCK_SUPERVISOR, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_ORDER = {
    "id": "order-001",
    "type": "command",
    "status": "pending",
    "supervisor_id": "supervisor-001",
    "validator_id": None,
    "validated_at": None,
    "product_id": "prod-001",
    "quantity": 10,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}

MOCK_VALIDATED_ORDER = {
    **MOCK_ORDER,
    "status": "validated",
    "validator_id": "supervisor-001",
    "validated_at": "2026-06-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListOrders:
    """Tests for GET /api/orders/"""

    @patch("app.routes.orders.order_repo")
    def test_list_orders(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_ORDER])
        response = client.get("/api/orders/", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) >= 1

    @patch("app.routes.orders.order_repo")
    def test_list_orders_filter_type(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_ORDER])
        response = client.get("/api/orders/?order_type=command", headers=AUTH_HEADER)
        assert response.status_code == 200

    @patch("app.routes.orders.order_repo")
    def test_list_orders_filter_status(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_ORDER])
        response = client.get("/api/orders/?status=pending", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestPendingOrders:
    """Tests for GET /api/orders/pending"""

    @patch("app.routes.orders.order_repo")
    def test_list_pending_orders(self, mock_repo, client):
        mock_repo.get_pending = AsyncMock(return_value=[MOCK_ORDER])
        response = client.get("/api/orders/pending", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestGetOrder:
    """Tests for GET /api/orders/{order_id}"""

    @patch("app.routes.orders.order_repo")
    def test_get_order_success(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_ORDER)
        response = client.get("/api/orders/order-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["id"] == "order-001"
        assert response.json()["status"] == "pending"


class TestGetOrderLogs:
    """Tests for GET /api/orders/{order_id}/logs"""

    @patch("app.routes.orders.order_log_repo")
    def test_get_order_logs(self, mock_log_repo, client):
        mock_log_repo.get_by_order = AsyncMock(return_value=[{
            "id": "log-001",
            "order_id": "order-001",
            "action": "created",
            "order_type": "command",
            "supervisor_id": "supervisor-001",
            "product_id": "prod-001",
            "quantity": 10,
            "date": "2026-01-01T00:00:00",
            "created_at": "2026-01-01T00:00:00",
            "updated_at": "2026-01-01T00:00:00",
        }])
        response = client.get("/api/orders/order-001/logs", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestCreateOrder:
    """Tests for POST /api/orders/"""

    @patch("app.routes.orders.order_log_repo")
    @patch("app.routes.orders.order_repo")
    def test_create_order(self, mock_repo, mock_log_repo, client):
        mock_repo.create = AsyncMock(return_value=MOCK_ORDER)
        mock_log_repo.create = AsyncMock(return_value={})
        response = client.post(
            "/api/orders/",
            json={"product_id": "prod-001", "quantity": 10},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201
        mock_log_repo.create.assert_called_once()


class TestValidateOrder:
    """Tests for PUT /api/orders/{order_id}/validate"""

    @patch("app.routes.orders.operation_log_repo")
    @patch("app.routes.orders.operation_repo")
    @patch("app.routes.orders.user_repo")
    @patch("app.routes.orders.order_log_repo")
    @patch("app.routes.orders.order_repo")
    def test_validate_command_order(
        self, mock_order_repo, mock_log_repo, mock_user_repo,
        mock_op_repo, mock_op_log_repo, client,
    ):
        mock_order_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_ORDER)
        mock_order_repo.update = AsyncMock(return_value=MOCK_VALIDATED_ORDER)
        mock_log_repo.create = AsyncMock(return_value={})
        mock_user_repo.get_active_employees = AsyncMock(return_value=[
            {"id": "employee-001", "name": "E1", "role": "employee", "is_active": True},
        ])
        mock_op_repo.create = AsyncMock(return_value={
            "id": "op-new", "type": "receipt", "status": "pending",
            "product_id": "prod-001", "quantity": 10,
            "employee_id": "employee-001", "chariot_id": None,
            "order_id": "order-001", "emplacement_id": None,
            "source_emplacement_id": None, "suggested_route": None,
            "validator_id": None, "validated_at": None,
            "created_at": "2026-06-01T00:00:00", "updated_at": "2026-06-01T00:00:00",
        })
        mock_op_log_repo.create = AsyncMock(return_value={})

        response = client.put("/api/orders/order-001/validate", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["status"] == "validated"
        # Should have created a receipt operation
        mock_op_repo.create.assert_called_once()

    @patch("app.routes.orders.order_repo")
    def test_validate_already_validated(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_VALIDATED_ORDER)
        response = client.put("/api/orders/order-001/validate", headers=AUTH_HEADER)
        assert response.status_code == 409


class TestGeneratePreparationOrders:
    """Tests for POST /api/orders/generate-preparation"""

    @patch("app.routes.orders.order_log_repo")
    @patch("app.routes.orders.order_repo")
    @patch("app.routes.orders.forecasting_engine")
    def test_generate_preparation(self, mock_engine, mock_repo, mock_log_repo, client):
        mock_engine.predict_preparation_orders = AsyncMock(return_value=[
            {"product_id": "prod-001", "predicted_quantity": 50},
        ])
        mock_repo.create = AsyncMock(return_value={
            **MOCK_ORDER, "type": "preparation", "quantity": 50,
        })
        mock_log_repo.create = AsyncMock(return_value={})

        response = client.post(
            "/api/orders/generate-preparation",
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert len(response.json()) == 1

    @patch("app.routes.orders.order_log_repo")
    @patch("app.routes.orders.order_repo")
    @patch("app.routes.orders.forecasting_engine")
    def test_generate_preparation_empty(self, mock_engine, mock_repo, mock_log_repo, client):
        mock_engine.predict_preparation_orders = AsyncMock(return_value=[])
        response = client.post(
            "/api/orders/generate-preparation",
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert response.json() == []


class TestDeleteOrder:
    """Tests for DELETE /api/orders/{order_id}"""

    @patch("app.routes.orders.order_repo")
    def test_delete_order(self, mock_repo, client):
        mock_repo.delete = AsyncMock(return_value=True)
        response = client.delete("/api/orders/order-001", headers=AUTH_HEADER)
        assert response.status_code == 204

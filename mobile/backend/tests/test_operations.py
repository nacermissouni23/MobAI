"""
Tests for Operation endpoints: GET/POST/PUT/DELETE /api/operations/...
Including approve, validate workflow, and AI integration triggers.
"""

import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, MOCK_SUPERVISOR, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_OPERATION = {
    "id": "op-001",
    "type": "receipt",
    "status": "pending",
    "employee_id": "employee-001",
    "validator_id": None,
    "validated_at": None,
    "chariot_id": None,
    "order_id": None,
    "emplacement_id": None,
    "source_emplacement_id": None,
    "suggested_route": None,
    "product_id": "prod-001",
    "quantity": 100,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}

MOCK_CHARIOT = {
    "id": "chariot-001",
    "is_active": True,
    "assigned_to_operation_id": None,
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListOperations:
    """Tests for GET /api/operations/"""

    @patch("app.routes.operations.operation_repo")
    def test_list_operations(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_OPERATION])
        response = client.get("/api/operations/", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1

    @patch("app.routes.operations.operation_repo")
    def test_list_operations_filter_type(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_OPERATION])
        response = client.get("/api/operations/?operation_type=receipt", headers=AUTH_HEADER)
        assert response.status_code == 200

    @patch("app.routes.operations.operation_repo")
    def test_list_operations_filter_status(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_OPERATION])
        response = client.get("/api/operations/?status=pending", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestPendingOperations:
    """Tests for GET /api/operations/pending"""

    @patch("app.routes.operations.operation_repo")
    def test_list_pending(self, mock_repo, client):
        mock_repo.get_by_status = AsyncMock(return_value=[MOCK_OPERATION])
        response = client.get("/api/operations/pending", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestGetOperation:
    """Tests for GET /api/operations/{operation_id}"""

    @patch("app.routes.operations.operation_repo")
    def test_get_operation(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_OPERATION)
        response = client.get("/api/operations/op-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["id"] == "op-001"
        assert response.json()["status"] == "pending"


class TestGetEmployeeOperations:
    """Tests for GET /api/operations/employee/{employee_id}/operations"""

    @patch("app.routes.operations.operation_repo")
    def test_get_employee_operations(self, mock_repo, client):
        mock_repo.get_by_employee = AsyncMock(return_value=[MOCK_OPERATION])
        response = client.get(
            "/api/operations/employee/employee-001/operations",
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestGetOperationLogs:
    """Tests for GET /api/operations/{operation_id}/logs"""

    @patch("app.routes.operations.operation_log_repo")
    def test_get_logs(self, mock_log_repo, client):
        mock_log_repo.get_by_operation = AsyncMock(return_value=[{
            "id": "log-001", "operation_id": "op-001", "action": "created",
        }])
        response = client.get("/api/operations/op-001/logs", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestDestinationInfo:
    """Tests for GET /api/operations/{operation_id}/destination-info"""

    @patch("app.routes.operations.emplacement_repo")
    @patch("app.routes.operations.operation_repo")
    def test_destination_info_success(self, mock_op_repo, mock_emp_repo, client):
        mock_op_repo.get_by_id_or_raise = AsyncMock(
            return_value={**MOCK_OPERATION, "emplacement_id": "emp-001"}
        )
        mock_emp_repo.get_by_id = AsyncMock(return_value={
            "id": "emp-001", "x": 5, "y": 10, "z": 0, "floor": 1,
            "is_slot": True, "is_occupied": False, "is_expedition": False,
            "product_id": None, "quantity": 0,
        })
        response = client.get("/api/operations/op-001/destination-info", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert data["emplacement_id"] == "emp-001"
        assert data["x"] == 5

    @patch("app.routes.operations.operation_repo")
    def test_destination_info_no_emplacement(self, mock_op_repo, client):
        mock_op_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_OPERATION)
        response = client.get("/api/operations/op-001/destination-info", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert "error" in response.json()


class TestCreateReceiptOperation:
    """Tests for POST /api/operations/receipt"""

    @patch("app.routes.operations.operation_log_repo")
    @patch("app.routes.operations.operation_repo")
    def test_create_receipt(self, mock_repo, mock_log_repo, client):
        mock_repo.create = AsyncMock(return_value=MOCK_OPERATION)
        mock_log_repo.create = AsyncMock(return_value={})
        response = client.post(
            "/api/operations/receipt",
            json={
                "type": "receipt",
                "product_id": "prod-001",
                "quantity": 100,
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201
        mock_log_repo.create.assert_called_once()


class TestCreateTransferOperation:
    """Tests for POST /api/operations/transfer"""

    @patch("app.routes.operations.operation_log_repo")
    @patch("app.routes.operations.operation_repo")
    def test_create_transfer(self, mock_repo, mock_log_repo, client):
        transfer_op = {**MOCK_OPERATION, "type": "transfer"}
        mock_repo.create = AsyncMock(return_value=transfer_op)
        mock_log_repo.create = AsyncMock(return_value={})
        response = client.post(
            "/api/operations/transfer",
            json={
                "type": "transfer",
                "product_id": "prod-001",
                "quantity": 50,
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201


class TestApproveOperation:
    """Tests for PUT /api/operations/{operation_id}/approve"""

    @patch("app.routes.operations.operation_log_repo")
    @patch("app.routes.operations.chariot_repo")
    @patch("app.routes.operations.emplacement_repo")
    @patch("app.routes.operations.operation_repo")
    def test_approve_transfer(
        self, mock_op_repo, mock_emp_repo, mock_chariot_repo,
        mock_log_repo, client,
    ):
        transfer_op = {
            **MOCK_OPERATION,
            "type": "transfer",
            "emplacement_id": "emp-001",
            "source_emplacement_id": "emp-002",
        }
        mock_op_repo.get_by_id_or_raise = AsyncMock(return_value=transfer_op)
        approved = {
            **transfer_op,
            "status": "in_progress",
            "chariot_id": "chariot-001",
        }
        mock_op_repo.update = AsyncMock(return_value=approved)
        mock_chariot_repo.get_available = AsyncMock(return_value=[MOCK_CHARIOT])
        mock_chariot_repo.update = AsyncMock(return_value={})
        mock_emp_repo.get_by_id = AsyncMock(return_value={
            "id": "emp-001", "x": 5, "y": 10, "floor": 1,
        })
        mock_log_repo.create = AsyncMock(return_value={})

        # Patch the pathfinder to avoid loading grid files
        with patch("app.routes.operations.get_pathfinder") as mock_pf:
            pf_instance = MagicMock()
            pf_instance.find_path.return_value = {"path": [(0, 0, 0), (1, 1, 0)]}
            mock_pf.return_value = pf_instance

            response = client.put("/api/operations/op-001/approve", headers=AUTH_HEADER)
            assert response.status_code == 200
            assert response.json()["status"] == "in_progress"

    @patch("app.routes.operations.operation_repo")
    def test_approve_not_pending(self, mock_op_repo, client):
        in_progress_op = {**MOCK_OPERATION, "status": "in_progress"}
        mock_op_repo.get_by_id_or_raise = AsyncMock(return_value=in_progress_op)
        response = client.put("/api/operations/op-001/approve", headers=AUTH_HEADER)
        assert response.status_code == 409


class TestValidateOperation:
    """Tests for PUT /api/operations/{operation_id}/validate"""

    @patch("app.routes.operations.operation_log_repo")
    @patch("app.routes.operations.product_repo")
    @patch("app.routes.operations.storage_optimizer")
    @patch("app.routes.operations.emplacement_repo")
    @patch("app.routes.operations.user_repo")
    @patch("app.routes.operations.operation_repo")
    def test_validate_receipt_operation(
        self, mock_op_repo, mock_user_repo, mock_emp_repo,
        mock_storage, mock_product_repo, mock_log_repo, client,
    ):
        """Validating a receipt should increment reception_freq and create a transfer."""
        mock_op_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_OPERATION)
        validated = {
            **MOCK_OPERATION,
            "status": "validated",
            "validator_id": "employee-001",
            "validated_at": "2026-06-01T00:00:00",
        }
        mock_op_repo.update = AsyncMock(return_value=validated)
        mock_op_repo.create = AsyncMock(return_value={
            "id": "op-transfer", "type": "transfer", "status": "pending",
            "product_id": "prod-001", "quantity": 100,
            "employee_id": "employee-001", "chariot_id": None,
            "order_id": None, "emplacement_id": "emp-001",
            "source_emplacement_id": "emp-002", "suggested_route": None,
            "validator_id": None, "validated_at": None,
            "created_at": "2026-06-01T00:00:00", "updated_at": "2026-06-01T00:00:00",
        })
        mock_product_repo.get_by_id = AsyncMock(return_value={
            "id": "prod-001", "reception_freq": 5.0,
        })
        mock_product_repo.update = AsyncMock(return_value={})
        mock_storage.suggest_slot = AsyncMock(return_value=[
            {"id": "emp-001", "x": 5, "y": 10, "floor": 1},
        ])
        mock_emp_repo.get_expedition_zones = AsyncMock(return_value=[
            {"id": "emp-002", "x": 0, "y": 0, "floor": 0, "is_expedition": True},
        ])
        mock_emp_repo.get_by_id = AsyncMock(return_value={
            "id": "emp-001", "x": 5, "y": 10, "floor": 1,
        })
        mock_user_repo.get_active_employees = AsyncMock(return_value=[])
        mock_log_repo.create = AsyncMock(return_value={})

        with patch("app.routes.operations.get_pathfinder") as mock_pf:
            pf_instance = MagicMock()
            pf_instance.find_path.return_value = {"path": [(0, 0, 0), (5, 10, 1)]}
            mock_pf.return_value = pf_instance

            response = client.put("/api/operations/op-001/validate", headers=AUTH_HEADER)
            assert response.status_code == 200
            assert response.json()["status"] == "validated"
            # Reception freq should have been incremented
            mock_product_repo.update.assert_called_once()
            call_args = mock_product_repo.update.call_args
            assert call_args[0][1]["reception_freq"] == 6.0

    @patch("app.routes.operations.operation_log_repo")
    @patch("app.routes.operations.emplacement_repo")
    @patch("app.routes.operations.chariot_repo")
    @patch("app.routes.operations.operation_repo")
    def test_validate_transfer_updates_stock(
        self, mock_op_repo, mock_chariot_repo, mock_emp_repo,
        mock_log_repo, client,
    ):
        """Validating a transfer should update destination emplacement stock."""
        transfer_op = {
            **MOCK_OPERATION,
            "type": "transfer",
            "status": "in_progress",
            "emplacement_id": "emp-001",
            "chariot_id": "chariot-001",
        }
        mock_op_repo.get_by_id_or_raise = AsyncMock(return_value=transfer_op)
        validated = {**transfer_op, "status": "validated", "validator_id": "employee-001"}
        mock_op_repo.update = AsyncMock(return_value=validated)
        mock_emp_repo.get_by_id = AsyncMock(return_value={
            "id": "emp-001", "quantity": 0, "product_id": None,
        })
        mock_emp_repo.update = AsyncMock(return_value={})
        mock_chariot_repo.update = AsyncMock(return_value={})
        mock_log_repo.create = AsyncMock(return_value={})

        response = client.put("/api/operations/op-001/validate", headers=AUTH_HEADER)
        assert response.status_code == 200
        # Emplacement stock should be updated
        mock_emp_repo.update.assert_called_once()
        emp_update_args = mock_emp_repo.update.call_args[0][1]
        assert emp_update_args["quantity"] == 100
        assert emp_update_args["is_occupied"] is True
        # Chariot should be released
        mock_chariot_repo.update.assert_called_once()

    @patch("app.routes.operations.operation_repo")
    def test_validate_already_validated(self, mock_op_repo, client):
        validated_op = {**MOCK_OPERATION, "status": "validated"}
        mock_op_repo.get_by_id_or_raise = AsyncMock(return_value=validated_op)
        response = client.put("/api/operations/op-001/validate", headers=AUTH_HEADER)
        assert response.status_code == 409


class TestDeleteOperation:
    """Tests for DELETE /api/operations/{operation_id}"""

    @patch("app.routes.operations.chariot_repo")
    @patch("app.routes.operations.operation_repo")
    def test_delete_operation(self, mock_repo, mock_chariot_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_OPERATION)
        mock_repo.delete = AsyncMock(return_value=True)
        response = client.delete("/api/operations/op-001", headers=AUTH_HEADER)
        assert response.status_code == 204

    @patch("app.routes.operations.chariot_repo")
    @patch("app.routes.operations.operation_repo")
    def test_delete_operation_releases_chariot(self, mock_repo, mock_chariot_repo, client):
        op_with_chariot = {**MOCK_OPERATION, "chariot_id": "chariot-001"}
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=op_with_chariot)
        mock_repo.delete = AsyncMock(return_value=True)
        mock_chariot_repo.update = AsyncMock(return_value={})
        response = client.delete("/api/operations/op-001", headers=AUTH_HEADER)
        assert response.status_code == 204
        mock_chariot_repo.update.assert_called_once()

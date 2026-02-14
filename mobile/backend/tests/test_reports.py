"""
Tests for Report endpoints: CRUD, operation reports, statistics.
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, MOCK_SUPERVISOR, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_REPORT = {
    "id": "report-001",
    "operation_id": "op-001",
    "physical_damage": True,
    "missing_quantity": 5,
    "extra_quality": 0,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListReports:
    """Tests for GET /api/reports/"""

    @patch("app.routes.reports.report_repo")
    def test_list_all(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_REPORT])
        response = client.get("/api/reports/", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1

    @patch("app.routes.reports.report_repo")
    def test_list_filter_operation(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_REPORT])
        response = client.get("/api/reports/?operation_id=op-001", headers=AUTH_HEADER)
        assert response.status_code == 200

    @patch("app.routes.reports.report_repo")
    def test_list_damage_only(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_REPORT])
        response = client.get("/api/reports/?damage_only=true", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestGetReport:
    """Tests for GET /api/reports/{report_id}"""

    @patch("app.routes.reports.report_repo")
    def test_get_success(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_REPORT)
        response = client.get("/api/reports/report-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["id"] == "report-001"


class TestCreateReport:
    """Tests for POST /api/reports/"""

    @patch("app.routes.reports.report_repo")
    def test_create_report(self, mock_repo, client):
        mock_repo.create = AsyncMock(return_value=MOCK_REPORT)
        response = client.post(
            "/api/reports/",
            json={
                "operation_id": "op-001",
                "physical_damage": True,
                "missing_quantity": 5,
                "extra_quality": 0,
            },
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201
        assert response.json()["id"] == "report-001"


class TestDeleteReport:
    """Tests for DELETE /api/reports/{report_id}"""

    @patch("app.routes.reports.report_repo")
    def test_delete(self, mock_repo, client):
        mock_repo.delete = AsyncMock(return_value=None)
        response = client.delete("/api/reports/report-001", headers=AUTH_HEADER)
        assert response.status_code == 204


class TestOperationReports:
    """Tests for GET /api/reports/operation/{operation_id}/reports"""

    @patch("app.routes.reports.report_repo")
    def test_operation_reports(self, mock_repo, client):
        mock_repo.get_by_operation = AsyncMock(return_value=[MOCK_REPORT])
        response = client.get(
            "/api/reports/operation/op-001/reports",
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200
        assert len(response.json()) == 1


class TestReportStatistics:
    """Tests for GET /api/reports/statistics/summary"""

    @patch("app.routes.reports.report_repo")
    def test_summary(self, mock_repo, client):
        mock_repo.get_all = AsyncMock(return_value=[
            MOCK_REPORT,
            {**MOCK_REPORT, "id": "report-002", "physical_damage": False, "missing_quantity": 0, "extra_quality": 3},
        ])
        response = client.get("/api/reports/statistics/summary", headers=AUTH_HEADER)
        assert response.status_code == 200
        data = response.json()
        assert data["total_reports"] == 2
        assert data["damage_reports"] == 1
        assert data["reports_with_missing"] == 1
        assert data["reports_with_extra"] == 1
        assert data["total_missing_quantity"] == 5
        assert data["total_extra_quality"] == 3

"""
Tests for Product endpoints: GET/POST/PUT/DELETE /api/products/...
"""

import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from tests.conftest import (
    MOCK_EMPLOYEE, MOCK_SUPERVISOR, AUTH_HEADER,
    override_current_user, override_supervisor_user,
)
from app.utils.dependencies import get_current_user, get_supervisor_user

MOCK_PRODUCT = {
    "id": "prod-001",
    "sku": "SKU-001",
    "nom_produit": "Test Product",
    "unite_mesure": "pcs",
    "categorie": "electronics",
    "actif": True,
    "colisage_fardeau": 10,
    "colisage_palette": 100,
    "volume_pcs": 0.5,
    "poids": 1.0,
    "is_gerbable": False,
    "demand_freq": 5.0,
    "reception_freq": 3.0,
    "delivery_freq": 1.0,
    "created_at": "2026-01-01T00:00:00",
    "updated_at": "2026-01-01T00:00:00",
}


@pytest.fixture
def client(app):
    app.dependency_overrides[get_current_user] = override_current_user(MOCK_EMPLOYEE)
    app.dependency_overrides[get_supervisor_user] = override_supervisor_user()
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestListProducts:
    """Tests for GET /api/products/"""

    @patch("app.routes.products.product_repo")
    def test_list_products(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_PRODUCT])
        response = client.get("/api/products/", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert len(response.json()) == 1

    @patch("app.routes.products.product_repo")
    def test_list_products_filter_category(self, mock_repo, client):
        mock_repo.get_filtered = AsyncMock(return_value=[MOCK_PRODUCT])
        response = client.get("/api/products/?category=electronics", headers=AUTH_HEADER)
        assert response.status_code == 200


class TestGetProduct:
    """Tests for GET /api/products/{product_id}"""

    @patch("app.routes.products.product_repo")
    def test_get_product_success(self, mock_repo, client):
        mock_repo.get_by_id_or_raise = AsyncMock(return_value=MOCK_PRODUCT)
        response = client.get("/api/products/prod-001", headers=AUTH_HEADER)
        assert response.status_code == 200
        assert response.json()["sku"] == "SKU-001"


class TestGetProductBySku:
    """Tests for GET /api/products/sku/{sku}"""

    @patch("app.routes.products.product_repo")
    def test_get_by_sku_success(self, mock_repo, client):
        mock_repo.get_by_sku = AsyncMock(return_value=MOCK_PRODUCT)
        response = client.get("/api/products/sku/SKU-001", headers=AUTH_HEADER)
        assert response.status_code == 200

    @patch("app.routes.products.product_repo")
    def test_get_by_sku_not_found(self, mock_repo, client):
        mock_repo.get_by_sku = AsyncMock(return_value=None)
        response = client.get("/api/products/sku/NONEXISTENT", headers=AUTH_HEADER)
        assert response.status_code == 404


class TestCreateProduct:
    """Tests for POST /api/products/"""

    @patch("app.routes.products.product_repo")
    def test_create_product_success(self, mock_repo, client):
        mock_repo.get_by_sku = AsyncMock(return_value=None)
        mock_repo.create = AsyncMock(return_value=MOCK_PRODUCT)
        response = client.post(
            "/api/products/",
            json={"sku": "SKU-001", "nom_produit": "Test Product"},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 201

    @patch("app.routes.products.product_repo")
    def test_create_product_duplicate_sku(self, mock_repo, client):
        mock_repo.get_by_sku = AsyncMock(return_value=MOCK_PRODUCT)
        response = client.post(
            "/api/products/",
            json={"sku": "SKU-001", "nom_produit": "Test Product"},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 409


class TestUpdateProduct:
    """Tests for PUT /api/products/{product_id}"""

    @patch("app.routes.products.product_repo")
    def test_update_product_success(self, mock_repo, client):
        updated = {**MOCK_PRODUCT, "nom_produit": "Updated Product"}
        mock_repo.update = AsyncMock(return_value=updated)
        response = client.put(
            "/api/products/prod-001",
            json={"nom_produit": "Updated Product"},
            headers=AUTH_HEADER,
        )
        assert response.status_code == 200


class TestDeleteProduct:
    """Tests for DELETE /api/products/{product_id}"""

    @patch("app.routes.products.product_repo")
    def test_delete_product_success(self, mock_repo, client):
        mock_repo.delete = AsyncMock(return_value=True)
        response = client.delete("/api/products/prod-001", headers=AUTH_HEADER)
        assert response.status_code == 204

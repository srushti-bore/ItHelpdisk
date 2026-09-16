import pytest
from fastapi.testclient import TestClient
from backend.main import app


def test_health_check_endpoint():
    """Verifies that the /api/v1/health endpoint returns a valid response shape per SRS §3.8."""
    with TestClient(app) as client:
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "db" in data
        assert "environment" in data
        assert "timestamp" in data

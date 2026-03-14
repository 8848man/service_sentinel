import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.core.database import Base, get_db

# Test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_database():
    """Setup and teardown test database"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def test_read_root():
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "operational"


def test_health_check():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_db_health():
    """Test database health check"""
    response = client.get("/health/db")
    assert response.status_code == 200
    assert response.json()["database"] == "connected"


def test_create_service():
    """Test service creation"""
    service_data = {
        "name": "Test Service",
        "description": "A test service",
        "endpoint_url": "https://httpbin.org/status/200",
        "http_method": "GET",
        "service_type": "https_api",
        "expected_status_codes": [200],
        "timeout_seconds": 10,
        "check_interval_seconds": 60,
        "failure_threshold": 3
    }

    response = client.post("/api/v1/services", json=service_data)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Service"
    assert data["is_active"] is True


def test_get_services():
    """Test getting all services"""
    # Create a service first
    service_data = {
        "name": "Test Service 2",
        "endpoint_url": "https://httpbin.org/status/200",
        "http_method": "GET",
        "service_type": "https_api"
    }
    client.post("/api/v1/services", json=service_data)

    # Get all services
    response = client.get("/api/v1/services")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) > 0


def test_get_service_by_id():
    """Test getting service by ID"""
    # Create a service
    service_data = {
        "name": "Test Service 3",
        "endpoint_url": "https://httpbin.org/status/200",
        "http_method": "GET",
        "service_type": "https_api"
    }
    create_response = client.post("/api/v1/services", json=service_data)
    service_id = create_response.json()["id"]

    # Get service by ID
    response = client.get(f"/api/v1/services/{service_id}")
    assert response.status_code == 200
    assert response.json()["id"] == service_id
    assert response.json()["name"] == "Test Service 3"


def test_update_service():
    """Test updating service"""
    # Create a service
    service_data = {
        "name": "Test Service 4",
        "endpoint_url": "https://httpbin.org/status/200",
        "http_method": "GET",
        "service_type": "https_api"
    }
    create_response = client.post("/api/v1/services", json=service_data)
    service_id = create_response.json()["id"]

    # Update service
    update_data = {
        "check_interval_seconds": 120,
        "failure_threshold": 5
    }
    response = client.patch(f"/api/v1/services/{service_id}", json=update_data)
    assert response.status_code == 200
    assert response.json()["check_interval_seconds"] == 120
    assert response.json()["failure_threshold"] == 5


def test_delete_service():
    """Test deleting service"""
    # Create a service
    service_data = {
        "name": "Test Service 5",
        "endpoint_url": "https://httpbin.org/status/200",
        "http_method": "GET",
        "service_type": "https_api"
    }
    create_response = client.post("/api/v1/services", json=service_data)
    service_id = create_response.json()["id"]

    # Delete service
    response = client.delete(f"/api/v1/services/{service_id}")
    assert response.status_code == 204

    # Verify deleted
    response = client.get(f"/api/v1/services/{service_id}")
    assert response.status_code == 404


def test_get_dashboard_overview():
    """Test dashboard overview endpoint"""
    response = client.get("/api/v1/dashboard/overview")
    assert response.status_code == 200
    data = response.json()
    assert "total_services" in data
    assert "services_healthy" in data
    assert "open_incidents" in data


def test_get_system_metrics():
    """Test system metrics endpoint"""
    response = client.get("/api/v1/dashboard/metrics")
    assert response.status_code == 200
    data = response.json()
    assert "total_services_monitored" in data
    assert "successful_checks_last_hour" in data


def test_get_incidents():
    """Test incidents endpoint"""
    response = client.get("/api/v1/incidents")
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "items" in data
    assert isinstance(data["items"], list)

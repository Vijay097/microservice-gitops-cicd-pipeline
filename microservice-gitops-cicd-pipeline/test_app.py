import pytest
from app import app

@pytest.fixture
def client():
    """Configures the app for testing"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_endpoint(client):
    """Verifies that the main home page loads successfully"""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Success! Project 1 is Live!" in response.data

def test_health_endpoint(client):
    """Verifies that the health check endpoint returns valid JSON"""
    response = client.get('/health')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data["status"] == "healthy"
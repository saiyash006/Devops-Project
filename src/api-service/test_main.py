from fastapi.testclient import TestClient
import pytest
import sys
import os

# Ensure the app can be imported
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'api-service')))

# We have to mock the DB and Redis for simple unit tests.
# This is a very basic unit test suite to pass the validation stage.
def test_health():
    # Import inside to avoid immediate DB connection on load
    from main import app
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

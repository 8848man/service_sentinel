"""
Test the bootstrap endpoint directly
"""
import sys
import traceback
from fastapi.testclient import TestClient

# Import app with all dependencies
try:
    from app.main import app
    from app.core.database import SessionLocal, Base, engine

    # Ensure database is set up
    Base.metadata.create_all(bind=engine)

    print("=" * 60)
    print("Testing Bootstrap Endpoint")
    print("=" * 60)
    print()

    # Create test client
    client = TestClient(app)

    # Test 1: Bootstrap endpoint exists and is accessible
    print("Test 1: Call POST /api/v3/projects/bootstrap")
    print("-" * 60)

    response = client.post(
        "/api/v3/projects/bootstrap",
        json={
            "name": "Test Guest Project",
            "description": "Testing bootstrap endpoint"
        }
    )

    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

    if response.status_code == 201:
        print("[SUCCESS] Bootstrap endpoint works!")
        data = response.json()
        api_key = data.get("api_key")
        project_id = data.get("project", {}).get("id")

        print(f"Project ID: {project_id}")
        print(f"API Key: {api_key[:30]}...")
        print()

        # Test 2: Use the API key to list projects
        print("Test 2: List projects with guest API key")
        print("-" * 60)

        response2 = client.get(
            "/api/v3/projects",
            headers={"X-API-Key": api_key}
        )

        print(f"Status Code: {response2.status_code}")
        print(f"Response: {response2.json()}")
        print()

        if response2.status_code == 200:
            print("[SUCCESS] Guest can list projects!")
        else:
            print("[FAIL] Guest cannot list projects")

        # Test 3: Access the specific project
        print("Test 3: Get specific project with guest API key")
        print("-" * 60)

        response3 = client.get(
            f"/api/v3/projects/{project_id}",
            headers={"X-API-Key": api_key}
        )

        print(f"Status Code: {response3.status_code}")
        print(f"Response: {response3.json()}")
        print()

        if response3.status_code == 200:
            print("[SUCCESS] Guest can access their project!")
        else:
            print("[FAIL] Guest cannot access project")

    else:
        print("[FAIL] Bootstrap endpoint failed")
        print(f"Error: {response.json()}")

    print("=" * 60)
    print("Test Complete")
    print("=" * 60)

except ImportError as e:
    print(f"[ERROR] Import failed: {e}")
    print()
    print("This might be due to missing dependencies.")
    print("Try installing: pip install google-generativeai")
    traceback.print_exc()

except Exception as e:
    print(f"[ERROR] Test failed: {e}")
    traceback.print_exc()

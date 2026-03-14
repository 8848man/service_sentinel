# API v3 Frontend Integration Guide

## Overview

This document defines how frontend applications should call ServiceSentinel API v3 endpoints. It serves as the contract between backend and frontend teams.

**Target Audience:** Frontend developers integrating with ServiceSentinel v3 APIs.

---

## 1. What Changed in v3

### Breaking Changes

- **Mandatory Authentication:** All v3 endpoints REQUIRE authentication. Unauthenticated requests will fail with `401 Unauthorized`.
- **Project-Scoped Resources:** All resources (services, incidents, dashboards) are strictly project-scoped. Global or project-less access is forbidden.
- **Ownership Validation:** Every request validates that the authenticated user/guest owns the specified project. Unauthorized access returns `403 Forbidden`.

### Key Differences from v2

| Feature | v2 | v3 |
|---------|----|----|
| Authentication | Optional (API key only) | **Mandatory** (Firebase JWT or API key) |
| Project Scoping | Enforced via path | **Strictly enforced** with ownership validation |
| User Types | Guest only (API key) | **Firebase users + Guest users** |
| Authorization Priority | N/A | Authorization header > X-API-Key header |

**Migration Impact:** v2-style unauthenticated requests WILL fail in v3.

---

## 2. Getting Started (Quick Setup Flow)

### For New Users (Firebase Authentication)

1. **Sign up** with Firebase Auth (handled by Firebase SDK)
2. **Obtain Firebase ID token:**
   ```javascript
   const token = await auth.currentUser.getIdToken();
   ```
3. **Create your first project:**
   ```javascript
   POST /api/v3/projects
   Headers: { Authorization: Bearer <token> }
   ```
4. **Start adding services** to your project

### For API Key Users

1. Contact the **project owner** (Firebase user) to generate an API key for you
2. Project owner creates API key via:
   ```javascript
   POST /api/v3/projects/{project_id}/api-keys
   Headers: { Authorization: Bearer <firebase_token> }
   ```
3. **Store the API key** securely (shown only once!)
4. **Use the API key** in all requests:
   ```javascript
   Headers: { X-API-Key: ss_your_key_here }
   ```

### User Type Capabilities

| Action | Firebase User | Guest (API Key) |
|--------|---------------|-----------------|
| Create projects | ✅ Yes | ❌ No |
| List own projects | ✅ Yes | ❌ No |
| Access project resources | ✅ Yes | ✅ Yes (if key matches) |
| Create API keys | ✅ Yes | ❌ No |
| Manage services/incidents | ✅ Yes | ✅ Yes (with valid key) |

---

## 3. Authentication Requirements

### Authentication Methods

v3 supports two authentication methods:

1. **Firebase Authentication** (for logged-in users)
2. **Guest Authentication** (for API key users)

### Priority Rules

If **both** `Authorization` and `X-API-Key` headers are present:
- `Authorization: Bearer <token>` takes **priority**
- `X-API-Key` is **ignored**

This design allows seamless user upgrades from guest to authenticated user.

### Authentication Responses

| Scenario | Status Code | Detail |
|----------|-------------|---------|
| Missing credentials | `401 Unauthorized` | "Authentication required. Provide either Authorization header (Bearer token) or X-API-Key header." |
| Invalid Firebase token | `401 Unauthorized` | "Invalid Firebase token" |
| Expired Firebase token | `401 Unauthorized` | "Firebase token has expired" |
| Invalid API key | `401 Unauthorized` | "Invalid API key" |
| Inactive API key | `403 Forbidden` | "API key is inactive" |
| Expired API key | `403 Forbidden` | "API key has expired" |
| Wrong project | `403 Forbidden` | "Access denied. You do not own this project." or "API key does not have access to this project." |

---

## 3. Project Context Requirement

### How Project Context is Specified

All v3 endpoints (except project creation and listing) use **path parameters** to specify project context:

```
/api/v3/projects/{project_id}/services
/api/v3/projects/{project_id}/incidents
/api/v3/projects/{project_id}/dashboard/overview
```

The `project_id` is **extracted from the URL path**, not from headers or query parameters.

### Validation Rules

For every request:
1. The project **must exist** in the database
2. The authenticated user/guest **must own** the project

Failure results in:
- `404 Not Found` if project doesn't exist
- `403 Forbidden` if user doesn't own the project

---

## 4. Required Headers Summary

### Firebase-Authenticated Requests

```http
Authorization: Bearer <firebase_jwt_token>
Content-Type: application/json
```

**Required:**
- `Authorization`: Firebase ID token obtained from Firebase Auth SDK

**Optional:**
- `X-API-Key`: Ignored if `Authorization` is present

### Guest-Authenticated Requests

```http
X-API-Key: <api_key_value>
Content-Type: application/json
```

**Required:**
- `X-API-Key`: API key value (format: `ss_<random_string>`)

---

## 5. Example Requests

### 5.1 Creating a Project (Firebase User Only)

**Endpoint:** `POST /api/v3/projects`

**Authentication:** Firebase JWT (required)

```bash
curl -X POST https://api.example.com/api/v3/projects \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production Monitoring",
    "description": "Monitoring for production services"
  }'
```

**Response (201 Created):**

```json
{
  "id": 42,
  "name": "Production Monitoring",
  "description": "Monitoring for production services",
  "user_id": 7,
  "is_active": true,
  "created_at": "2026-01-21T10:30:00Z",
  "updated_at": "2026-01-21T10:30:00Z"
}
```

**Notes:**
- Only Firebase-authenticated users can create projects
- Guest API keys **cannot** create projects
- The project is automatically owned by the authenticated user

---

### 5.2 Listing Projects (Firebase User Only)

**Endpoint:** `GET /api/v3/projects`

**Authentication:** Firebase JWT (required)

```bash
curl -X GET https://api.example.com/api/v3/projects \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200 OK):**

```json
[
  {
    "id": 42,
    "name": "Production Monitoring",
    "description": "Monitoring for production services",
    "user_id": 7,
    "is_active": true,
    "created_at": "2026-01-21T10:30:00Z",
    "updated_at": "2026-01-21T10:30:00Z"
  }
]
```

**Notes:**
- Returns only projects owned by the authenticated user
- Guest API keys **cannot** list projects

---

### 5.3 Creating a Service (Firebase User)

**Endpoint:** `POST /api/v3/projects/{project_id}/services`

**Authentication:** Firebase JWT or Guest API Key

```bash
curl -X POST https://api.example.com/api/v3/projects/42/services \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "User API",
    "service_type": "http",
    "endpoint": "https://api.myapp.com/health",
    "check_interval_seconds": 60
  }'
```

**Response (201 Created):**

```json
{
  "id": 123,
  "project_id": 42,
  "name": "User API",
  "service_type": "http",
  "endpoint": "https://api.myapp.com/health",
  "check_interval_seconds": 60,
  "is_active": true,
  "created_at": "2026-01-21T10:35:00Z"
}
```

---

### 5.4 Creating a Service (Guest API Key)

**Endpoint:** `POST /api/v3/projects/{project_id}/services`

**Authentication:** Guest API Key

```bash
curl -X POST https://api.example.com/api/v3/projects/42/services \
  -H "X-API-Key: ss_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Payment Gateway",
    "service_type": "http",
    "endpoint": "https://pay.myapp.com/status",
    "check_interval_seconds": 30
  }'
```

**Response (201 Created):**

```json
{
  "id": 124,
  "project_id": 42,
  "name": "Payment Gateway",
  "service_type": "http",
  "endpoint": "https://pay.myapp.com/status",
  "check_interval_seconds": 30,
  "is_active": true,
  "created_at": "2026-01-21T10:40:00Z"
}
```

**Notes:**
- The API key must belong to `project_id: 42`
- Using an API key from a different project returns `403 Forbidden`

---

### 5.5 Getting Project Dashboard

**Endpoint:** `GET /api/v3/projects/{project_id}/dashboard/overview`

**Authentication:** Firebase JWT or Guest API Key

#### Using Firebase JWT:

```bash
curl -X GET https://api.example.com/api/v3/projects/42/dashboard/overview \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Using Guest API Key:

```bash
curl -X GET https://api.example.com/api/v3/projects/42/dashboard/overview \
  -H "X-API-Key: ss_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
```

**Response (200 OK):**

```json
{
  "total_services": 12,
  "healthy_services": 10,
  "unhealthy_services": 2,
  "total_open_incidents": 3,
  "services": [
    {
      "service_id": 123,
      "service_name": "User API",
      "service_type": "http",
      "is_alive": true,
      "last_check": "2026-01-21T10:45:00Z",
      "latency_ms": 142,
      "open_incidents": 0
    }
  ],
  "last_updated": "2026-01-21T10:46:00Z"
}
```

---

### 5.6 Listing Incidents with Filters

**Endpoint:** `GET /api/v3/projects/{project_id}/incidents`

**Query Parameters:**
- `status`: Filter by incident status (open, acknowledged, investigating, resolved)
- `severity`: Filter by severity (low, medium, high, critical)
- `service_id`: Filter by specific service
- `skip`: Pagination offset (default: 0)
- `limit`: Page size (default: 100, max: 1000)

```bash
curl -X GET "https://api.example.com/api/v3/projects/42/incidents?status=open&severity=critical" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200 OK):**

```json
{
  "total": 3,
  "items": [
    {
      "id": 501,
      "service_id": 123,
      "service_name": "User API",
      "status": "open",
      "severity": "critical",
      "detected_at": "2026-01-21T09:00:00Z",
      "message": "Service is down"
    }
  ]
}
```

---

### 5.7 Creating an API Key for a Project

**Endpoint:** `POST /api/v3/projects/{project_id}/api-keys`

**Authentication:** Firebase JWT (required)

```bash
curl -X POST https://api.example.com/api/v3/projects/42/api-keys \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production Key",
    "description": "API key for production monitoring"
  }'
```

**Response (201 Created):**

```json
{
  "id": 15,
  "project_id": 42,
  "key_value": "ss_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
  "name": "Production Key",
  "description": "API key for production monitoring",
  "is_active": true,
  "created_at": "2026-01-21T10:50:00Z"
}
```

**CRITICAL:** The `key_value` is shown **ONLY ONCE** in this response. Store it securely. It cannot be retrieved later.

---

## 6. Migration Guide (v2 → v3)

### 6.1 What Frontend Must Change

#### Before (v2):

```javascript
// v2: No authentication required (or API key only)
fetch('/api/v2/projects/42/services', {
  headers: {
    'X-API-Key': 'ss_mykey123'
  }
})
```

#### After (v3):

```javascript
// v3: Must authenticate with Firebase JWT or API key
const firebaseToken = await auth.currentUser.getIdToken();

fetch('/api/v3/projects/42/services', {
  headers: {
    'Authorization': `Bearer ${firebaseToken}`,
    'Content-Type': 'application/json'
  }
})
```

### 6.2 What Will Break If Unchanged

| v2 Pattern | v3 Behavior | Fix |
|------------|-------------|-----|
| No authentication | `401 Unauthorized` | Add `Authorization` or `X-API-Key` header |
| Accessing other users' projects | `403 Forbidden` | Only access owned projects |
| Using expired API keys | `403 Forbidden` | Regenerate API key |
| Project creation with API key | `401 Unauthorized` | Use Firebase authentication |

### 6.3 Common Mistakes

#### ❌ Mistake 1: Not including authentication

```javascript
// WRONG: No authentication
fetch('/api/v3/projects/42/services')
```

**Error:** `401 Unauthorized`

**Fix:**

```javascript
// CORRECT: Include Firebase token
fetch('/api/v3/projects/42/services', {
  headers: {
    'Authorization': `Bearer ${firebaseToken}`
  }
})
```

---

#### ❌ Mistake 2: Using wrong project_id

```javascript
// WRONG: API key from project 10, trying to access project 42
fetch('/api/v3/projects/42/services', {
  headers: {
    'X-API-Key': 'ss_key_for_project_10'
  }
})
```

**Error:** `403 Forbidden - Access denied. API key does not have access to this project.`

**Fix:** Use the correct project ID that matches your API key.

---

#### ❌ Mistake 3: Malformed Authorization header

```javascript
// WRONG: Missing "Bearer " prefix
fetch('/api/v3/projects/42/services', {
  headers: {
    'Authorization': firebaseToken  // Missing "Bearer "
  }
})
```

**Error:** `401 Unauthorized - Invalid Authorization header format. Expected 'Bearer <token>'`

**Fix:**

```javascript
// CORRECT: Include "Bearer " prefix
fetch('/api/v3/projects/42/services', {
  headers: {
    'Authorization': `Bearer ${firebaseToken}`
  }
})
```

---

#### ❌ Mistake 4: Trying to create projects with API key

```javascript
// WRONG: Cannot create project with API key
fetch('/api/v3/projects', {
  method: 'POST',
  headers: {
    'X-API-Key': 'ss_mykey123',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ name: 'My Project' })
})
```

**Error:** `401 Unauthorized - Authentication required. Only Firebase-authenticated users can create projects.`

**Fix:** Use Firebase authentication for project creation.

---

## 7. API Endpoint Reference

### Base URL

```
Production: https://api.yourapp.com/api/v3
Development: http://localhost:8000/api/v3
```

### Projects

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/projects` | Firebase JWT | Create project |
| GET | `/projects` | Firebase JWT | List user's projects |
| GET | `/projects/{id}` | Firebase JWT or API Key | Get project details |
| GET | `/projects/{id}/stats` | Firebase JWT or API Key | Get project statistics |
| PATCH | `/projects/{id}` | Firebase JWT or API Key | Update project |
| DELETE | `/projects/{id}` | Firebase JWT or API Key | Delete project |

### Services

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/projects/{id}/services` | Firebase JWT or API Key | Create service |
| GET | `/projects/{id}/services` | Firebase JWT or API Key | List services |
| GET | `/projects/{id}/services/{service_id}` | Firebase JWT or API Key | Get service details |
| PATCH | `/projects/{id}/services/{service_id}` | Firebase JWT or API Key | Update service |
| DELETE | `/projects/{id}/services/{service_id}` | Firebase JWT or API Key | Delete service |
| POST | `/projects/{id}/services/{service_id}/activate` | Firebase JWT or API Key | Activate monitoring |
| POST | `/projects/{id}/services/{service_id}/deactivate` | Firebase JWT or API Key | Pause monitoring |
| POST | `/projects/{id}/services/{service_id}/check-now` | Firebase JWT or API Key | Trigger immediate check |

### Incidents

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/projects/{id}/incidents` | Firebase JWT or API Key | List incidents |
| GET | `/projects/{id}/incidents/{incident_id}` | Firebase JWT or API Key | Get incident details |
| PATCH | `/projects/{id}/incidents/{incident_id}` | Firebase JWT or API Key | Update incident |
| POST | `/projects/{id}/incidents/{incident_id}/acknowledge` | Firebase JWT or API Key | Acknowledge incident |
| POST | `/projects/{id}/incidents/{incident_id}/resolve` | Firebase JWT or API Key | Resolve incident |
| GET | `/projects/{id}/incidents/{incident_id}/analysis` | Firebase JWT or API Key | Get AI analysis |
| POST | `/projects/{id}/incidents/{incident_id}/analysis` | Firebase JWT or API Key | Request AI analysis |

### Dashboard

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/projects/{id}/dashboard/overview` | Firebase JWT or API Key | Get dashboard overview |
| GET | `/projects/{id}/dashboard/metrics` | Firebase JWT or API Key | Get aggregated metrics |

### API Keys

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/projects/{id}/api-keys` | Firebase JWT | Create API key |
| GET | `/projects/{id}/api-keys` | Firebase JWT | List API keys |
| DELETE | `/projects/{id}/api-keys/{key_id}` | Firebase JWT | Delete API key |
| POST | `/projects/{id}/api-keys/{key_id}/deactivate` | Firebase JWT | Deactivate API key |

---

## 8. Error Response Format

All v3 errors follow this format:

```json
{
  "detail": "Error message describing what went wrong"
}
```

### Common Error Codes

| Status Code | Meaning | Common Causes |
|-------------|---------|---------------|
| 401 Unauthorized | Authentication failed | Missing/invalid credentials |
| 403 Forbidden | Access denied | Wrong project, inactive key |
| 404 Not Found | Resource not found | Invalid project_id, service_id |
| 422 Unprocessable Entity | Validation error | Invalid request body |
| 500 Internal Server Error | Server error | Backend failure |

---

## 9. Best Practices

### 9.1 Token Management

- **Refresh Firebase tokens:** Firebase ID tokens expire after 1 hour. Implement automatic refresh.
- **Handle 401 errors:** If you receive `401 Unauthorized`, refresh the Firebase token and retry.

```javascript
async function authenticatedFetch(url, options = {}) {
  const token = await auth.currentUser.getIdToken(true); // Force refresh
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
}
```

### 9.2 API Key Security

- **Never commit API keys** to version control
- **Store securely** in environment variables or secure vaults
- **Rotate periodically** for production environments
- **Use separate keys** for development, staging, and production

### 9.3 Error Handling

```javascript
async function callV3API(endpoint, options) {
  const response = await authenticatedFetch(endpoint, options);

  if (response.status === 401) {
    // Token expired - refresh and retry
    await auth.currentUser.getIdToken(true);
    return callV3API(endpoint, options);
  }

  if (response.status === 403) {
    // Access denied - user doesn't own this project
    throw new Error('You do not have access to this project');
  }

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail);
  }

  return response.json();
}
```

---

## 10. Testing v3 APIs

### Using cURL

```bash
# Set your Firebase token
export FIREBASE_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# Test project creation
curl -X POST http://localhost:8000/api/v3/projects \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Project"}'

# Test with API key
export API_KEY="ss_your_api_key_here"

curl -X GET http://localhost:8000/api/v3/projects/42/services \
  -H "X-API-Key: $API_KEY"
```

### Using Postman

1. Create a new request
2. Set authorization type to "Bearer Token"
3. Paste your Firebase ID token
4. Set the URL to `{{base_url}}/api/v3/projects/42/services`
5. Send the request

---

## 11. Support

For questions or issues:

- **API Documentation:** https://api.yourapp.com/docs
- **Support:** support@yourapp.com
- **GitHub Issues:** https://github.com/yourorg/service-sentinel/issues

---

## 12. Changelog

### v3.0.0 (2026-01-21)

- Initial v3 release
- Added mandatory authentication (Firebase JWT + Guest API Key)
- Enforced strict project-scoping with ownership validation
- Introduced unified authentication priority (Authorization > X-API-Key)
- All endpoints now require authentication and project ownership

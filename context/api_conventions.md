# API Conventions

## Base URL
All endpoints are prefixed with `/api/v3`.

## URL Structure
Resources follow a hierarchical RESTful pattern: `/{resource}`, `/{resource}/{id}`, `/{resource}/{id}/{sub-resource}`, `/{resource}/{id}/{sub-resource}/{sub-id}`. Sub-resource names use kebab-case (e.g. `api-keys`, `device-tokens`).

## Authentication
Two methods are supported. When both headers are present, Firebase takes priority.

- **Firebase (authenticated users)**: `Authorization: Bearer <firebase_id_token>`
- **API Key (guest users)**: `X-API-Key: <api_key>`

**Exceptions**: The following endpoints require no authentication.
- `POST /api/v3/projects/bootstrap` — guest project creation
- `GET /api/v3/dashboard/global` — system-wide read-only metrics

## Ownership Verification
All endpoints with `{project_id}` in the path verify that the requester owns the project before processing. Applies to both Firebase users and guest API key holders.

## HTTP Methods and Status Codes
- GET → 200: retrieve resource(s)
- POST → 201: create resource
- PATCH → 200: partial update
- DELETE → 204: delete resource

Special actions that don't map cleanly to CRUD use POST with an action suffix (e.g. `POST /{resource}/{id}/deactivate`). Action endpoints and idempotent upsert operations (e.g. register-or-update) return 200 or 204 rather than 201.

## Error Response Format
All errors return `{ "detail": "<message>" }`.
- 401: missing or invalid credentials
- 403: valid credentials but insufficient permission, or resource belongs to another project
- 404: resource does not exist

## Pagination
List endpoints accept `skip` (default: 0) and `limit` (default: 100, max: 1000) query parameters. Filtering is supported via additional query parameters (e.g. `is_active=true`).

## Routers
- `projects_v3` → `/api/v3/projects`
- `services_v3` → `/api/v3/services`
- `incidents_v3` → `/api/v3/incidents`
- `dashboard_v3` → `/api/v3/dashboard`
- `user_v3` → `/api/v3/auth`
- `device_token_v3` → `/api/v3/device-tokens`

---

## Endpoint Reference

Auth column values:
- **Firebase** — `Authorization: Bearer` header only; guest API keys are rejected
- **Firebase or API key** — either auth method accepted; project ownership verified
- **None** — no authentication required

### Projects

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| POST | `/api/v3/projects/bootstrap` | None | 201 | Create a guest-owned project. Returns the project and a one-time API key. |
| POST | `/api/v3/projects` | Firebase | 201 | Create a project owned by the authenticated Firebase user. |
| GET | `/api/v3/projects` | Firebase or API key | 200 | List projects owned by the authenticated user or guest. |
| GET | `/api/v3/projects/{project_id}` | Firebase or API key | 200 | Get project by ID. |
| GET | `/api/v3/projects/{project_id}/stats` | Firebase or API key | 200 | Get project with aggregate statistics. |
| GET | `/api/v3/projects/{project_id}/health` | Firebase or API key | 200 | Get derived health status (never stored; always calculated). |
| PATCH | `/api/v3/projects/{project_id}` | Firebase or API key | 200 | Update project fields. |
| DELETE | `/api/v3/projects/{project_id}` | Firebase or API key | 204 | Delete project and all associated data (irreversible). |

### API Keys

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| POST | `/api/v3/projects/{project_id}/api-keys` | Firebase or API key | 201 | Create a new API key. `key_value` is shown only in this response. |
| GET | `/api/v3/projects/{project_id}/api-keys` | Firebase or API key | 200 | List all API keys for the project. |
| DELETE | `/api/v3/projects/{project_id}/api-keys/{key_id}` | Firebase or API key | 204 | Permanently delete an API key. |
| POST | `/api/v3/projects/{project_id}/api-keys/{key_id}/deactivate` | Firebase or API key | 200 | Deactivate an API key without deleting it. |

### Services

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| POST | `/api/v3/projects/{project_id}/services` | Firebase or API key | 201 | Create a new monitored service. |
| GET | `/api/v3/projects/{project_id}/services` | Firebase or API key | 200 | List all services in the project. |
| GET | `/api/v3/projects/{project_id}/services/{service_id}` | Firebase or API key | 200 | Get service by ID. |
| PATCH | `/api/v3/projects/{project_id}/services/{service_id}` | Firebase or API key | 200 | Update service configuration. |
| DELETE | `/api/v3/projects/{project_id}/services/{service_id}` | Firebase or API key | 204 | Delete a service and its history. |
| POST | `/api/v3/projects/{project_id}/services/{service_id}/activate` | Firebase or API key | 200 | Enable monitoring for a service (`is_active = true`). |
| POST | `/api/v3/projects/{project_id}/services/{service_id}/deactivate` | Firebase or API key | 200 | Pause monitoring for a service (`is_active = false`). |
| POST | `/api/v3/projects/{project_id}/services/{service_id}/check-now` | Firebase or API key | 200 | Trigger an immediate health check outside the normal schedule. |

### Health Checks

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| GET | `/api/v3/projects/{project_id}/services/{service_id}/health-checks` | Firebase or API key | 200 | Paginated health check history for a service. |
| GET | `/api/v3/projects/{project_id}/services/{service_id}/health-checks/latest` | Firebase or API key | 200 | Most recent health check result for a service. |
| GET | `/api/v3/projects/{project_id}/services/{service_id}/stats` | Firebase or API key | 200 | Uptime statistics for a service. Query param: `period` (`1h`, `24h`, `7d`, `30d`; default `24h`). |

### Incidents

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| GET | `/api/v3/projects/{project_id}/incidents` | Firebase or API key | 200 | List all incidents for the project. Filterable by `status`, `severity`, `service_id`. |
| GET | `/api/v3/projects/{project_id}/incidents/{incident_id}` | Firebase or API key | 200 | Get incident by ID. |
| PATCH | `/api/v3/projects/{project_id}/incidents/{incident_id}` | Firebase or API key | 200 | Update incident fields (status, severity, description). |
| POST | `/api/v3/projects/{project_id}/incidents/{incident_id}/acknowledge` | Firebase or API key | 200 | Set incident status to `acknowledged` and record `acknowledged_at`. |
| POST | `/api/v3/projects/{project_id}/incidents/{incident_id}/resolve` | Firebase or API key | 200 | Set incident status to `resolved` and record `resolved_at`. |
| GET | `/api/v3/projects/{project_id}/services/{service_id}/incidents` | Firebase or API key | 200 | List incidents scoped to a specific service. |

### AI Analysis

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| GET | `/api/v3/projects/{project_id}/incidents/{incident_id}/analysis` | Firebase or API key | 200 | Get existing AI analysis for an incident. 404 if not yet requested. |
| POST | `/api/v3/projects/{project_id}/incidents/{incident_id}/analysis` | Firebase or API key | 200 | Request AI analysis for an incident. Accepts optional `force_reanalyze` body flag. |

### Dashboard

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| GET | `/api/v3/projects/{project_id}/dashboard/overview` | Firebase or API key | 200 | Service health overview for the project. |
| GET | `/api/v3/projects/{project_id}/dashboard/metrics` | Firebase or API key | 200 | Aggregated metrics for the project. Query param: `period` (`1h`, `24h`, `7d`, `30d`; default `24h`). |
| GET | `/api/v3/dashboard/global` | None | 200 | System-wide aggregated metrics across all projects. No authentication required. |

### Auth

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| DELETE | `/api/v3/auth/me` | Firebase | 204 | Delete the authenticated Firebase user and cascade-delete all owned projects. |

### Device Tokens

| Method | Path | Auth | Status | Description |
|--------|------|------|--------|-------------|
| POST | `/api/v3/device-tokens` | Firebase | 204 | Register or update an FCM device token for the current user. Idempotent. |
| POST | `/api/v3/device-tokens/deactivate` | Firebase | 204 | Deactivate an FCM device token. |

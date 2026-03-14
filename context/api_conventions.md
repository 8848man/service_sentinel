# API Conventions

## Base URL
All endpoints are prefixed with `/api/v3`.

## URL Structure
Resources follow a hierarchical RESTful pattern: `/{resource}`, `/{resource}/{id}`, `/{resource}/{id}/{sub-resource}`, `/{resource}/{id}/{sub-resource}/{sub-id}`. Sub-resource names use kebab-case (e.g. `api-keys`, `device-tokens`).

## Authentication
Two methods are supported. When both headers are present, Firebase takes priority.

- **Firebase (authenticated users)**: `Authorization: Bearer <firebase_id_token>`
- **API Key (guest users)**: `X-API-Key: <api_key>`

**Exception**: `POST /api/v3/projects/bootstrap` is the only endpoint that requires no authentication.

## Ownership Verification
All endpoints with `{project_id}` in the path verify that the requester owns the project before processing. Applies to both Firebase users and guest API key holders.

## HTTP Methods and Status Codes
- GET → 200: retrieve resource(s)
- POST → 201: create resource
- PATCH → 200: partial update
- DELETE → 204: delete resource

Special actions that don't map cleanly to CRUD use POST with an action suffix (e.g. `POST /{resource}/{id}/deactivate`).

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
- `user_v3` → `/api/v3/users`
- `device_token_v3` → `/api/v3/device-tokens`

# Service Sentinel

API monitoring platform. Register your API endpoints, and Service Sentinel periodically health-checks them, raises incidents on failure, and provides on-demand AI root-cause analysis powered by Google Gemini.

---

## Features

- **Service Registration** — Monitor HTTP/HTTPS endpoints with custom headers, methods, and expected status codes
- **Automated Health Checks** — Configurable per-service check intervals via background scheduler
- **Incident Detection** — Incidents are created after `failure_threshold` consecutive failures, with severity classification
- **AI Root-Cause Analysis** — On-demand Gemini-powered analysis: root cause hypothesis, debug checklist, and suggested actions
- **Push Notifications** — FCM alerts for incident open/resolve events (per-service opt-in)
- **Guest Access** — Bootstrap a project without an account; authenticate with a project-scoped API key

---

## Repository Structure

```
service_sentinel/
├── be/          # Python / FastAPI backend
├── fe/          # Flutter frontend (mobile + web)
└── context/     # Architecture, domain model, and API convention docs
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend framework | FastAPI 0.110.0 + Uvicorn |
| ORM / migrations | SQLAlchemy 2.0.25, Alembic |
| Database | PostgreSQL |
| Scheduling | APScheduler 3.10.4 |
| HTTP client | HTTPX 0.27.0 |
| Auth | Firebase Admin + python-jose |
| AI | Google Gemini (google-generativeai 0.3.2) |
| Frontend | Flutter ≥3.3.0 |
| State management | Riverpod 2.5.1 |
| Routing | go_router 14.2.0 |
| Networking | Dio 5.4.3 |
| Push notifications | FCM |

---

## Getting Started

### Backend

```bash
cd be
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env          # fill in DATABASE_URL, Firebase credentials, Gemini API key
alembic upgrade head
uvicorn app.main:app --reload
```

API docs: `http://localhost:8000/docs`

### Frontend

```bash
cd fe
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## API

All endpoints are under `/api/v3`.

**Authentication** — include one of:
- `Authorization: Bearer <firebase_id_token>` (authenticated users)
- `X-API-Key: <api_key>` (guest users; key prefix `ss_`)

The only public endpoint (no auth required): `POST /api/v3/projects/bootstrap`

**Status codes**: GET → 200, POST → 201, PATCH → 200, DELETE → 204

**Errors**: `{ "detail": "<message>" }` — 401 / 403 / 404

**Pagination**: `?skip=0&limit=100` on list endpoints

### Key Endpoints

| Resource | Endpoint |
|----------|----------|
| Bootstrap guest project | `POST /api/v3/projects/bootstrap` |
| Projects | `GET/POST /api/v3/projects` |
| Project detail | `GET/PATCH/DELETE /api/v3/projects/{id}` |
| Services | `GET/POST /api/v3/projects/{id}/services` |
| Service detail | `GET/PATCH/DELETE /api/v3/projects/{id}/services/{sid}` |
| Trigger check | `POST /api/v3/projects/{id}/services/{sid}/check-now` |
| Health check history | `GET /api/v3/projects/{id}/services/{sid}/health-checks` |
| Service stats | `GET /api/v3/projects/{id}/services/{sid}/stats?period=24h` |
| Incidents | `GET /api/v3/projects/{id}/incidents` |
| Incident detail | `GET/PATCH /api/v3/projects/{id}/incidents/{iid}` |
| AI analysis | `GET/POST /api/v3/projects/{id}/incidents/{iid}/analysis` |
| API keys | `GET/POST /api/v3/projects/{id}/api-keys` |
| Device tokens | `GET/POST /api/v3/device-tokens` |

See `context/api_conventions.md` for full conventions.

---

## Domain Model

- **Project** — aggregate root; owned by a Firebase user **XOR** a guest key (never both)
- **Service** — monitoring target; tracks `failure_threshold`, `check_interval_seconds`, `service_state` (healthy / error / inactive)
- **HealthCheck** — single execution result (`is_alive`, `status_code`, `latency_ms`, `error_type`)
- **Incident** — created at `failure_threshold` consecutive failures; statuses: open / investigating / acknowledged / resolved
- **AIAnalysis** — one per incident, created on demand; provides `root_cause_hypothesis`, `debug_checklist`, `suggested_actions`
- **APIKey** — project-scoped, prefixed `ss_`
- **UserDeviceToken** — FCM token (unique across all users)

See `context/domain_model.md` for full entity definitions and business rules.

---

## Project Docs

| File | Contents |
|------|----------|
| `context/architecture.md` | System components and monitoring pipeline |
| `context/domain_model.md` | Entities, relationships, and business rules |
| `context/tech_stack.md` | Full dependency list |
| `context/api_conventions.md` | REST conventions and router map |
| `context/project_conventions.md` | Folder and layer rules |

# Domain Model

API monitoring platform. Users register services (API endpoints). The system periodically performs health checks, creates incidents on failure, and provides AI-based root cause analysis.

## Entities

**User** — Firebase-authenticated user.
- `firebase_uid`: unique Firebase Auth UID
- Has many `Project`, has many `UserDeviceToken`

**Project** — Top-level aggregate root. All services and activity belong to a project.
- `user_id` XOR `guest_key`: exactly one must be set (mutually exclusive ownership)
  - `user_id` → authenticated Firebase user / `guest_key` → unauthenticated guest
- `is_active`, `notification_enabled`
- Belongs to `User`; has many `Service`, `APIKey`

**APIKey** — Project-scoped authentication key.
- `key_value`: prefixed `ss_`, unique
- `is_active`, `expires_at` (optional), `last_used_at`, `usage_count`
- Belongs to `Project`

**Service** — A monitoring target (API endpoint).
- `endpoint_url`, `http_method` (GET/POST/PUT/DELETE/PATCH/HEAD)
- `service_type`: http_api / https_api / gcp_endpoint / firebase / websocket / grpc
- `headers` (JSON), `request_body` (JSON), `expected_status_codes` (JSON, default: [200])
- `timeout_seconds` (default: 10), `check_interval_seconds` (default: 60)
- `failure_threshold`: consecutive failures before an incident is created (default: 3)
- `is_active`, `service_state`: healthy / error / inactive
- `notification_enabled`: overrides project-level setting
- Belongs to `Project`; has many `HealthCheck`, `Incident`

**HealthCheck** — A single health check execution result.
- `is_alive`, `status_code`, `latency_ms`
- `response_body` (first 1000 chars), `error_message`, `error_type` (timeout/connection/ssl/etc.)
- `needs_analysis`: flag to trigger AI analysis
- Belongs to `Service`; may trigger at most one `Incident`

**HealthCheckResult** — Lightweight projection of check results for aggregation/dashboards only.
- `is_alive`, `status_code`, `latency_ms`, `error_message`, `checked_at`
- Belongs to `Service`
- Note: not linked to incidents or AI analysis — `HealthCheck` is the authoritative record

**Incident** — A detected service failure. Created when consecutive failures reach `failure_threshold`.
- `title`, `description`
- `status`: open / investigating / acknowledged / resolved
- `severity`: critical (outage) / high (multiple failures) / medium (intermittent) / low (degradation)
- `consecutive_failures`, `total_affected_checks`
- `detected_at`, `resolved_at`, `acknowledged_at`
- `ai_analysis_requested`, `ai_analysis_completed`
- Belongs to `Service`; triggered by one `HealthCheck`; has at most one `AIAnalysis`

**AIAnalysis** — AI model analysis result for an incident. Created on demand, one per incident.
- `incident_id`: unique — one analysis per incident
- `model_used`, `prompt_tokens`, `completion_tokens`, `total_cost_usd`
- `root_cause_hypothesis`, `confidence_score` (0.0–1.0)
- `debug_checklist` (JSON array of steps), `suggested_actions` (JSON array of {action, priority})
- `related_error_patterns` (JSON), `raw_response`, `analysis_duration_ms`
- Belongs to `Incident`

**UserDeviceToken** — FCM push notification token for a user's device.
- `token`: globally unique FCM token
- `platform`: android / ios / web
- `is_active`, `last_seen_at`
- Belongs to `User`

## Business Rules

1. **Project ownership exclusivity**: `user_id` and `guest_key` are mutually exclusive — exactly one must be set.
2. **Incident threshold**: incident is created when a service's consecutive failures reach `failure_threshold`.
3. **One AI analysis per incident**: `AIAnalysis.incident_id` is unique.
4. **Notification precedence**: service-level `notification_enabled` overrides project-level.
5. **Duplicate FCM token prevention**: `UserDeviceToken.token` has a unique constraint across all users.

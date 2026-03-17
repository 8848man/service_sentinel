# Domain Model

API monitoring platform. Users register services (API endpoints). The system periodically performs health checks, creates incidents on failure, and provides AI-based root cause analysis.

## Entities

**User** — Firebase-authenticated user.
- `firebase_uid`: unique Firebase Auth UID
- Has many `Project`, has many `UserDeviceToken`

**Project** — Top-level aggregate root. All services and activity belong to a project.
- `name` (max 100 chars, required), `description` (text, optional)
- `user_id` XOR `guest_key`: exactly one must be set (mutually exclusive ownership)
  - `user_id` → authenticated Firebase user / `guest_key` → unauthenticated guest
- `is_active`, `notification_enabled` (nullable, no default — null means inherit or unset)
- `created_at`, `updated_at`
- Belongs to `User`; has many `Service`, `APIKey`

**APIKey** — Project-scoped authentication key.
- `key_value`: prefixed `ss_`, unique
- `is_active`, `expires_at` (optional), `last_used_at`, `usage_count`
- Belongs to `Project`

**Service** — A monitoring target (API endpoint).
- `name` (max 100 chars, required), `description` (max 500 chars, optional)
- `endpoint_url`, `http_method` (GET/POST/PUT/DELETE/PATCH/HEAD)
- `service_type`: http_api / https_api / gcp_endpoint / firebase / websocket / grpc
- `headers` (JSON), `request_body` (JSON), `expected_status_codes` (JSON, default: [200])
- `timeout_seconds` (default: 10), `check_interval_seconds` (default: 60)
- `failure_threshold`: number of failures within the detection time window required to create an incident (default: 3). Detection window = `(check_interval_seconds / 60) × failure_threshold` minutes.
- `is_active`, `service_state`: healthy / error / inactive
- `notification_enabled`: overrides project-level setting (nullable, no default)
- `created_at`, `updated_at`, `last_checked_at` (nullable — set after first check)
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
- ORM note: the `service` relationship on `HealthCheckResult` does not define `back_populates`, so `Service` has no corresponding `health_check_results` attribute on the ORM side.

**Incident** — A detected service failure. Created when the count of failed health checks within a rolling time window reaches `failure_threshold`.
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
2. **Incident threshold**: an incident is created when the count of failed health checks within a rolling time window of `(check_interval_seconds / 60) × failure_threshold` minutes reaches `failure_threshold`. This is a time-window failure count, not a strictly consecutive check count. Once an open incident exists for a service, each subsequent failure increments its `consecutive_failures` counter directly.
3. **One AI analysis per incident**: `AIAnalysis.incident_id` has a unique constraint in the database. When `force_reanalyze=True`, `AIAnalysisService.analyze_incident()` deletes the existing record before calling `create()`.
4. **Notification precedence**: service-level `notification_enabled` overrides project-level.
5. **Duplicate FCM token prevention**: `UserDeviceToken.token` has a unique constraint across all users.

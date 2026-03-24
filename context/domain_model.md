# Domain Model

API monitoring platform. Users register services (API endpoints). The system periodically performs health checks, creates incidents on failure, and provides AI-based root cause analysis.

## Plan Limits

| Plan | Max Projects (per User) | Max Services (per Project) |
|------|------------------------|---------------------------|
| free | 3                      | 10                        |
| pro  | 10                     | 20                        |
| max  | 10                     | 50                        |

## Feature Flags (MVP)

| Flag                         | Value | Description                                                                        |
|------------------------------|-------|------------------------------------------------------------------------------------|
| `DEFAULT_PLAN`               | `pro` | Default plan assigned to newly created users. To be switched to `free` post-MVP.  |
| `INACTIVITY_SUSPENSION_DAYS` | `30`  | Days of inactivity before free plan monitoring is suspended.                       |

## Entities

**User** — Firebase-authenticated user.
- `firebase_uid`: unique Firebase Auth UID
- `last_login_at` (nullable — updated on every login)
- Has many `Project`, `UserDeviceToken`; has one `Subscription`

**Subscription** — User's plan subscription. Auto-created alongside User.
- `user_id`: unique (1:1 with User)
- `plan`: free / pro / max (default: `DEFAULT_PLAN`)
- `status`: active / expired / cancelled / trial (default: active)
- `started_at`, `expires_at` (nullable — null means indefinite)
- `previous_plan` (nullable), `plan_changed_at` (nullable)
- `monitoring_suspended_at` (nullable — set when suspended due to inactivity, null when active)
- Has many `SubscriptionHistory`; belongs to `User`

**SubscriptionHistory** — Audit log of plan changes. *(not implemented — planned for billing integration)*
- `subscription_id` (FK), `previous_plan`, `new_plan`, `changed_at`
- `reason` (nullable): upgrade / downgrade / expiry / cancellation / admin
- Belongs to `Subscription`

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
- `failure_threshold`: failures within detection window to trigger incident (default: 3).
  Detection window = `(check_interval_seconds / 60) × failure_threshold` minutes.
- `is_active`, `service_state`: healthy / error / inactive
- `notification_enabled`: overrides project-level setting (nullable, no default)
- `created_at`, `updated_at`, `last_checked_at` (nullable — set after first check)
- Belongs to `Project`; has many `HealthCheck`, `Incident`

**HealthCheck** — A single health check execution result.
- `is_alive`, `status_code`, `latency_ms`
- `response_body` (first 1000 chars), `error_message`, `error_type` (timeout/connection/ssl/etc.)
- `needs_analysis`: flag to trigger AI analysis
- Belongs to `Service`; may trigger at most one `Incident`

**LatencyPoint** — Single bucket in a latency time-series. Response projection only; not persisted.
- `bucket_start` (datetime), `avg_latency_ms` (float), `p95_latency_ms` (float, PostgreSQL only), `sample_count` (int)
- Sourced from `HealthCheck.latency_ms` grouped by `HealthCheck.checked_at` into fixed-duration buckets

**LatencySeriesResponse** — Top-level latency query response. Response projection only; not persisted.
- `service_id`, `avg_latency_ms` (float — series-wide average), `p95_latency_ms` (float — series-wide 95th percentile)
- `data_points`: list of `LatencyPoint`
- Defined in `be/app/schemas/latency_schema.py`

**HealthCheckResult** — Lightweight projection of check results for aggregation/dashboards only.
- `is_alive`, `status_code`, `latency_ms`, `error_message`, `checked_at`
- Belongs to `Service`
- Note: not linked to incidents or AI analysis — `HealthCheck` is the authoritative record
- ORM note: no `back_populates` defined — `Service` has no `health_check_results` ORM attribute.

**Incident** — A detected service failure.
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
- `debug_checklist` (JSON array of strings — each entry is one resolution step; drives the FE `ResolutionChecklist` widget with per-item checkbox state and a `LinearProgressIndicator`)
- `suggested_actions` (JSON array of `{action, priority}` objects — typed `List<Map<String,dynamic>>` in the FE `AiAnalysis` entity and `AiAnalysisDto`; **do not type as `List<String>`**)
- `related_error_patterns` (JSON), `raw_response`, `analysis_duration_ms`
- Belongs to `Incident`

**UserDeviceToken** — FCM push notification token for a user's device.
- `token`: globally unique FCM token
- `platform`: android / ios / web
- `is_active`, `last_seen_at`
- Belongs to `User`

## Business Rules

1. **Project ownership exclusivity**: `user_id` and `guest_key` are mutually exclusive — exactly one must be set.
2. **Incident threshold**: an incident is created when the count of failed health checks within a rolling time window of `(check_interval_seconds / 60) × failure_threshold` minutes reaches `failure_threshold`. Not strictly consecutive. Once an open incident exists, each subsequent failure increments `consecutive_failures` directly.
3. **One AI analysis per incident**: `AIAnalysis.incident_id` is unique. When `force_reanalyze=True`, the existing record is deleted before re-creating.
4. **Notification precedence**: service-level `notification_enabled` overrides project-level.
5. **Duplicate FCM token prevention**: `UserDeviceToken.token` has a unique constraint across all users.
6. **Project limit per user**: capped by `Subscription.plan` (free: 3, pro: 10, max: 10). Expired / cancelled status falls back to free limits.
7. **Service limit per project**: capped by the owning user's `Subscription.plan` (free: 10, pro: 20, max: 50).
8. **Subscription auto-creation**: a `Subscription` is auto-created with each new User, with `plan` set to `DEFAULT_PLAN`.
9. **Guest project plan**: projects owned by `guest_key` have no subscription — always apply free plan limits.
10. **Inactivity suspension (free plan only)**: if a free plan user has not logged in for `INACTIVITY_SUSPENSION_DAYS` consecutive days (based on `User.last_login_at`), all their services' monitoring is suspended (`service_state` → inactive) and `Subscription.monitoring_suspended_at` is set. Health checks are not performed during suspension. Warning notifications are sent at 7 days, 3 days, and 0 days before suspension. pro / max plans are unaffected.
11. **Manual reactivation**: a suspended free plan user must explicitly reactivate monitoring via the plan section in settings. The reactivate button is visible only when `Subscription.plan = free` AND `monitoring_suspended_at` is not null. On reactivation, `monitoring_suspended_at` is reset to null and all previously active services resume monitoring.
12. **Project monitoring toggle**: Project.is_active can be toggled
    by the owner at any time, on all plans. When deactivated, all
    child services are treated as inactive — health checks are
    skipped. When reactivated, all child services resume monitoring.
    Changes take effect from the next check cycle, not immediately.
    Individual service states are preserved; the project toggle acts
    as an override layer.

13. **Service monitoring toggle**: Service.is_active can be toggled
    independently by the owner at any time, on all plans. A service
    is only checked when both its own is_active = true AND its parent
    Project.is_active = true. Changes take effect from the next
    check cycle.

14. **Resolution checklist state is local only**: `AIAnalysis.debug_checklist` stores the step strings. Checkbox completion state (checked/unchecked per step) is maintained in FE widget-local state (`List<bool>`) and is never persisted to the backend.
15. **Latency series uses PostgreSQL aggregates**: the `/latency` endpoint computes `p95_latency_ms` with `percentile_cont(0.95)` — a PostgreSQL-specific function. This query will fail if the backend is pointed at an SQLite database.

## Future Considerations

- **SubscriptionHistory**: activate when integrating a billing system. Deprecate `Subscription.previous_plan` and `plan_changed_at` at that point.
- **Guest plan policy**: re-evaluate after analyzing guest-to-authenticated conversion rates.
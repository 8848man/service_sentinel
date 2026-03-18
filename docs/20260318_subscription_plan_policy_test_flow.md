# Test Flow: Subscription & Plan Policy

Date: 2026-03-18

---

## 1. Subscription Auto-creation

**Steps to verify:**
1. Register a new Firebase user via the app (first login / sign-up).
2. After authentication, call `GET /api/v3/subscription` with the user's Bearer token.

**Expected DB state:**
```sql
SELECT * FROM subscriptions WHERE user_id = <new_user_id>;
-- plan = 'pro', status = 'active', monitoring_suspended_at = NULL
```

**Expected API response (200):**
```json
{
  "id": 1,
  "user_id": 42,
  "plan": "pro",
  "status": "active",
  "started_at": "2026-03-18T...",
  "expires_at": null,
  "monitoring_suspended_at": null
}
```

---

## 2. Plan Limit — Project

### Free plan (max 3 projects)
1. Set subscription plan to `free` in DB:
   ```sql
   UPDATE subscriptions SET plan='free' WHERE user_id = <user_id>;
   ```
2. Create 3 projects via `POST /api/v3/projects`.
3. Attempt to create a 4th project.

**Expected BE response (403):**
```json
{
  "detail": {
    "error": "plan_limit_reached",
    "resource": "project",
    "current_plan": "free",
    "limit": 3,
    "upgrade_required": true
  }
}
```

**Expected FE behavior:**
- Project list section: The create button should show `PlanLimitDialog` before opening the create dialog.
- If the dialog is somehow bypassed, the BE 403 is caught and `PlanLimitDialog` is shown.
- Clicking "Upgrade Plan" in the dialog navigates to `/upgrade`.

### Pro / Max plan (max 10 projects)
- Same steps, create 10 projects → 11th attempt returns 403 with `limit: 10`.

---

## 3. Plan Limit — Service

### Free plan (max 10 services per project)
1. Set subscription plan to `free`.
2. Create 10 services under one project.
3. Attempt to create an 11th service.

**Expected BE response (403):**
```json
{
  "detail": {
    "error": "plan_limit_reached",
    "resource": "service",
    "current_plan": "free",
    "limit": 10,
    "upgrade_required": true
  }
}
```

**Expected FE behavior:**
- Services list section: Create button shows `PlanLimitDialog` before opening the create dialog.
- 403 from BE is caught and `PlanLimitDialog` is shown.

### Guest project (always free limits regardless of subscription)
- Create guest project via `POST /api/v3/projects/bootstrap`.
- Attempt to create >10 services → 403 with `current_plan: free`.

---

## 4. Upgrade Screen

**Navigation path:**
1. Open Settings screen (`/main/settings`).
2. In the Subscription section, tap "View Plans" → navigates to `/upgrade`.
3. From `PlanLimitDialog`, tap "Upgrade Plan" → navigates to `/upgrade`.

**Expected UI elements on `/upgrade`:**
- Current plan badge (e.g., "FREE" or "PRO").
- Plan comparison table (Free / Pro / Max with project and service limits).
- Pro and Max plan cards with "Coming soon" CTA buttons (disabled).

---

## 5. Project Monitoring Toggle

**Steps to deactivate:**
1. Navigate to a project detail screen (`/project/:id`).
2. Toggle the "Monitoring" switch to OFF.
3. Verify a snackbar appears: "Monitoring will update on the next check cycle."

**Expected DB state:**
```sql
SELECT is_active FROM projects WHERE id = <project_id>;
-- is_active = false
```

**Verify next check cycle skips the project:**
- Check monitoring logs — the project's services should NOT appear in the active service list.
- Alternatively: query `find_active_for_monitoring()` — services belonging to this project should not be returned.

**Steps to reactivate:**
- Toggle the switch back to ON.
- Services resume on the next scheduler run.

---

## 6. Service Monitoring Toggle

**Steps to deactivate:**
1. Navigate to a service detail screen (`/service/:id`).
2. Toggle the "Monitoring" switch to OFF.
3. Verify snackbar: "Monitoring will update on the next check cycle."

**Expected DB state:**
```sql
SELECT is_active, service_state FROM services WHERE id = <service_id>;
-- is_active = false, service_state = 'inactive'
```

**Parent project inactive hint:**
- If the parent project's `is_active = false`, the service is already skipped regardless of service toggle state.
- The toggle is still functional but has no visible effect until the project is re-enabled.

**Steps to reactivate:**
- Toggle the switch back to ON.

---

## 7. Inactivity Suspension (free plan)

**How to simulate 30-day inactivity:**
```sql
-- Set last_login_at to 31 days ago for a free plan user
UPDATE users
SET last_login_at = NOW() - INTERVAL '31 days'
WHERE id = <user_id>;

-- Ensure user is on free plan
UPDATE subscriptions SET plan = 'free' WHERE user_id = <user_id>;
```

Then trigger `run_inactivity_checks()` manually (or wait for the daily scheduler job).

**Expected result after check:**
```sql
-- All services for the user's projects should be INACTIVE
SELECT service_state FROM services WHERE project_id IN (
  SELECT id FROM projects WHERE user_id = <user_id>
);
-- All rows: service_state = 'inactive'

-- Subscription should be marked suspended
SELECT monitoring_suspended_at FROM subscriptions WHERE user_id = <user_id>;
-- monitoring_suspended_at = <timestamp>
```

**Warning notification verification (D-7, D-3, D-0):**
```sql
-- Simulate D-7: last_login_at = 23 days ago (30 - 7 = 23)
UPDATE users SET last_login_at = NOW() - INTERVAL '23 days' WHERE id = <user_id>;
```
Run `check_warnings()` → a push notification should be sent to the user's registered device tokens with body containing "7 days".

Repeat with 27 days (D-3) and 30 days (D-0).

---

## 8. Manual Reactivation

**Steps to reactivate via settings:**
1. Open Settings screen.
2. In the Subscription section, verify the orange suspension warning banner is visible.
   - Condition: `plan == 'free' AND monitoring_suspended_at IS NOT NULL`.
3. Tap "Reactivate" button.
4. Verify success snackbar: "Monitoring reactivated successfully."

**Expected DB state after reactivation:**
```sql
-- monitoring_suspended_at should be cleared
SELECT monitoring_suspended_at FROM subscriptions WHERE user_id = <user_id>;
-- monitoring_suspended_at = NULL

-- Services should be restored to HEALTHY
SELECT service_state FROM services WHERE project_id IN (
  SELECT id FROM projects WHERE user_id = <user_id>
);
-- service_state = 'healthy'
```

**Button visibility condition:**
- Button is shown ONLY when `plan == 'free'` AND `monitoring_suspended_at IS NOT NULL`.
- Not shown for Pro/Max users.
- Not shown for free users who are not suspended.

---

## 9. Fallback to Free Plan

**How to test expired/cancelled subscription:**
```sql
UPDATE subscriptions
SET status = 'expired'
WHERE user_id = <user_id>;
```

**Expected limit behavior:**
- `GET /api/v3/subscription` returns `status: 'expired'`.
- Project/service creation uses free plan limits (3 projects, 10 services).
- Verify by trying to create a 4th project → 403 with `current_plan: free, limit: 3`.

**Test cancelled plan similarly:**
```sql
UPDATE subscriptions SET status = 'cancelled' WHERE user_id = <user_id>;
```

---

## 10. Guest Project

**Steps to create guest project and hit service limit:**
1. Call `POST /api/v3/projects/bootstrap` (no auth required) to create a guest project.
   - Store the returned `api_key`.
2. Create 10 services using `X-API-Key: <api_key>` header.
3. Attempt to create an 11th service.

**Expected:**
- 403 with `current_plan: free, limit: 10, resource: service`.
- No subscription lookup is performed for guest projects.

**Verify no subscription lookup:**
- Guest flow in `services.py` goes directly to `plan = FALLBACK_PLAN` branch.
- No DB query to the `subscriptions` table for guest requests.

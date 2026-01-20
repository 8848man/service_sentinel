# ServiceSentinel - API Flow Documentation

**Version**: 2.0.0
**Date**: 2026-01-15
**Purpose**: Describes API flows from a service perspective, including triggers, backend responsibilities, data storage, and frontend expectations.

---

## Table of Contents

1. [Overview](#overview)
2. [Core Flows](#core-flows)
3. [Monitoring Flows](#monitoring-flows)
4. [Incident Management Flows](#incident-management-flows)
5. [AI Analysis Flows](#ai-analysis-flows)
6. [Authentication Flows](#authentication-flows)
7. [Data Synchronization Patterns](#data-synchronization-patterns)

---

## Overview

This document describes how different parts of the system interact from a **service perspective**. Each flow includes:

- **Trigger**: What initiates the flow
- **Backend Responsibility**: What the backend does
- **Data Stored**: What gets persisted
- **Frontend Expected Behavior**: How the frontend should respond

---

## Core Flows

### Flow 1: Project Initialization

**Purpose**: Create a project and set up authentication for monitoring.

#### Sequence

```
User Action → Frontend → Backend
     ↓
[1] User clicks "Create Project"
     ↓
[2] POST /api/v2/projects
     ↓
[3] Backend creates Project record
     ↓
[4] Frontend receives Project response
     ↓
[5] User prompted to "Create API Key"
     ↓
[6] POST /api/v2/projects/{id}/api-keys
     ↓
[7] Backend generates secure API key
     ↓
[8] Frontend receives API Key (ONLY ONCE)
     ↓
[9] Frontend displays key with "Copy" button
     ↓
[10] User copies key, frontend stores encrypted
     ↓
[11] Frontend sets project context (projectId + apiKey)
     ↓
[12] Monitoring can begin
```

#### Trigger
- User action (button click: "Create New Project")

#### Backend Responsibility
1. Validate project name uniqueness (within system, not required but recommended)
2. Create Project record in database
3. Return Project object with ID
4. On API key creation: generate secure random key (`ss_` prefix + 32 bytes URL-safe)
5. Store API key hash (not plain text) - **Note**: Current implementation stores plain text for simplicity; production should hash
6. Return API key object with `key_value` field

#### Data Stored
- **projects table**: New row with name, description, is_active=true
- **api_keys table**: New row with key_value, project_id, name, is_active=true

#### Frontend Expected Behavior
1. Show success message: "Project created successfully"
2. Immediately prompt to create API key
3. Display API key in a modal with:
   - Large, readable text
   - "Copy to Clipboard" button
   - Warning: "This key will only be shown once. Store it securely."
4. After user confirms, store API key in encrypted storage
5. Set global project context (projectId + apiKey)
6. Navigate to project dashboard

---

### Flow 2: Service Registration

**Purpose**: Register a new API/service to monitor within a project.

#### Sequence

```
User Action → Frontend → Backend → Scheduler
     ↓
[1] User fills "Add Service" form
     ↓
[2] POST /api/v2/services (with X-API-Key header)
     ↓
[3] Backend validates API key → extracts project_id
     ↓
[4] Backend creates Service record with project_id
     ↓
[5] Frontend receives Service response
     ↓
[6] Backend scheduler picks up new active service
     ↓
[7] Monitoring begins automatically
```

#### Trigger
- User action (form submission: "Create Service")

#### Backend Responsibility
1. Authenticate API key via `X-API-Key` header
2. Extract project_id from authenticated API key
3. Validate service configuration:
   - endpoint_url is valid URL
   - check_interval_seconds >= 10
   - failure_threshold >= 1
4. Create Service record with project_id
5. Return Service object
6. Scheduler automatically detects new active service (no manual trigger needed)

#### Data Stored
- **services table**: New row with all configuration fields, project_id FK, is_active=true

#### Frontend Expected Behavior
1. Show success message: "Service added successfully"
2. Navigate to service list or service detail page
3. Show "Monitoring Active" badge
4. Poll for first health check result (may take check_interval_seconds)

---

### Flow 3: Service Activation/Deactivation

**Purpose**: Start or stop monitoring for a service.

#### Sequence (Activation)

```
User Action → Frontend → Backend → Scheduler
     ↓
[1] User clicks "Activate Monitoring"
     ↓
[2] POST /api/v2/services/{id}/activate (with X-API-Key)
     ↓
[3] Backend updates Service.is_active = true
     ↓
[4] Scheduler picks up service on next cycle
     ↓
[5] Health checks begin
```

#### Trigger
- User action (button click: "Activate" or "Deactivate")

#### Backend Responsibility
1. Authenticate and verify service belongs to project
2. Update `is_active` field
3. Return updated Service object
4. Scheduler automatically includes/excludes service based on is_active flag

#### Data Stored
- **services table**: Update `is_active` and `updated_at` fields

#### Frontend Expected Behavior
1. Update UI immediately (optimistic update)
2. Show confirmation message
3. If activating: start polling for health checks
4. If deactivating: stop polling, show "Monitoring Paused" badge

---

## Monitoring Flows

### Flow 4: Automatic Health Check

**Purpose**: Backend scheduler automatically checks service health at configured intervals.

#### Sequence

```
Scheduler (Background) → Backend → Database
     ↓
[1] Scheduler timer triggers (every MONITORING_INTERVAL_SECONDS)
     ↓
[2] Fetch all active services (is_active=true)
     ↓
[3] For each service:
         ↓
     [a] Check if check_interval_seconds elapsed since last_checked_at
         ↓
     [b] If yes, perform HTTP request to endpoint_url
         ↓
     [c] Measure latency, capture status_code, response_body
         ↓
     [d] Determine is_alive based on:
         - Request succeeded
         - status_code in expected_status_codes
         - No timeout
         ↓
     [e] Create HealthCheck record
         ↓
     [f] Update Service.last_checked_at
         ↓
     [g] Check for incident conditions
         ↓
     [h] If consecutive failures >= failure_threshold:
             → Trigger incident detection flow
```

#### Trigger
- Time-based: Backend scheduler (APScheduler) runs every 30 seconds (configurable via MONITORING_INTERVAL_SECONDS)

#### Backend Responsibility
1. Query active services
2. Execute HTTP requests asynchronously (using httpx)
3. Handle timeouts, connection errors, SSL errors
4. Create HealthCheck records (immutable)
5. Update Service.last_checked_at timestamp
6. Invoke incident detection logic

#### Data Stored
- **health_checks table**: New row with is_alive, status_code, latency_ms, error_message, checked_at
- **services table**: Update last_checked_at

#### Frontend Expected Behavior
1. If on service detail page: poll GET /api/v2/services/{id}/health-checks/latest every 10-20 seconds
2. Update health status indicator (green/red)
3. Update uptime chart
4. If incident detected: show notification/alert

---

### Flow 5: Manual Health Check (Check Now)

**Purpose**: User triggers immediate health check for a service.

#### Sequence

```
User Action → Frontend → Backend → Database
     ↓
[1] User clicks "Check Now" button
     ↓
[2] POST /api/v2/services/{id}/check-now (with X-API-Key)
     ↓
[3] Backend immediately performs health check
     ↓
[4] HealthCheck record created
     ↓
[5] Frontend receives HealthCheck response
     ↓
[6] UI updates immediately
```

#### Trigger
- User action (button click: "Check Now")

#### Backend Responsibility
1. Authenticate and verify service belongs to project
2. Instantiate MonitoringWorker
3. Perform health check synchronously
4. Create HealthCheck record
5. Update Service.last_checked_at
6. Return HealthCheck object immediately

#### Data Stored
- **health_checks table**: New row
- **services table**: Update last_checked_at

#### Frontend Expected Behavior
1. Show loading spinner on "Check Now" button
2. Display result immediately when received
3. Update health status indicator
4. Show toast notification: "Health check completed"

---

## Incident Management Flows

### Flow 6: Automatic Incident Detection

**Purpose**: Detect and create incidents when consecutive failures exceed threshold.

#### Sequence

```
HealthCheck (Failed) → Incident Detection Service → Database
     ↓
[1] HealthCheck created with is_alive=false
     ↓
[2] Backend queries recent health checks for service
     ↓
[3] Count consecutive failures
     ↓
[4] If count >= Service.failure_threshold:
         ↓
     [a] Check if open incident already exists
         ↓
     [b] If no open incident:
             → Create new Incident
             → Set status=OPEN
             → Set severity based on consecutive failures:
                 - 3-5: MEDIUM
                 - 6-10: HIGH
                 - 11+: CRITICAL
             ↓
     [c] If open incident exists:
             → Update consecutive_failures
             → Update total_affected_checks
             → Update severity if worse
         ↓
[5] Frontend polls and detects new incident
```

#### Trigger
- Automatic: After each failed health check

#### Backend Responsibility
1. Query recent health checks for service
2. Count consecutive failures
3. Compare against failure_threshold
4. Create or update Incident record
5. Set incident severity based on failure count
6. Generate incident title: "Service {name} is down"

#### Data Stored
- **incidents table**: New row with service_id, trigger_check_id, title, status=OPEN, severity, detected_at

#### Frontend Expected Behavior
1. Poll GET /api/v2/incidents?status=open every 10-30 seconds
2. Show notification/alert when new incident detected
3. Update incident counter in navbar/dashboard
4. Optionally play sound or send desktop notification

---

### Flow 7: Incident Acknowledgment

**Purpose**: User acknowledges awareness of an incident.

#### Sequence

```
User Action → Frontend → Backend → Database
     ↓
[1] User clicks "Acknowledge" on incident
     ↓
[2] POST /api/v2/incidents/{id}/acknowledge (with X-API-Key)
     ↓
[3] Backend updates Incident status
     ↓
[4] Frontend receives updated Incident
     ↓
[5] UI reflects acknowledgment
```

#### Trigger
- User action (button click: "Acknowledge")

#### Backend Responsibility
1. Authenticate and verify incident belongs to project
2. Update Incident:
   - status = ACKNOWLEDGED
   - acknowledged_at = current timestamp
3. Return updated Incident object

#### Data Stored
- **incidents table**: Update status, acknowledged_at

#### Frontend Expected Behavior
1. Update incident status immediately (optimistic update)
2. Show confirmation: "Incident acknowledged"
3. Change status badge color
4. Optionally remove from "urgent" list

---

### Flow 8: Incident Resolution

**Purpose**: User marks an incident as resolved.

#### Sequence

```
User Action → Frontend → Backend → Database
     ↓
[1] User clicks "Resolve" on incident
     ↓
[2] POST /api/v2/incidents/{id}/resolve (with X-API-Key)
     ↓
[3] Backend updates Incident status
     ↓
[4] Frontend receives updated Incident
     ↓
[5] UI reflects resolution
```

#### Trigger
- User action (button click: "Resolve")

#### Backend Responsibility
1. Authenticate and verify incident belongs to project
2. Update Incident:
   - status = RESOLVED
   - resolved_at = current timestamp
3. Return updated Incident object

#### Data Stored
- **incidents table**: Update status, resolved_at

#### Frontend Expected Behavior
1. Update incident status immediately
2. Show confirmation: "Incident resolved"
3. Move incident to "Resolved" tab
4. Decrement open incident counter

---

## AI Analysis Flows

### Flow 9: Request AI Analysis

**Purpose**: Generate AI-powered root cause analysis for an incident.

#### Sequence

```
User Action → Frontend → Backend → AI Service → Database
     ↓
[1] User clicks "Analyze with AI" on incident
     ↓
[2] POST /api/v2/incidents/{id}/analysis (with X-API-Key)
     ↓
[3] Backend checks if analysis already exists
     ↓
[4] If exists and force_reanalyze=false:
         → Return existing analysis
     ↓
[5] If not exists or force_reanalyze=true:
         ↓
     [a] Gather context:
         - Service configuration
         - Recent health checks (last 10)
         - Error messages
         - Incident details
         ↓
     [b] Build AI prompt with structured format
         ↓
     [c] Call AI API (Google Gemini, OpenAI, etc.)
         ↓
     [d] Parse AI response
         ↓
     [e] Calculate cost (tokens * rate)
         ↓
     [f] Create AIAnalysis record
         ↓
     [g] Update Incident.ai_analysis_completed = true
         ↓
[6] Frontend receives AIAnalysis response
     ↓
[7] UI displays analysis
```

#### Trigger
- User action (button click: "Analyze with AI")

#### Backend Responsibility
1. Authenticate and verify incident belongs to project
2. Check if analysis exists (unless force_reanalyze=true)
3. Gather incident context:
   - Service endpoint_url, http_method, headers
   - Last 10 health checks (status codes, error messages, latencies)
   - Incident severity, consecutive_failures
4. Construct AI prompt with:
   - System role: "You are an expert DevOps engineer..."
   - Context: service config, error details
   - Request: root cause hypothesis, debug checklist, suggested actions
5. Call AI API (e.g., Google Gemini `gemini-pro`)
6. Parse response (JSON format expected)
7. Track costs:
   - prompt_tokens, completion_tokens
   - total_cost_usd (calculated based on model pricing)
8. Create AIAnalysis record
9. Return AIAnalysis object

#### Data Stored
- **ai_analyses table**: New row with model_used, root_cause_hypothesis, debug_checklist, suggested_actions, total_cost_usd, analyzed_at
- **incidents table**: Update ai_analysis_requested=true, ai_analysis_completed=true

#### Frontend Expected Behavior
1. Show loading spinner: "Analyzing incident..."
2. Display estimated wait time: "This may take 10-30 seconds"
3. On success:
   - Display root cause hypothesis prominently
   - Show debug checklist as checkboxes
   - Show suggested actions as cards
   - Display confidence score (if available)
   - Show cost and model used (transparency)
4. On error:
   - Show error message: "AI analysis failed. Check if AI is enabled in settings."
   - Provide retry button

---

### Flow 10: Retrieve Existing AI Analysis

**Purpose**: Fetch previously generated AI analysis.

#### Sequence

```
User Action → Frontend → Backend → Database
     ↓
[1] User navigates to incident detail page
     ↓
[2] Frontend checks if incident.ai_analysis_completed=true
     ↓
[3] GET /api/v2/incidents/{id}/analysis (with X-API-Key)
     ↓
[4] Backend fetches AIAnalysis record
     ↓
[5] Frontend receives AIAnalysis
     ↓
[6] UI displays analysis
```

#### Trigger
- User navigation (page load: incident detail page)
- Automatic check: if incident.ai_analysis_completed=true

#### Backend Responsibility
1. Authenticate and verify incident belongs to project
2. Query AIAnalysis by incident_id
3. Return AIAnalysis object if exists
4. Return 404 if not exists

#### Data Stored
- No write operations (read-only)

#### Frontend Expected Behavior
1. Check `incident.ai_analysis_completed` flag
2. If true: automatically fetch analysis
3. Display analysis in collapsible section
4. If false: show "Analyze with AI" button

---

## Authentication Flows

### Flow 11: API Key Authentication

**Purpose**: Authenticate requests using API key.

#### Sequence

```
Frontend Request → Middleware → Database → Backend Endpoint
     ↓
[1] Frontend includes X-API-Key header
     ↓
[2] Request hits authentication middleware
     ↓
[3] Middleware extracts API key from header
     ↓
[4] Middleware queries api_keys table
     ↓
[5] Validation checks:
     - Key exists?
     - is_active=true?
     - Not expired (expires_at > now)?
     ↓
[6] If valid:
         → Extract project_id
         → Update last_used_at, increment usage_count
         → Inject project_id into request context
         → Continue to endpoint
     ↓
[7] If invalid:
         → Return 401 Unauthorized
```

#### Trigger
- Every authenticated API request (all /api/v2/* endpoints except /projects)

#### Backend Responsibility
1. Extract `X-API-Key` from request headers
2. Query `api_keys` table by `key_value`
3. Validate:
   - Key exists
   - is_active = true
   - expires_at is null OR expires_at > now()
4. Update usage tracking:
   - last_used_at = now()
   - usage_count += 1
5. Inject authenticated project_id into request context
6. Return 401/403 if validation fails

#### Data Stored
- **api_keys table**: Update last_used_at, usage_count on each successful authentication

#### Frontend Expected Behavior
1. Store API key securely (encrypted local storage or secure cookie)
2. Include `X-API-Key` header in ALL V2 API requests
3. Implement axios/fetch interceptor to automatically add header
4. On 401/403 error:
   - Clear stored API key
   - Redirect to authentication page
   - Show message: "Session expired. Please re-authenticate."

---

## Data Synchronization Patterns

### Pattern 1: Polling for Real-Time Updates

**Use Case**: Dashboard, service list, incident list

**Implementation**:

```typescript
// Pseudo-code
let pollInterval;

function startPolling(endpoint, callback, intervalMs) {
  pollInterval = setInterval(async () => {
    try {
      const data = await fetch(endpoint, {
        headers: { 'X-API-Key': getAPIKey() }
      });
      callback(data);
    } catch (error) {
      handleError(error);
    }
  }, intervalMs);
}

function stopPolling() {
  clearInterval(pollInterval);
}

// Usage
onPageLoad(() => {
  startPolling('/api/v2/dashboard/overview', updateDashboard, 15000); // 15s
});

onPageUnload(() => {
  stopPolling();
});
```

**Recommended Intervals**:
- Dashboard overview: 15-30 seconds
- Service list: 30-60 seconds
- Incident list (active monitoring): 10-30 seconds
- Health check latest: 10-20 seconds

---

### Pattern 2: Optimistic Updates

**Use Case**: Service activation, incident acknowledgment

**Implementation**:

```typescript
// Pseudo-code
async function acknowledgeIncident(incidentId) {
  // 1. Optimistically update UI
  updateUIOptimistically(incidentId, { status: 'acknowledged' });

  try {
    // 2. Make API request
    const updated = await POST(`/api/v2/incidents/${incidentId}/acknowledge`);

    // 3. Update with server response
    updateUI(updated);
  } catch (error) {
    // 4. Rollback on error
    rollbackUI(incidentId);
    showError('Failed to acknowledge incident');
  }
}
```

---

### Pattern 3: Cache and Refresh

**Use Case**: Project list, API key list

**Implementation**:

```typescript
// Pseudo-code
const cache = new Map();

async function getProjects(forceRefresh = false) {
  if (!forceRefresh && cache.has('projects')) {
    return cache.get('projects');
  }

  const projects = await fetch('/api/v2/projects');
  cache.set('projects', projects);
  return projects;
}

// Refresh on user action
onUserClickRefresh(() => {
  getProjects(true);
});
```

---

## Summary

### Key Flows

1. **Project Initialization**: Create project → Create API key → Store key → Begin monitoring
2. **Service Registration**: Add service → Backend validates → Scheduler picks up → Monitoring begins
3. **Automatic Monitoring**: Scheduler checks services → Creates health checks → Detects incidents
4. **Incident Management**: Incident detected → User acknowledges/resolves → Status updated
5. **AI Analysis**: User requests analysis → Backend calls AI API → Analysis stored → Frontend displays

### Backend Responsibilities

- Validate all inputs
- Enforce project-scoping via authentication
- Maintain data consistency
- Perform background monitoring
- Generate AI analyses on demand

### Frontend Responsibilities

- Store API keys securely
- Include authentication headers
- Poll for updates at reasonable intervals
- Handle errors gracefully (401/403)
- Provide clear user feedback
- Stop polling when not needed

---

## Additional Resources

- **README_CLI.md**: Frontend refactoring guide
- **DOMAIN_STRUCTURE.md**: Domain model and aggregates
- **OpenAPI Spec**: `/docs` endpoint on running server

---

**Document Version**: 2.0.0
**Last Updated**: 2026-01-15
**Author**: ServiceSentinel Backend Team

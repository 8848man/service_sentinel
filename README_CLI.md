# ServiceSentinel Backend - Frontend Refactoring Handoff

**Version**: 2.0.0
**Date**: 2026-01-15
**Purpose**: This document provides explicit guidance for refactoring the frontend to work with the new Project-centric backend architecture.

---

## 1. High-Level System Overview

### What Problem This System Solves

ServiceSentinel is an AI-powered monitoring system that continuously checks the health of APIs and services, detects incidents when they fail, and uses AI to analyze failures and suggest solutions.

### Why Project is the Core Unit

**Project** is now the **Aggregate Root** of the entire system. Previously, services (APIs) were standalone entities. Now:

- **Every API/Service must belong to a Project**
- **All monitoring data is project-scoped**
- **Authentication is project-scoped via API Keys**
- **Multi-project, multi-team usage is now supported**

### Source of Truth for Frontend

The frontend should treat **Project ID** as the primary context for all operations. The typical flow is:

1. User selects or creates a Project
2. Frontend obtains an API Key for that Project
3. All subsequent API calls use that API Key to access project-scoped resources

---

## 2. Domain Structure

### Entities and Relationships

```
Project (Aggregate Root)
├── id: int
├── name: string
├── description: string (optional)
├── is_active: boolean
├── created_at: datetime
└── updated_at: datetime
    │
    ├─── API Keys (Authentication)
    │    ├── id: int
    │    ├── project_id: int (FK)
    │    ├── key_value: string (secret, shown once)
    │    ├── name: string
    │    ├── is_active: boolean
    │    ├── usage_count: int
    │    ├── last_used_at: datetime
    │    └── expires_at: datetime (optional)
    │
    └─── Services (API Monitoring Targets)
         ├── id: int
         ├── project_id: int (FK)
         ├── name: string
         ├── endpoint_url: string
         ├── http_method: enum (GET, POST, etc.)
         ├── service_type: enum (http_api, https_api, etc.)
         ├── is_active: boolean
         ├── check_interval_seconds: int
         ├── failure_threshold: int
         └── last_checked_at: datetime
             │
             ├─── Health Checks (Historical Data)
             │    ├── id: int
             │    ├── service_id: int (FK)
             │    ├── is_alive: boolean
             │    ├── status_code: int
             │    ├── latency_ms: int
             │    ├── error_message: string
             │    └── checked_at: datetime
             │
             └─── Incidents (Failure Events)
                  ├── id: int
                  ├── service_id: int (FK)
                  ├── title: string
                  ├── status: enum (open, investigating, acknowledged, resolved)
                  ├── severity: enum (low, medium, high, critical)
                  ├── consecutive_failures: int
                  ├── detected_at: datetime
                  └── resolved_at: datetime (optional)
                      │
                      └─── AI Analysis (Root Cause Analysis)
                           ├── id: int
                           ├── incident_id: int (FK)
                           ├── model_used: string
                           ├── root_cause_hypothesis: string
                           ├── confidence_score: float
                           ├── debug_checklist: array of strings
                           ├── suggested_actions: array of objects
                           └── analyzed_at: datetime
```

### Key Domain Concepts

#### Project
- **Purpose**: Organizational unit for grouping related APIs/services
- **Lifespan**: Long-lived, created by user, contains all monitoring data
- **Deletion**: Cascades to all children (Services, API Keys, Health Checks, Incidents, AI Analyses)

#### APIKey
- **Purpose**: Project-scoped authentication token
- **Usage**: Required for all V2 API endpoints (via `X-API-Key` header)
- **Security**: Key value is only shown ONCE at creation time
- **Scoping**: Each API key grants access to exactly ONE project

#### Service (API)
- **Purpose**: Represents a single API endpoint to monitor
- **Relationship**: Always belongs to a Project (NOT an independent entity)
- **Monitoring**: Backend scheduler automatically checks active services based on `check_interval_seconds`

#### Health Check
- **Purpose**: Records the result of each monitoring check
- **Lifecycle**: Created automatically by the scheduler, read-only for users
- **Usage**: Historical data for uptime statistics and debugging

#### Incident
- **Purpose**: Represents a detected failure event (triggered after consecutive failures exceed threshold)
- **Lifecycle**: Created automatically by incident detection service, updated by users or AI
- **Resolution**: Must be manually resolved or acknowledged by users

#### AI Analysis
- **Purpose**: AI-generated root cause analysis and debugging suggestions
- **Trigger**: Requested manually via POST endpoint (not automatic)
- **Cost Tracking**: Includes token usage and estimated USD cost

---

## 3. API Contract Overview

### Base URL

```
Production: https://your-backend-url.com
Development: http://localhost:8000
```

### API Versioning

- **V1** (`/api/v1/*`): Legacy endpoints, no authentication required, flat service structure (DEPRECATED)
- **V2** (`/api/v2/*`): New project-scoped endpoints, authentication required via API Key

**Frontend should ONLY use V2 endpoints.**

---

### Authentication

All V2 endpoints require authentication via the `X-API-Key` header:

```http
X-API-Key: ss_AbCdEfGh1234567890IjKlMnOpQrStUvWxYz
```

#### Authentication Flow

1. **Create Project**: `POST /api/v2/projects` (no auth required)
2. **Create API Key**: `POST /api/v2/projects/{project_id}/api-keys` (no auth required)
3. **Store API Key**: Frontend must securely store the `key_value` (shown only once)
4. **Use API Key**: Include `X-API-Key` header in all subsequent requests

#### Error Responses

- `401 Unauthorized`: Missing or invalid API key
- `403 Forbidden`: API key is inactive or expired
- `404 Not Found`: Resource not found or doesn't belong to the authenticated project

---

### API Group 1: Projects

#### Purpose
Manage projects (the top-level organizational unit).

#### Endpoints

**Create Project**
```http
POST /api/v2/projects
Content-Type: application/json

{
  "name": "Production Monitoring",
  "description": "Monitors production APIs" // optional
}

Response 201:
{
  "id": 1,
  "name": "Production Monitoring",
  "description": "Monitors production APIs",
  "is_active": true,
  "created_at": "2026-01-15T10:00:00Z",
  "updated_at": "2026-01-15T10:00:00Z"
}
```

**List Projects**
```http
GET /api/v2/projects?is_active=true&skip=0&limit=100

Response 200:
[
  {
    "id": 1,
    "name": "Production Monitoring",
    "description": "...",
    "is_active": true,
    "created_at": "...",
    "updated_at": "..."
  }
]
```

**Get Project with Stats**
```http
GET /api/v2/projects/{project_id}/stats

Response 200:
{
  "id": 1,
  "name": "Production Monitoring",
  "description": "...",
  "is_active": true,
  "created_at": "...",
  "updated_at": "...",
  "total_services": 5,
  "active_services": 4,
  "total_incidents": 12,
  "open_incidents": 2
}
```

**Update Project**
```http
PATCH /api/v2/projects/{project_id}
Content-Type: application/json

{
  "name": "Updated Name",  // optional
  "description": "...",    // optional
  "is_active": false       // optional
}
```

**Delete Project**
```http
DELETE /api/v2/projects/{project_id}

Response 204 No Content
```

---

### API Group 2: API Keys (Project-Scoped)

#### Purpose
Manage API keys for project authentication.

#### Endpoints

**Create API Key**
```http
POST /api/v2/projects/{project_id}/api-keys
Content-Type: application/json

{
  "name": "Production Key",
  "description": "Used by production frontend",  // optional
  "expires_at": "2027-01-15T00:00:00Z"          // optional
}

Response 201:
{
  "id": 1,
  "project_id": 1,
  "key_value": "ss_AbCdEfGh1234567890...",  // ONLY SHOWN ONCE
  "name": "Production Key",
  "description": "...",
  "is_active": true,
  "created_at": "2026-01-15T10:00:00Z",
  "expires_at": "2027-01-15T00:00:00Z",
  "last_used_at": null,
  "usage_count": 0
}
```

**CRITICAL**: The `key_value` is ONLY returned at creation. Frontend must:
- Display it to the user immediately
- Provide copy-to-clipboard functionality
- Warn the user to store it securely
- Never show it again

**List API Keys**
```http
GET /api/v2/projects/{project_id}/api-keys?is_active=true

Response 200:
{
  "project_id": 1,
  "total": 2,
  "items": [
    {
      "id": 1,
      "project_id": 1,
      // NO key_value field
      "name": "Production Key",
      "description": "...",
      "is_active": true,
      "created_at": "...",
      "expires_at": "...",
      "last_used_at": "...",
      "usage_count": 123
    }
  ]
}
```

**Deactivate API Key**
```http
POST /api/v2/projects/{project_id}/api-keys/{key_id}/deactivate

Response 200: (returns updated API key)
```

**Delete API Key**
```http
DELETE /api/v2/projects/{project_id}/api-keys/{key_id}

Response 204 No Content
```

---

### API Group 3: Services (Project-Scoped)

#### Purpose
Manage services (APIs to monitor) within a project.

#### Authentication
All endpoints require `X-API-Key` header.

#### Endpoints

**Create Service**
```http
POST /api/v2/services
X-API-Key: ss_...
Content-Type: application/json

{
  "name": "Auth API",
  "description": "User authentication service",  // optional
  "endpoint_url": "https://api.example.com/health",
  "http_method": "GET",  // GET, POST, PUT, DELETE, PATCH, HEAD
  "service_type": "https_api",  // http_api, https_api, gcp_endpoint, firebase, websocket, grpc
  "headers": {  // optional
    "Authorization": "Bearer token"
  },
  "request_body": {...},  // optional, for POST/PUT
  "expected_status_codes": [200, 204],  // optional, default [200]
  "timeout_seconds": 10,  // optional, default 10
  "check_interval_seconds": 60,  // optional, default 60
  "failure_threshold": 3  // optional, default 3
}

Response 201:
{
  "id": 1,
  "name": "Auth API",
  "description": "...",
  "endpoint_url": "https://api.example.com/health",
  "http_method": "GET",
  "service_type": "https_api",
  "headers": {...},
  "request_body": null,
  "expected_status_codes": [200, 204],
  "timeout_seconds": 10,
  "check_interval_seconds": 60,
  "failure_threshold": 3,
  "is_active": true,
  "created_at": "2026-01-15T10:00:00Z",
  "updated_at": "2026-01-15T10:00:00Z",
  "last_checked_at": null
}
```

**List Services**
```http
GET /api/v2/services?is_active=true&skip=0&limit=100
X-API-Key: ss_...

Response 200:
[
  { /* service object */ }
]
```

**Get Service**
```http
GET /api/v2/services/{service_id}
X-API-Key: ss_...

Response 200:
{ /* service object */ }
```

**Update Service**
```http
PATCH /api/v2/services/{service_id}
X-API-Key: ss_...
Content-Type: application/json

{
  "name": "Updated Name",  // all fields optional
  "is_active": false
}
```

**Delete Service**
```http
DELETE /api/v2/services/{service_id}
X-API-Key: ss_...

Response 204 No Content
```

**Activate/Deactivate Service**
```http
POST /api/v2/services/{service_id}/activate
POST /api/v2/services/{service_id}/deactivate
X-API-Key: ss_...

Response 200: (returns updated service)
```

**Trigger Immediate Health Check**
```http
POST /api/v2/services/{service_id}/check-now
X-API-Key: ss_...

Response 200:
{
  "id": 123,
  "service_id": 1,
  "is_alive": true,
  "status_code": 200,
  "latency_ms": 45,
  "response_body": "...",
  "error_message": null,
  "error_type": null,
  "checked_at": "2026-01-15T10:05:00Z",
  "needs_analysis": false
}
```

**Get Health Check History**
```http
GET /api/v2/services/{service_id}/health-checks?skip=0&limit=100
X-API-Key: ss_...

Response 200:
{
  "service_id": 1,
  "total": 500,
  "items": [
    { /* health check object */ }
  ]
}
```

**Get Latest Health Check**
```http
GET /api/v2/services/{service_id}/health-checks/latest
X-API-Key: ss_...

Response 200:
{ /* health check object */ }
```

**Get Service Stats**
```http
GET /api/v2/services/{service_id}/stats?period=24h
X-API-Key: ss_...

Query params:
- period: "1h" | "24h" | "7d" | "30d"

Response 200:
{
  "service_id": 1,
  "period": "24h",
  "uptime_percentage": 99.5,
  "total_checks": 1440,
  "successful_checks": 1433,
  "failed_checks": 7,
  "avg_latency_ms": 52.3
}
```

**Get Service Incidents**
```http
GET /api/v2/services/{service_id}/incidents?skip=0&limit=100
X-API-Key: ss_...

Response 200:
[
  {
    "id": 1,
    "service_id": 1,
    "service_name": "Auth API",
    "title": "Service Auth API is down",
    "description": "...",
    "status": "open",
    "severity": "critical",
    "consecutive_failures": 5,
    "total_affected_checks": 5,
    "detected_at": "...",
    "resolved_at": null,
    "acknowledged_at": null,
    "ai_analysis_requested": true,
    "ai_analysis_completed": true
  }
]
```

---

### API Group 4: Incidents (Project-Scoped)

#### Purpose
View and manage incidents (failure events).

#### Authentication
All endpoints require `X-API-Key` header.

#### Endpoints

**List Incidents**
```http
GET /api/v2/incidents?status=open&severity=critical&skip=0&limit=100
X-API-Key: ss_...

Query params:
- status: "open" | "investigating" | "acknowledged" | "resolved"
- severity: "low" | "medium" | "high" | "critical"
- service_id: int (optional)

Response 200:
{
  "total": 10,
  "items": [
    {
      "id": 1,
      "service_id": 1,
      "service_name": "Auth API",
      "title": "Service Auth API is down",
      "description": "...",
      "status": "open",
      "severity": "critical",
      "consecutive_failures": 5,
      "total_affected_checks": 5,
      "detected_at": "2026-01-15T09:00:00Z",
      "resolved_at": null,
      "acknowledged_at": null,
      "ai_analysis_requested": true,
      "ai_analysis_completed": true
    }
  ]
}
```

**Get Incident**
```http
GET /api/v2/incidents/{incident_id}
X-API-Key: ss_...

Response 200:
{ /* incident object */ }
```

**Update Incident**
```http
PATCH /api/v2/incidents/{incident_id}
X-API-Key: ss_...
Content-Type: application/json

{
  "status": "investigating",  // optional
  "severity": "high",         // optional
  "description": "..."        // optional
}
```

**Acknowledge Incident**
```http
POST /api/v2/incidents/{incident_id}/acknowledge
X-API-Key: ss_...

Response 200: (returns updated incident with acknowledged_at set)
```

**Resolve Incident**
```http
POST /api/v2/incidents/{incident_id}/resolve
X-API-Key: ss_...

Response 200: (returns updated incident with resolved_at set)
```

**Get AI Analysis**
```http
GET /api/v2/incidents/{incident_id}/analysis
X-API-Key: ss_...

Response 200:
{
  "id": 1,
  "incident_id": 1,
  "model_used": "gemini-pro",
  "prompt_tokens": 500,
  "completion_tokens": 300,
  "total_cost_usd": 0.0025,
  "root_cause_hypothesis": "The service is likely experiencing...",
  "confidence_score": 0.85,
  "debug_checklist": [
    "Check DNS resolution",
    "Verify SSL certificate validity",
    "Check firewall rules"
  ],
  "suggested_actions": [
    {
      "action": "Restart the service",
      "priority": "high",
      "estimated_time": "5 minutes"
    }
  ],
  "related_error_patterns": [...],
  "raw_response": "...",
  "analyzed_at": "2026-01-15T09:05:00Z",
  "analysis_duration_ms": 2500
}

Response 404: (if analysis not requested yet)
```

**Request AI Analysis**
```http
POST /api/v2/incidents/{incident_id}/analysis
X-API-Key: ss_...
Content-Type: application/json

{
  "force_reanalyze": false  // optional, default false
}

Response 200: (returns AI analysis object)
Response 500: (if AI is disabled or API key invalid)
```

---

### API Group 5: Dashboard (Project-Scoped)

#### Purpose
Get aggregated metrics and overview for the project.

#### Authentication
All endpoints require `X-API-Key` header.

#### Endpoints

**Get Dashboard Overview**
```http
GET /api/v2/dashboard/overview
X-API-Key: ss_...

Response 200:
{
  "total_services": 5,
  "healthy_services": 4,
  "unhealthy_services": 1,
  "total_open_incidents": 2,
  "services": [
    {
      "service_id": 1,
      "service_name": "Auth API",
      "service_type": "https_api",
      "is_alive": false,
      "last_check": "2026-01-15T10:00:00Z",
      "latency_ms": null,
      "open_incidents": 1
    }
  ],
  "last_updated": "2026-01-15T10:05:00Z"
}
```

**Get Dashboard Metrics**
```http
GET /api/v2/dashboard/metrics?period=24h
X-API-Key: ss_...

Query params:
- period: "1h" | "24h" | "7d" | "30d"

Response 200:
{
  "period": "24h",
  "total_health_checks": 7200,
  "failed_health_checks": 150,
  "uptime_percentage": 97.92,
  "average_latency_ms": 48.5,
  "total_incidents": 5,
  "open_incidents": 2,
  "ai_analyses_count": 3,
  "ai_total_cost_usd": 0.0125
}
```

---

## 4. API Usage Rules for Frontend

### Initialization Flow

1. **On App Load**:
   - Check if user has selected a project (from local storage or state)
   - If no project selected, show project selection/creation UI
   - If project selected, verify API key exists in secure storage

2. **Project Selection**:
   - User selects or creates a project
   - Frontend prompts for API key (or creates one)
   - Store API key securely (e.g., encrypted local storage, secure cookie)
   - Set project context in global state

3. **Authenticated Requests**:
   - All V2 API requests MUST include `X-API-Key` header
   - If 401/403 received, clear API key and re-prompt user

### Data Caching Strategy

**Should Cache Client-Side**:
- Project list (refresh on user action)
- API key list (without key values)
- Service list for current project (refresh every 30-60 seconds)
- Dashboard overview (refresh every 15-30 seconds)

**Should NOT Cache**:
- Health check results (always fetch fresh)
- Incident list (poll every 10-30 seconds if monitoring page is active)
- AI analysis results (too dynamic)

### Pagination Rules

All list endpoints support pagination:
- Default: `skip=0`, `limit=100`
- Maximum limit: 1000
- Frontend should implement infinite scroll or pagination UI

### Polling Recommendations

For real-time monitoring experience:

- **Dashboard Overview**: Poll every 15-30 seconds
- **Service List**: Poll every 30-60 seconds
- **Incident List**: Poll every 10-30 seconds (only when incidents page is active)
- **Health Check Latest**: Poll every 10-20 seconds (only when viewing specific service)

**IMPORTANT**: Stop polling when user navigates away from monitoring pages to reduce load.

### Error Handling

**401 Unauthorized**:
- Clear API key from storage
- Redirect to API key input page
- Show message: "API key invalid or expired. Please provide a new API key."

**403 Forbidden**:
- Show message: "Access denied. Your API key may be inactive or expired."
- Provide option to re-authenticate

**404 Not Found**:
- Resource doesn't exist OR doesn't belong to authenticated project
- Show appropriate message to user

**500 Internal Server Error**:
- Retry once after 2 seconds
- If still fails, show error message and suggest contacting support

---

## 5. Frontend Assumptions

### What Frontend MUST NOT Infer

- **Do NOT assume** service IDs are globally unique. They are only unique within a project.
- **Do NOT assume** incidents can be accessed without authentication.
- **Do NOT assume** API keys can be retrieved after creation. They are only shown once.
- **Do NOT assume** all services belong to the same project. Always filter by project_id.
- **Do NOT assume** the backend will automatically create an API key. Frontend must explicitly create it.

### What Frontend CAN Rely On

- **Project ID** is the source of truth for all scoping.
- **API Key** authentication is mandatory for all V2 endpoints.
- **Cascade delete** works: deleting a project deletes all services, health checks, incidents, and AI analyses.
- **Automatic monitoring**: services with `is_active=true` are automatically checked by the backend scheduler.
- **Incident creation**: incidents are automatically created when a service exceeds its `failure_threshold`.
- **Idempotency**: Creating the same service twice will fail with 4xx error (name uniqueness within project).

### Pagination Expectations

- All list endpoints return arrays or objects with `total` and `items` fields.
- Use `skip` and `limit` query parameters for pagination.
- Default limit is 100, maximum is 1000.

### Rate Limiting

- No explicit rate limiting is currently enforced.
- Frontend should implement reasonable polling intervals (see Polling Recommendations).
- Avoid making more than 10 requests per second from a single client.

### Error Response Format

All errors follow this format:

```json
{
  "detail": "Error message here"
}
```

---

## 6. Frontend Refactoring Handoff

### Recommended Frontend State Structure

```typescript
// Global State
interface AppState {
  auth: {
    currentProjectId: number | null;
    apiKey: string | null;
    isAuthenticated: boolean;
  };
  projects: {
    list: Project[];
    current: Project | null;
    loading: boolean;
  };
  services: {
    list: Service[];
    loading: boolean;
    lastUpdated: Date | null;
  };
  incidents: {
    list: Incident[];
    openCount: number;
    loading: boolean;
    lastUpdated: Date | null;
  };
  dashboard: {
    overview: DashboardOverview | null;
    metrics: SystemMetrics | null;
    loading: boolean;
    lastUpdated: Date | null;
  };
}
```

### Suggested API Grouping for Frontend Services

Create these frontend service modules:

1. **ProjectService**
   - `createProject()`
   - `listProjects()`
   - `getProject(id)`
   - `updateProject(id, data)`
   - `deleteProject(id)`

2. **APIKeyService**
   - `createAPIKey(projectId, data)`
   - `listAPIKeys(projectId)`
   - `deactivateAPIKey(projectId, keyId)`
   - `deleteAPIKey(projectId, keyId)`

3. **ServiceService** (or MonitoringService)
   - `createService(data)`
   - `listServices(filters)`
   - `getService(id)`
   - `updateService(id, data)`
   - `deleteService(id)`
   - `activateService(id)`
   - `deactivateService(id)`
   - `checkServiceNow(id)`
   - `getHealthChecks(serviceId, pagination)`
   - `getLatestHealthCheck(serviceId)`
   - `getServiceStats(serviceId, period)`
   - `getServiceIncidents(serviceId, pagination)`

4. **IncidentService**
   - `listIncidents(filters, pagination)`
   - `getIncident(id)`
   - `updateIncident(id, data)`
   - `acknowledgeIncident(id)`
   - `resolveIncident(id)`
   - `getAIAnalysis(incidentId)`
   - `requestAIAnalysis(incidentId, forceReanalyze)`

5. **DashboardService**
   - `getOverview()`
   - `getMetrics(period)`

### Authentication & Project Context Handling Rules

1. **On App Initialization**:
   ```typescript
   // Check if user has selected project
   const projectId = localStorage.getItem('currentProjectId');
   const apiKey = secureStorage.get('apiKey'); // encrypted storage

   if (projectId && apiKey) {
     // Set auth context
     setAuthContext({ projectId, apiKey });
     // Fetch project details
     await fetchProject(projectId);
   } else {
     // Redirect to project selection
     navigateTo('/projects');
   }
   ```

2. **API Request Interceptor**:
   ```typescript
   axios.interceptors.request.use((config) => {
     const apiKey = getAPIKey();
     if (apiKey) {
       config.headers['X-API-Key'] = apiKey;
     }
     return config;
   });

   axios.interceptors.response.use(
     (response) => response,
     (error) => {
       if (error.response?.status === 401 || error.response?.status === 403) {
         // Clear auth and redirect
         clearAuth();
         navigateTo('/auth');
       }
       return Promise.reject(error);
     }
   );
   ```

3. **Project Context Provider**:
   ```typescript
   const ProjectContext = createContext();

   export const ProjectProvider = ({ children }) => {
     const [projectId, setProjectId] = useState(null);
     const [apiKey, setAPIKey] = useState(null);

     const switchProject = (newProjectId, newAPIKey) => {
       setProjectId(newProjectId);
       setAPIKey(newAPIKey);
       localStorage.setItem('currentProjectId', newProjectId);
       secureStorage.set('apiKey', newAPIKey);
     };

     const clearProject = () => {
       setProjectId(null);
       setAPIKey(null);
       localStorage.removeItem('currentProjectId');
       secureStorage.remove('apiKey');
     };

     return (
       <ProjectContext.Provider value={{ projectId, apiKey, switchProject, clearProject }}>
         {children}
       </ProjectContext.Provider>
     );
   };
   ```

4. **Routing Structure**:
   ```
   /projects                 → List/select projects
   /projects/new             → Create new project
   /projects/:id/settings    → Project settings & API keys
   /dashboard                → Dashboard (requires project context)
   /services                 → Service list (requires project context)
   /services/new             → Create service (requires project context)
   /services/:id             → Service details (requires project context)
   /incidents                → Incident list (requires project context)
   /incidents/:id            → Incident details (requires project context)
   ```

### Common Mistakes to Avoid During Frontend Refactoring

1. **❌ Forgetting to include X-API-Key header**
   - All V2 endpoints require authentication
   - Set up a global axios interceptor to automatically include the header

2. **❌ Storing API keys in plain text**
   - Never store API keys in localStorage without encryption
   - Use secure storage mechanisms or encrypted cookies

3. **❌ Mixing V1 and V2 endpoints**
   - V1 is deprecated and has no project scoping
   - Always use V2 endpoints for new development

4. **❌ Not handling 401/403 errors**
   - These indicate authentication issues
   - Always redirect to auth flow and clear stored credentials

5. **❌ Assuming services are globally unique**
   - Service IDs are only unique within a project
   - Always filter services by project_id on the backend (automatic in V2)

6. **❌ Polling too frequently**
   - Excessive polling can overload the backend
   - Follow the recommended polling intervals in section 4

7. **❌ Not showing API key at creation time**
   - The `key_value` is ONLY returned at creation
   - Must be displayed to user immediately with copy functionality

8. **❌ Ignoring cascade delete**
   - Deleting a project deletes ALL associated data
   - Warn users before project deletion with a confirmation dialog

9. **❌ Not implementing project switching**
   - Users should be able to switch between projects easily
   - Provide a project selector in the UI (e.g., dropdown in navbar)

10. **❌ Hardcoding project IDs**
    - Always get project ID from auth context
    - Never hardcode project-specific values

### Migration Path from Old Frontend

If you have an existing frontend using V1 endpoints:

1. **Phase 1: Add Project Support**
   - Add project selection UI
   - Implement API key management
   - Add authentication layer

2. **Phase 2: Parallel Implementation**
   - Keep V1 calls working
   - Implement V2 calls in parallel
   - Use feature flags to switch between V1 and V2

3. **Phase 3: Migration**
   - Migrate data to projects (if needed)
   - Switch all components to V2 endpoints
   - Remove V1 code

4. **Phase 4: Cleanup**
   - Remove feature flags
   - Remove V1-related code
   - Update documentation

---

## 7. Testing Checklist for Frontend

Before deploying the refactored frontend, verify:

- [ ] Project creation flow works
- [ ] API key creation shows key value only once
- [ ] API key is stored securely (encrypted)
- [ ] All API requests include X-API-Key header
- [ ] 401/403 errors redirect to auth flow
- [ ] Project switching works correctly
- [ ] Service creation is scoped to current project
- [ ] Dashboard shows only current project's data
- [ ] Incidents are filtered by current project
- [ ] Polling stops when navigating away from monitoring pages
- [ ] Project deletion warns user about cascade delete
- [ ] API key deactivation works
- [ ] Service activation/deactivation works
- [ ] AI analysis request/retrieval works
- [ ] Health check history loads correctly
- [ ] Service stats are calculated correctly

---

## 8. Summary

### Key Takeaways

1. **Project is the Aggregate Root** - all operations are project-scoped
2. **Authentication is mandatory** - use `X-API-Key` header for all V2 endpoints
3. **API keys are shown once** - frontend must handle secure storage
4. **V1 is deprecated** - use V2 endpoints exclusively
5. **Cascade delete** - deleting a project deletes all children
6. **Automatic monitoring** - backend handles scheduling, frontend just displays data

### Next Steps

1. Review this document thoroughly
2. Set up project context in your frontend
3. Implement authentication layer
4. Migrate endpoints from V1 to V2
5. Test thoroughly before deploying

---

**For questions or clarifications, refer to the additional documentation:**
- `DOMAIN_STRUCTURE.md` - Detailed domain model explanation
- `API_FLOWS.md` - Service perspective API flows
- Backend API docs: `/docs` (Swagger UI)

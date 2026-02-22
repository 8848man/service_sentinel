# Service Sentinel v1.1.0 - Frontend Integration Guide

**Version:** 1.1.0
**Release Date:** 2026-01-23
**Target Audience:** Frontend Developers, AI Coding Assistants

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [What's New in v1.1.0](#whats-new-in-v110)
3. [Service State Management](#service-state-management)
4. [Project Health](#project-health)
5. [API Changes](#api-changes)
6. [Migration Guide](#migration-guide)
7. [UI Recommendations](#ui-recommendations)
8. [TypeScript Types](#typescript-types)
9. [Common Use Cases](#common-use-cases)
10. [FAQ](#faq)

---

## Overview

Version 1.1.0 introduces **service-level state tracking** and **derived project health calculations**. These features provide real-time observability without requiring complex client-side computations.

### Key Improvements

- **Service State**: Every service now has a `service_state` field (HEALTHY, ERROR, INACTIVE)
- **Project Health**: New endpoint calculates project health from service states + incidents
- **Dashboard Enhancements**: System-wide metrics and improved project dashboards
- **Zero Breaking Changes**: All changes are additive and backward compatible

---

## What's New in v1.1.0

### 1. Service State Field

Every service response now includes `service_state`:

```json
{
  "id": 123,
  "name": "User API",
  "is_active": true,
  "service_state": "healthy",  // 👈 NEW FIELD
  "endpoint_url": "https://api.example.com",
  // ... other fields
}
```

### 2. Project Health Endpoint

New endpoint to get project-level health:

```http
GET /api/v3/projects/{project_id}/health
```

Response:
```json
{
  "status": "DEGRADED",
  "total_services": 12,
  "healthy_services": 10,
  "error_services": 2,
  "inactive_services": 0,
  "active_incidents": 3
}
```

### 3. Global Dashboard Endpoint

System-wide metrics across all projects:

```http
GET /api/v3/dashboard/global
```

Response:
```json
{
  "total_projects": 45,
  "total_services": 234,
  "healthy_services": 220,
  "error_services": 8,
  "inactive_services": 6,
  "active_incidents": 12,
  "degraded_projects": 7
}
```

---

## Service State Management

### Service State Values

| State | Meaning | When Set |
|-------|---------|----------|
| `healthy` | Service is operational, no incidents | Default for new services, set when incident resolves |
| `error` | Service has an active incident | Set when monitoring detects failures and opens incident |
| `inactive` | Monitoring is paused | Set when `is_active` is changed to `false` |

### State Transitions

```
┌─────────┐
│ HEALTHY │ ←──────────────────┐
└────┬────┘                    │
     │                         │
     │ Incident Opens          │ Incident Resolves
     │                         │ (3 consecutive healthy checks)
     ▼                         │
┌─────────┐                    │
│  ERROR  │────────────────────┘
└────┬────┘
     │
     │ Monitoring Disabled
     │ (is_active = false)
     ▼
┌──────────┐
│ INACTIVE │
└──────────┘
```

### Key Differences: `is_active` vs `service_state`

- **`is_active`**: User control - whether monitoring is enabled
- **`service_state`**: System state - current health status

Example scenarios:

| `is_active` | `service_state` | Meaning |
|-------------|----------------|---------|
| `true` | `healthy` | Service is monitored and healthy |
| `true` | `error` | Service is monitored but has failures |
| `false` | `inactive` | Monitoring disabled (always inactive when `is_active=false`) |

---

## Project Health

### Health Status Values

| Status | Meaning | Calculation |
|--------|---------|-------------|
| `HEALTHY` | All services operational | No error services AND no active incidents |
| `DEGRADED` | Issues detected | At least one error service OR active incident |
| `UNKNOWN` | No data available | Project has zero services |

### Important Concepts

**Project health is NEVER stored in the database.** It is always calculated on-demand from:
1. Service states (by counting services in each state)
2. Active incidents (OPEN or INVESTIGATING status)

This means:
- ✅ Always reflects current system state
- ✅ No synchronization issues
- ✅ No stale data
- ❌ Requires API call to get (not precomputed)

---

## API Changes

### 1. Service Response Schema

**Endpoint:** All service endpoints (`GET /api/v3/projects/{id}/services`, etc.)

**Before v1.1.0:**
```json
{
  "id": 1,
  "name": "API Gateway",
  "is_active": true,
  "endpoint_url": "https://api.example.com",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**After v1.1.0:**
```json
{
  "id": 1,
  "name": "API Gateway",
  "is_active": true,
  "service_state": "healthy",  // 👈 NEW
  "endpoint_url": "https://api.example.com",
  "created_at": "2024-01-01T00:00:00Z"
}
```

### 2. Project Health Endpoint (NEW)

**Endpoint:** `GET /api/v3/projects/{project_id}/health`

**Authentication:** Required (Firebase JWT or API Key)

**Response:**
```json
{
  "status": "HEALTHY" | "DEGRADED" | "UNKNOWN",
  "total_services": 10,
  "healthy_services": 9,
  "error_services": 1,
  "inactive_services": 0,
  "active_incidents": 2
}
```

**Use Case:** Project-level dashboards, health indicators

### 3. Dashboard Overview (Enhanced)

**Endpoint:** `GET /api/v3/projects/{project_id}/dashboard/overview`

**Added Fields:**
```json
{
  "total_services": 10,
  "healthy_services": 8,
  "error_services": 2,           // 👈 NEW
  "inactive_services": 0,        // 👈 NEW
  "unhealthy_services": 2,       // ← Still present (backward compat)
  "services": [
    {
      "service_id": 1,
      "service_name": "API Gateway",
      "service_state": "healthy",  // 👈 NEW
      "is_alive": true,            // ← Still present
      "last_check": "2024-01-01T12:00:00Z"
    }
  ]
}
```

### 4. Global Dashboard Endpoint (NEW)

**Endpoint:** `GET /api/v3/dashboard/global`

**Authentication:** None required (consider adding for production)

**Response:**
```json
{
  "total_projects": 45,
  "total_services": 234,
  "healthy_services": 220,
  "error_services": 8,
  "inactive_services": 6,
  "active_incidents": 12,
  "degraded_projects": 7
}
```

**Use Case:** Admin dashboards, landing pages, status pages

---

## Migration Guide

### Before (v1.0.0)

```typescript
// Check if service is healthy
function getServiceHealth(service: Service, lastCheck?: HealthCheck) {
  if (!service.is_active) {
    return 'inactive';
  }
  if (!lastCheck) {
    return 'unknown';
  }
  return lastCheck.is_alive ? 'healthy' : 'error';
}

// Display badge
const health = getServiceHealth(service, lastHealthCheck);
```

### After (v1.1.0)

```typescript
// Use service_state directly (no computation needed!)
function getServiceHealth(service: Service) {
  return service.service_state;  // 'healthy' | 'error' | 'inactive'
}

// Display badge
const health = service.service_state;
```

### Benefits of Migration

- ✅ Simpler code (no client-side logic)
- ✅ Single source of truth (backend)
- ✅ Real-time accuracy (updated by monitoring worker)
- ✅ Fewer API calls (no need to fetch last health check)

---

## UI Recommendations

### 1. Service Status Badge Component

```tsx
type ServiceState = 'healthy' | 'error' | 'inactive';

interface ServiceBadgeProps {
  state: ServiceState;
}

function ServiceStateBadge({ state }: ServiceBadgeProps) {
  const config = {
    healthy: {
      color: 'green',
      icon: '✓',
      label: 'Healthy',
      bgColor: 'bg-green-100',
      textColor: 'text-green-800'
    },
    error: {
      color: 'red',
      icon: '⚠',
      label: 'Error',
      bgColor: 'bg-red-100',
      textColor: 'text-red-800'
    },
    inactive: {
      color: 'gray',
      icon: '○',
      label: 'Inactive',
      bgColor: 'bg-gray-100',
      textColor: 'text-gray-800'
    }
  };

  const { icon, label, bgColor, textColor } = config[state];

  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${bgColor} ${textColor}`}>
      <span className="mr-1">{icon}</span>
      {label}
    </span>
  );
}

// Usage
<ServiceStateBadge state={service.service_state} />
```

### 2. Project Health Card Component

```tsx
import { useQuery } from '@tanstack/react-query';

interface ProjectHealthCardProps {
  projectId: number;
}

function ProjectHealthCard({ projectId }: ProjectHealthCardProps) {
  const { data: health, isLoading } = useQuery({
    queryKey: ['project-health', projectId],
    queryFn: () => fetchProjectHealth(projectId),
    refetchInterval: 30000  // Poll every 30 seconds
  });

  if (isLoading) {
    return <div>Loading...</div>;
  }

  const statusConfig = {
    HEALTHY: { color: 'green', icon: '✓', message: 'All systems operational' },
    DEGRADED: { color: 'yellow', icon: '⚠', message: 'Some services have issues' },
    UNKNOWN: { color: 'gray', icon: '?', message: 'No services configured' }
  };

  const { color, icon, message } = statusConfig[health.status];

  return (
    <div className={`border-l-4 border-${color}-500 p-4 bg-white shadow rounded`}>
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">
          {icon} Project Health: {health.status}
        </h3>
        {health.active_incidents > 0 && (
          <span className="text-red-600 font-medium">
            {health.active_incidents} active incidents
          </span>
        )}
      </div>

      <p className="text-gray-600 mt-1">{message}</p>

      <div className="mt-4 grid grid-cols-3 gap-4">
        <Stat
          label="Healthy"
          value={health.healthy_services}
          total={health.total_services}
          color="green"
        />
        <Stat
          label="Error"
          value={health.error_services}
          total={health.total_services}
          color="red"
        />
        <Stat
          label="Inactive"
          value={health.inactive_services}
          total={health.total_services}
          color="gray"
        />
      </div>
    </div>
  );
}
```

### 3. Service List with State Filtering

```tsx
function ServiceList({ projectId }: { projectId: number }) {
  const [stateFilter, setStateFilter] = useState<ServiceState | 'all'>('all');
  const { data: services } = useQuery(['services', projectId], fetchServices);

  const filteredServices = services?.filter(s =>
    stateFilter === 'all' || s.service_state === stateFilter
  );

  return (
    <div>
      {/* Filter tabs */}
      <div className="flex gap-2 mb-4">
        <FilterTab
          label={`All (${services?.length})`}
          active={stateFilter === 'all'}
          onClick={() => setStateFilter('all')}
        />
        <FilterTab
          label={`Healthy (${services?.filter(s => s.service_state === 'healthy').length})`}
          active={stateFilter === 'healthy'}
          onClick={() => setStateFilter('healthy')}
        />
        <FilterTab
          label={`Error (${services?.filter(s => s.service_state === 'error').length})`}
          active={stateFilter === 'error'}
          onClick={() => setStateFilter('error')}
        />
        <FilterTab
          label={`Inactive (${services?.filter(s => s.service_state === 'inactive').length})`}
          active={stateFilter === 'inactive'}
          onClick={() => setStateFilter('inactive')}
        />
      </div>

      {/* Service cards */}
      {filteredServices?.map(service => (
        <ServiceCard key={service.id} service={service} />
      ))}
    </div>
  );
}
```

---

## TypeScript Types

### Complete Type Definitions

```typescript
// Service state enum
type ServiceState = 'healthy' | 'error' | 'inactive';

// Project health status
type ProjectHealthStatus = 'HEALTHY' | 'DEGRADED' | 'UNKNOWN';

// Service response (updated)
interface Service {
  id: number;
  name: string;
  description?: string;
  endpoint_url: string;
  http_method: string;
  service_type: string;
  is_active: boolean;
  service_state: ServiceState;  // 👈 NEW
  created_at: string;
  updated_at: string;
  last_checked_at?: string;
  // ... other fields
}

// Project health response
interface ProjectHealth {
  status: ProjectHealthStatus;
  total_services: number;
  healthy_services: number;
  error_services: number;
  inactive_services: number;
  active_incidents: number;
}

// Global dashboard metrics
interface GlobalDashboardMetrics {
  total_projects: number;
  total_services: number;
  healthy_services: number;
  error_services: number;
  inactive_services: number;
  active_incidents: number;
  degraded_projects: number;
}

// Dashboard overview (enhanced)
interface DashboardOverview {
  total_services: number;
  healthy_services: number;
  error_services: number;        // 👈 NEW
  inactive_services: number;     // 👈 NEW
  unhealthy_services: number;    // ← Still present
  total_open_incidents: number;
  services: ServiceHealthSummary[];
  last_updated: string;
}

interface ServiceHealthSummary {
  service_id: number;
  service_name: string;
  service_type: string;
  service_state: ServiceState;   // 👈 NEW
  is_alive?: boolean;            // ← Still present
  last_check?: string;
  latency_ms?: number;
  open_incidents: number;
}
```

### API Client Functions

```typescript
// Fetch project health
async function fetchProjectHealth(projectId: number): Promise<ProjectHealth> {
  const response = await fetch(
    `${API_BASE_URL}/api/v3/projects/${projectId}/health`,
    {
      headers: {
        'Authorization': `Bearer ${getFirebaseToken()}`,
        // or 'X-API-Key': getApiKey()
      }
    }
  );

  if (!response.ok) {
    throw new Error('Failed to fetch project health');
  }

  return response.json();
}

// Fetch global dashboard
async function fetchGlobalDashboard(): Promise<GlobalDashboardMetrics> {
  const response = await fetch(`${API_BASE_URL}/api/v3/dashboard/global`);

  if (!response.ok) {
    throw new Error('Failed to fetch global dashboard');
  }

  return response.json();
}

// Fetch services with state
async function fetchServices(projectId: number): Promise<Service[]> {
  const response = await fetch(
    `${API_BASE_URL}/api/v3/projects/${projectId}/services`,
    {
      headers: {
        'Authorization': `Bearer ${getFirebaseToken()}`
      }
    }
  );

  if (!response.ok) {
    throw new Error('Failed to fetch services');
  }

  return response.json();
}
```

---

## Common Use Cases

### 1. Display Project Overview Dashboard

```typescript
function ProjectDashboard({ projectId }: { projectId: number }) {
  const { data: health } = useQuery(
    ['project-health', projectId],
    () => fetchProjectHealth(projectId),
    { refetchInterval: 30000 }  // Update every 30s
  );

  const { data: services } = useQuery(
    ['services', projectId],
    () => fetchServices(projectId)
  );

  if (!health || !services) {
    return <LoadingSpinner />;
  }

  return (
    <div className="space-y-6">
      {/* Overall health status */}
      <ProjectHealthCard health={health} />

      {/* Show warning if degraded */}
      {health.status === 'DEGRADED' && (
        <Alert severity="warning">
          <AlertTitle>Action Required</AlertTitle>
          {health.error_services > 0 && (
            <p>{health.error_services} service(s) are experiencing errors.</p>
          )}
          {health.active_incidents > 0 && (
            <p>{health.active_incidents} active incident(s) need attention.</p>
          )}
        </Alert>
      )}

      {/* Service list with states */}
      <ServiceListWithFilters services={services} />
    </div>
  );
}
```

### 2. Real-time Service Health Monitoring

```typescript
function ServiceHealthMonitor({ serviceId }: { serviceId: number }) {
  const { data: service } = useQuery(
    ['service', serviceId],
    () => fetchService(serviceId),
    {
      refetchInterval: 10000,  // Poll every 10s
      refetchOnWindowFocus: true
    }
  );

  useEffect(() => {
    if (service?.service_state === 'error') {
      // Show notification
      showNotification({
        title: 'Service Error',
        message: `${service.name} is experiencing issues`,
        type: 'error'
      });
    }
  }, [service?.service_state]);

  return (
    <div>
      <h2>{service?.name}</h2>
      <ServiceStateBadge state={service?.service_state} />
    </div>
  );
}
```

### 3. Filter Services by State

```typescript
function useServicesByState(projectId: number, state?: ServiceState) {
  return useQuery(
    ['services', projectId, state],
    async () => {
      const services = await fetchServices(projectId);

      if (!state) {
        return services;
      }

      return services.filter(s => s.service_state === state);
    }
  );
}

// Usage
const { data: errorServices } = useServicesByState(projectId, 'error');
const { data: healthyServices } = useServicesByState(projectId, 'healthy');
```

### 4. Admin Global Dashboard

```typescript
function AdminDashboard() {
  const { data: metrics } = useQuery(
    ['global-dashboard'],
    fetchGlobalDashboard,
    { refetchInterval: 60000 }  // Update every minute
  );

  if (!metrics) {
    return <LoadingSpinner />;
  }

  const healthPercentage = Math.round(
    (metrics.healthy_services / metrics.total_services) * 100
  );

  return (
    <div className="grid grid-cols-2 gap-6">
      <MetricCard
        title="Total Projects"
        value={metrics.total_projects}
        subtitle={`${metrics.degraded_projects} with issues`}
      />

      <MetricCard
        title="System Health"
        value={`${healthPercentage}%`}
        subtitle={`${metrics.healthy_services}/${metrics.total_services} services healthy`}
      />

      <MetricCard
        title="Active Incidents"
        value={metrics.active_incidents}
        alert={metrics.active_incidents > 0}
      />

      <div className="col-span-2">
        <ServiceHealthChart
          healthy={metrics.healthy_services}
          error={metrics.error_services}
          inactive={metrics.inactive_services}
        />
      </div>
    </div>
  );
}
```

---

## FAQ

### Q: What's the difference between `is_active` and `service_state`?

**A:**
- `is_active`: User-controlled flag for enabling/disabling monitoring
- `service_state`: System-computed health state based on monitoring results

Think of `is_active` as a switch and `service_state` as a status indicator.

### Q: Can a service have `is_active=true` and `service_state='inactive'`?

**A:** No. When `is_active=false`, the service_state is always `'inactive'`. When `is_active=true`, the state is either `'healthy'` or `'error'` depending on incident status.

### Q: How often does `service_state` update?

**A:** Immediately when:
- An incident opens (transitions to `'error'`)
- An incident auto-resolves (transitions to `'healthy'`)
- Monitoring is disabled (transitions to `'inactive'`)

### Q: Should I cache project health?

**A:** Only briefly (< 30 seconds). Project health is cheap to calculate and should reflect real-time status. Use polling or WebSocket (future) for updates.

### Q: How do I know if a service is being monitored?

**A:** Check both flags:
- `is_active=true` AND `service_state != 'inactive'` → Being monitored
- `is_active=false` OR `service_state == 'inactive'` → Not monitored

### Q: What triggers a service to go into `'error'` state?

**A:** When monitoring detects failures exceeding the `failure_threshold` (default: 3 consecutive failures), an incident is automatically opened and the service transitions to `'error'`.

### Q: What triggers a service to return to `'healthy'` state?

**A:** When the service has 3 consecutive successful health checks, the open incident is auto-resolved and the service transitions back to `'healthy'`.

### Q: Can I manually change service_state?

**A:** No. `service_state` is managed automatically by the backend. You can only control `is_active` to enable/disable monitoring.

### Q: Is project health stored in the database?

**A:** No. Project health is **always calculated on-demand** from current service states and incidents. This ensures it's always accurate and never stale.

### Q: Will this update break my existing frontend?

**A:** No. All changes are **backward compatible**. Existing fields remain unchanged. New fields are additions only.

### Q: Do I need to update my code immediately?

**A:** No. Your existing code will continue to work. You can gradually adopt:
1. Start displaying `service_state` in service views
2. Add project health indicators to dashboards
3. Use global dashboard for admin pages

### Q: What if I'm still using v1 or v2 APIs?

**A:** The new fields are available in all API versions (v1, v2, v3). However, the new endpoints are v3 only:
- `GET /api/v3/projects/{id}/health` (v3 only)
- `GET /api/v3/dashboard/global` (v3 only)

---

## Additional Resources

- **CHANGELOG.md**: Detailed technical changes
- **API Documentation**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Migration Script**: `migrations/002_add_service_state.sql`
- **GitHub Issues**: Report bugs or request features

---

## Feedback & Support

Found a bug or have a suggestion? Please open an issue:
- **GitHub**: [Your Repo URL]
- **Email**: [Your Support Email]

---

**Happy Coding!** 🚀

*Generated for Service Sentinel v1.1.0 - January 2026*

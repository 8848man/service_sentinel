# ServiceSentinel API Examples

This document contains practical examples for using the ServiceSentinel API.

## Base URL

```
http://localhost:8000/api/v1
```

## Authentication

Currently, no authentication is required. In production, implement JWT or API key authentication.

## Service Management

### 1. Create a Service

```bash
curl -X POST "http://localhost:8000/api/v1/services" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My API Service",
    "description": "Production API endpoint",
    "endpoint_url": "https://api.example.com/health",
    "http_method": "GET",
    "service_type": "https_api",
    "headers": {},
    "expected_status_codes": [200],
    "timeout_seconds": 10,
    "check_interval_seconds": 60,
    "failure_threshold": 3
  }'
```

**Response:**
```json
{
  "id": 1,
  "name": "My API Service",
  "description": "Production API endpoint",
  "endpoint_url": "https://api.example.com/health",
  "http_method": "GET",
  "service_type": "https_api",
  "headers": {},
  "request_body": null,
  "expected_status_codes": [200],
  "timeout_seconds": 10,
  "check_interval_seconds": 60,
  "failure_threshold": 3,
  "is_active": true,
  "created_at": "2024-01-08T10:00:00Z",
  "updated_at": "2024-01-08T10:00:00Z",
  "last_checked_at": null
}
```

### 2. List All Services

```bash
curl "http://localhost:8000/api/v1/services"
```

### 3. Get Service Details

```bash
curl "http://localhost:8000/api/v1/services/1"
```

### 4. Update Service

```bash
curl -X PATCH "http://localhost:8000/api/v1/services/1" \
  -H "Content-Type: application/json" \
  -d '{
    "check_interval_seconds": 30,
    "failure_threshold": 5
  }'
```

### 5. Trigger Manual Health Check

```bash
curl -X POST "http://localhost:8000/api/v1/services/1/check-now"
```

**Response:**
```json
{
  "id": 123,
  "service_id": 1,
  "is_alive": true,
  "status_code": 200,
  "latency_ms": 145,
  "response_body": null,
  "error_message": null,
  "error_type": null,
  "checked_at": "2024-01-08T10:05:00Z",
  "needs_analysis": false
}
```

### 6. Get Health Check History

```bash
curl "http://localhost:8000/api/v1/services/1/health-checks?limit=10"
```

### 7. Get Service Statistics

```bash
curl "http://localhost:8000/api/v1/services/1/stats?period=24h"
```

**Response:**
```json
{
  "service_id": 1,
  "uptime_percentage": 99.5,
  "total_checks": 1440,
  "successful_checks": 1433,
  "failed_checks": 7,
  "avg_latency_ms": 142.5,
  "period": "24h"
}
```

### 8. Deactivate Service

```bash
curl -X POST "http://localhost:8000/api/v1/services/1/deactivate"
```

### 9. Delete Service

```bash
curl -X DELETE "http://localhost:8000/api/v1/services/1"
```

## Incident Management

### 1. List All Incidents

```bash
# All incidents
curl "http://localhost:8000/api/v1/incidents"

# Filter by status
curl "http://localhost:8000/api/v1/incidents?status=open"

# Filter by severity
curl "http://localhost:8000/api/v1/incidents?severity=critical"

# Combine filters
curl "http://localhost:8000/api/v1/incidents?status=open&severity=high"
```

**Response:**
```json
{
  "total": 3,
  "items": [
    {
      "id": 42,
      "service_id": 1,
      "service_name": "My API Service",
      "trigger_check_id": 123,
      "title": "My API Service - HTTP 503 Error",
      "description": "Service: My API Service\nEndpoint: https://api.example.com/health\nError: Service Unavailable\nStatus Code: 503\nLatency: 5234ms\nTime: 2024-01-08T09:55:00Z",
      "status": "open",
      "severity": "critical",
      "consecutive_failures": 5,
      "total_affected_checks": 5,
      "detected_at": "2024-01-08T09:55:00Z",
      "resolved_at": null,
      "acknowledged_at": null,
      "ai_analysis_requested": false,
      "ai_analysis_completed": false
    }
  ]
}
```

### 2. Get Incident Details

```bash
curl "http://localhost:8000/api/v1/incidents/42"
```

### 3. Acknowledge Incident

```bash
curl -X POST "http://localhost:8000/api/v1/incidents/42/acknowledge"
```

### 4. Resolve Incident

```bash
curl -X POST "http://localhost:8000/api/v1/incidents/42/resolve"
```

### 5. Request AI Analysis

```bash
curl -X POST "http://localhost:8000/api/v1/incidents/42/analysis" \
  -H "Content-Type: application/json" \
  -d '{
    "force_reanalyze": false
  }'
```

**Response:**
```json
{
  "id": 100,
  "incident_id": 42,
  "model_used": "gpt-4-turbo",
  "prompt_tokens": 450,
  "completion_tokens": 320,
  "total_cost_usd": 0.0182,
  "root_cause_hypothesis": "The service is experiencing a 503 error, likely due to:\n1. Database connection pool exhaustion\n2. Downstream service dependency failure\n3. Resource limits (CPU/Memory) being exceeded",
  "confidence_score": 0.85,
  "debug_checklist": [
    "Check database connection pool metrics",
    "Verify downstream service status",
    "Review CPU and memory usage",
    "Check application logs for exceptions",
    "Verify load balancer health"
  ],
  "suggested_actions": [
    {
      "action": "Restart the application server pool",
      "priority": "high",
      "estimated_impact": "Should restore service in 2-3 minutes"
    },
    {
      "action": "Scale up database connection pool size",
      "priority": "medium",
      "estimated_impact": "Prevents future occurrences"
    },
    {
      "action": "Add circuit breaker to downstream services",
      "priority": "low",
      "estimated_impact": "Improves resilience to dependency failures"
    }
  ],
  "related_error_patterns": [
    "503 Service Unavailable",
    "Database connection timeout",
    "Resource exhaustion"
  ],
  "analyzed_at": "2024-01-08T10:00:30Z",
  "analysis_duration_ms": 3200
}
```

### 6. Get AI Analysis

```bash
curl "http://localhost:8000/api/v1/incidents/42/analysis"
```

## Dashboard

### 1. Get Overview

```bash
curl "http://localhost:8000/api/v1/dashboard/overview"
```

**Response:**
```json
{
  "total_services": 15,
  "active_services": 12,
  "services_healthy": 10,
  "services_warning": 1,
  "services_down": 1,
  "services_unknown": 0,
  "open_incidents": 2,
  "critical_incidents": 1,
  "services": [
    {
      "id": 1,
      "name": "My API Service",
      "status": "down",
      "last_check_is_alive": false,
      "last_check_latency_ms": 5234,
      "last_checked_at": "2024-01-08T10:05:00Z",
      "active_incident_id": 42,
      "active_incident_severity": "critical"
    }
  ]
}
```

### 2. Get System Metrics

```bash
curl "http://localhost:8000/api/v1/dashboard/metrics"
```

**Response:**
```json
{
  "total_services_monitored": 12,
  "successful_checks_last_hour": 720,
  "failed_checks_last_hour": 15,
  "avg_check_duration_ms": 145.5,
  "ai_analyses_performed": 23,
  "total_ai_cost_usd": 0.42,
  "incidents_open": 2,
  "incidents_resolved_today": 5
}
```

## Health Checks

### 1. API Health

```bash
curl "http://localhost:8000/health"
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-08T10:00:00Z"
}
```

### 2. Database Health

```bash
curl "http://localhost:8000/health/db"
```

**Response:**
```json
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2024-01-08T10:00:00Z"
}
```

## Advanced Examples

### Service with Authentication Header

```bash
curl -X POST "http://localhost:8000/api/v1/services" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Authenticated API",
    "endpoint_url": "https://api.example.com/private/health",
    "http_method": "GET",
    "service_type": "https_api",
    "headers": {
      "Authorization": "Bearer sk-1234567890abcdef",
      "X-API-Version": "v1"
    },
    "expected_status_codes": [200, 204],
    "timeout_seconds": 15,
    "check_interval_seconds": 120,
    "failure_threshold": 5
  }'
```

### POST Endpoint Monitoring

```bash
curl -X POST "http://localhost:8000/api/v1/services" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Webhook Endpoint",
    "endpoint_url": "https://api.example.com/webhook/health",
    "http_method": "POST",
    "service_type": "https_api",
    "headers": {
      "Content-Type": "application/json"
    },
    "request_body": {
      "check": "health",
      "timestamp": "{{now}}"
    },
    "expected_status_codes": [200, 201],
    "timeout_seconds": 10,
    "check_interval_seconds": 60,
    "failure_threshold": 3
  }'
```

## Python Examples

### Using requests library

```python
import requests

BASE_URL = "http://localhost:8000/api/v1"

# Create service
service_data = {
    "name": "My API Service",
    "endpoint_url": "https://api.example.com/health",
    "http_method": "GET",
    "service_type": "https_api",
    "expected_status_codes": [200],
    "timeout_seconds": 10,
    "check_interval_seconds": 60,
    "failure_threshold": 3
}

response = requests.post(f"{BASE_URL}/services", json=service_data)
service = response.json()
print(f"Created service: {service['id']}")

# Get dashboard overview
overview = requests.get(f"{BASE_URL}/dashboard/overview").json()
print(f"Total services: {overview['total_services']}")
print(f"Services down: {overview['services_down']}")

# List open incidents
incidents = requests.get(
    f"{BASE_URL}/incidents",
    params={"status": "open"}
).json()
print(f"Open incidents: {incidents['total']}")

# Request AI analysis for incident
if incidents['items']:
    incident_id = incidents['items'][0]['id']
    analysis = requests.post(
        f"{BASE_URL}/incidents/{incident_id}/analysis"
    ).json()
    print(f"Root cause: {analysis['root_cause_hypothesis']}")
```

## JavaScript Examples

### Using fetch API

```javascript
const BASE_URL = 'http://localhost:8000/api/v1';

// Create service
async function createService() {
  const response = await fetch(`${BASE_URL}/services`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      name: 'My API Service',
      endpoint_url: 'https://api.example.com/health',
      http_method: 'GET',
      service_type: 'https_api',
      expected_status_codes: [200],
      timeout_seconds: 10,
      check_interval_seconds: 60,
      failure_threshold: 3
    })
  });

  const service = await response.json();
  console.log('Created service:', service.id);
  return service;
}

// Get dashboard overview
async function getDashboard() {
  const response = await fetch(`${BASE_URL}/dashboard/overview`);
  const overview = await response.json();
  console.log('Services:', overview.total_services);
  console.log('Down:', overview.services_down);
  return overview;
}

// List incidents
async function getIncidents() {
  const response = await fetch(`${BASE_URL}/incidents?status=open`);
  const data = await response.json();
  console.log('Open incidents:', data.total);
  return data.items;
}

// Use the functions
createService();
getDashboard();
getIncidents();
```

## Tips

1. **Pagination**: Use `skip` and `limit` parameters for large result sets
2. **Filtering**: Combine multiple query parameters for precise filtering
3. **Error Handling**: Always check response status codes and handle errors
4. **Rate Limiting**: Implement client-side rate limiting for bulk operations
5. **AI Costs**: Monitor AI analysis costs via dashboard metrics

# Changelog

All notable changes to ServiceSentinel Backend will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-08

### Added

#### Core Features
- **Service Management**
  - Create, read, update, delete services
  - Support for HTTP/HTTPS endpoints
  - Configurable HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD)
  - Custom headers and request bodies
  - Expected status codes configuration
  - Timeout and interval settings
  - Failure threshold configuration

- **Health Monitoring**
  - Automated periodic health checks
  - Background scheduler using APScheduler
  - Concurrent health check execution
  - Latency tracking
  - Error detection and classification
  - Response body capture for failed checks

- **Incident Management**
  - Automatic incident detection based on failure thresholds
  - Incident severity classification (Critical, High, Medium, Low)
  - Consecutive failure tracking
  - Incident status management (Open, Investigating, Resolved, Acknowledged)
  - Auto-resolution when service recovers

- **AI-Powered Failure Analysis**
  - Integration with OpenAI GPT-4 and compatible models
  - Root cause hypothesis generation
  - Debug checklist creation
  - Prioritized action suggestions
  - Related error pattern identification
  - Cost tracking per analysis

- **Dashboard & Analytics**
  - Multi-service health overview
  - System-wide metrics
  - Uptime statistics
  - Service health status (Healthy, Warning, Down, Unknown)
  - Real-time monitoring status

#### API Endpoints
- `/api/v1/services` - Full CRUD operations
- `/api/v1/services/{id}/health-checks` - Health check history
- `/api/v1/services/{id}/stats` - Uptime statistics
- `/api/v1/services/{id}/check-now` - Manual health check trigger
- `/api/v1/incidents` - Incident management
- `/api/v1/incidents/{id}/analysis` - AI analysis
- `/api/v1/dashboard/overview` - Dashboard overview
- `/api/v1/dashboard/metrics` - System metrics

#### Database Models
- Service model with advanced configuration
- HealthCheck model with detailed results
- Incident model with status tracking
- AIAnalysis model with cost tracking
- Support for SQLite (development) and PostgreSQL (production)

#### Architecture
- Repository pattern for data access
- Service layer for business logic
- Clean separation of concerns
- Async/await support for health checks
- Background worker for monitoring

#### Developer Experience
- Comprehensive API documentation (Swagger/ReDoc)
- Docker and Docker Compose support
- Example API requests
- Extensive README
- Deployment guide
- Testing framework setup

### Technical Details
- FastAPI 0.110.0
- SQLAlchemy 2.0.25
- Python 3.10+ support
- PostgreSQL compatibility
- Pydantic v2 for validation
- APScheduler for background tasks

### Configuration
- Environment-based configuration
- Configurable monitoring intervals
- AI model selection
- CORS support
- Logging configuration

### Documentation
- README.md with quick start guide
- API_EXAMPLES.md with curl and code examples
- DEPLOYMENT.md with production setup
- .env.example with all configuration options
- Inline code documentation

## [1.1.0] - 2026-01-23

### Added

#### Service State Management
- **Service State Tracking**: Added `service_state` enum field to Service model
  - States: `HEALTHY`, `ERROR`, `INACTIVE`
  - Automatically updated based on incident lifecycle
  - Synchronized with `is_active` flag changes
  - Default state is `HEALTHY` for new services

- **Incident Lifecycle Integration**
  - Service state transitions to `ERROR` when incident opens
  - Service state transitions to `HEALTHY` when incident auto-resolves
  - Service state transitions to `INACTIVE` when monitoring disabled (`is_active=False`)
  - State updates logged for observability

#### Project Health (Derived)
- **Project Health Calculation**: New derived health status for projects
  - Calculated from service states + active incidents (never stored in database)
  - Health states: `HEALTHY`, `DEGRADED`, `UNKNOWN`
  - `DEGRADED` if any error services OR active incidents exist
  - `HEALTHY` if all services healthy and no incidents
  - `UNKNOWN` if project has no services
  - Accessible via `GET /api/v3/projects/{id}/health`

- **Health Metrics Included**
  - `total_services`: All services in project
  - `healthy_services`: Services in HEALTHY state
  - `error_services`: Services in ERROR state
  - `inactive_services`: Services in INACTIVE state
  - `active_incidents`: Open or investigating incidents count

#### Dashboard Enhancements
- **Global Aggregations**: System-wide metrics across all projects
  - Endpoint: `GET /api/v3/dashboard/global`
  - Total projects count
  - Services by state (healthy/error/inactive)
  - Active incidents count
  - Degraded projects count (projects with errors or incidents)
  - Useful for admin dashboards and overview pages

- **Project-Scoped Dashboard Updates**
  - Enhanced `GET /api/v3/projects/{id}/dashboard/overview` endpoint
  - Service responses now include `service_state` field
  - Added `error_services` count to dashboard overview
  - Backward compatible with existing `unhealthy_services` field
  - Service health now based on state rather than last check

### Changed

#### API Responses (Non-Breaking)
- **ServiceResponse Schema**: Added `service_state` field
  - Exposes real-time health state in all service responses
  - Backward compatible - all existing fields preserved

- **DashboardOverview Schema**: Added `error_services` and `inactive_services` fields
  - Enhanced dashboard with state-based metrics
  - Backward compatible - existing fields unchanged

#### Internal Architecture
- **State Synchronization**: Centralized state updates via `ServiceRepository.update_state()`
  - Single source of truth for state transitions
  - Called by incident service lifecycle hooks
  - Ensures consistency across the system

- **Monitoring Worker**: Enhanced with state transition triggers
  - Automatically updates service state on incident creation/resolution
  - Integrated with existing health check flow

- **Repository Pattern**: Enhanced with state-aware query methods
  - Efficient GROUP BY queries for service state aggregations
  - Subquery patterns for project-scoped health calculations
  - Indexed columns for fast dashboard queries

### Technical Details

#### Database Changes
- **Migration 002**: `002_add_service_state.sql`
  - Added `service_state` column to services table
  - Backfilled existing data intelligently:
    - `is_active=False` → `INACTIVE`
    - `is_active=True` + open incidents → `ERROR`
    - All others → `HEALTHY`
  - Created index `idx_services_state` for efficient queries
  - Created composite index `idx_services_project_state` for project health

#### Design Principles
- Service state is the single source of truth for health
- Project health is always derived, never denormalized
- Zero breaking changes to existing v1/v2/v3 APIs
- Backward compatible with existing monitoring logic
- State updates within database transactions for consistency

### Upgrade Path

1. **Apply Database Migration**
   ```bash
   sqlite3 servicesentinel.db < migrations/002_add_service_state.sql
   ```

2. **Restart Application**
   - Service states will be initialized from migration backfill
   - Incident lifecycle will auto-sync states on next event

3. **Frontend Integration** (Optional)
   - Start consuming new `service_state` field in service responses
   - Integrate project health endpoint for project-level dashboards
   - Use global dashboard endpoint for system overview pages
   - See `README_v1.1.md` for detailed integration guide

### Benefits
- **Real-time Observability**: Service health visible without checking latest health check
- **Project-Level Visibility**: Understand project health at a glance
- **Simplified Frontend Logic**: No need to compute health states client-side
- **Performance**: Indexed queries make dashboard loads fast
- **Scalability**: Derived health scales with no storage overhead

## [Unreleased]

### Planned Features
- [ ] Notification system (Email, Slack, Discord, SMS)
- [ ] WebSocket support for real-time updates
- [ ] Service groups and dependencies
- [ ] Custom alert rules and conditions
- [ ] Historical trend analysis
- [ ] Multi-tenancy support
- [ ] Rate limiting
- [ ] API authentication (JWT/API keys)
- [ ] Advanced analytics and reporting
- [ ] Service health score calculation
- [ ] Automated remediation actions
- [ ] Integration with monitoring tools (Prometheus, Grafana)
- [ ] Mobile app support
- [ ] SLA tracking and reporting

### Known Issues
- None reported

### Breaking Changes
- None

---

## Version History

### Version 1.0.0 (2024-01-08)
- Initial release with core monitoring features
- AI-powered failure analysis
- RESTful API
- Dashboard and metrics
- Docker support
- Production-ready architecture

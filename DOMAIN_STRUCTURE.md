# ServiceSentinel - Domain Structure Documentation

**Version**: 2.0.0
**Date**: 2026-01-15

---

## Table of Contents

1. [Introduction](#introduction)
2. [Domain-Driven Design Principles](#domain-driven-design-principles)
3. [Aggregate Roots](#aggregate-roots)
4. [Entities](#entities)
5. [Value Objects](#value-objects)
6. [Domain Services](#domain-services)
7. [Relationships and Boundaries](#relationships-and-boundaries)
8. [Why Project is the Aggregate Root](#why-project-is-the-aggregate-root)
9. [Why Services are NOT Aggregate Roots](#why-services-are-not-aggregate-roots)
10. [Domain Model Diagram](#domain-model-diagram)

---

## Introduction

ServiceSentinel 2.0 has been refactored from a flat, service-centric architecture to a **Project-centric** architecture based on Domain-Driven Design (DDD) principles. This document explains the domain model, the reasoning behind structural decisions, and the boundaries of each domain concept.

### Core Principle

**Project is the Aggregate Root.** All monitoring activities, services, incidents, and analyses belong to a Project. This enables multi-project, multi-team usage while maintaining clear boundaries and data isolation.

---

## Domain-Driven Design Principles

### Aggregate Pattern

An **Aggregate** is a cluster of domain objects that can be treated as a single unit. Each aggregate has:

1. **Aggregate Root**: The only entity that external objects can hold references to
2. **Consistency Boundary**: Changes to objects within the aggregate are kept consistent
3. **Transactional Boundary**: All changes within an aggregate should happen in a single transaction

### Entity vs Value Object

- **Entity**: Has identity and lifecycle (e.g., Project, Service, Incident)
- **Value Object**: Immutable, identified by its attributes (e.g., ServiceType enum, HttpMethod enum)

---

## Aggregate Roots

### 1. Project (Primary Aggregate Root)

**Purpose**: Organizational unit for grouping related monitoring targets (APIs/services).

**Characteristics**:
- Has unique identity (ID)
- Controls lifecycle of all child entities
- Enforces invariants (business rules)
- External access point for the aggregate

**Invariants**:
- A Project must have a unique name (within the system)
- A Project can only be deleted if explicitly requested (cascade delete is intentional)
- All child entities (Services, API Keys) must belong to exactly one Project

**Lifecycle**:
- Created by user action
- Long-lived (persists across sessions)
- Deletion is destructive (cascades to all children)

**Why it's an Aggregate Root**:
1. **Clear Boundary**: All services, incidents, and monitoring data belong to a Project
2. **Consistency**: Changes to a Project's services should maintain project-level consistency
3. **Transactional Integrity**: Deleting a Project should delete all related data atomically
4. **External Reference**: API Keys reference Projects, not individual Services

---

## Entities

Entities within the Project aggregate:

### 1. APIKey (Entity within Project Aggregate)

**Purpose**: Provides authentication and authorization for project-scoped API access.

**Characteristics**:
- Has unique identity (ID + key_value)
- Belongs to exactly one Project
- Mutable state (can be activated/deactivated)
- Tracks usage (last_used_at, usage_count)

**Lifecycle**:
- Created by user action (POST /projects/{id}/api-keys)
- Key value shown only once at creation
- Can be deactivated (soft delete) or deleted (hard delete)
- Deletion does not cascade

**Relationships**:
- **Parent**: Project (mandatory, foreign key)
- **Children**: None

**Business Rules**:
- Key value must be unique across the system
- Cannot be reactivated if expired
- Usage tracking is automatic (updated on each authenticated request)

---

### 2. Service (Entity within Project Aggregate)

**Purpose**: Represents an API or monitoring target.

**Characteristics**:
- Has unique identity (ID)
- Belongs to exactly one Project
- Mutable configuration (endpoint, interval, threshold, etc.)
- Has operational state (is_active, last_checked_at)

**Lifecycle**:
- Created by user action (POST /api/v2/services)
- Long-lived (persists until explicitly deleted or project is deleted)
- Deletion cascades to HealthChecks and Incidents

**Relationships**:
- **Parent**: Project (mandatory, foreign key)
- **Children**: HealthCheck (1-to-many), Incident (1-to-many)

**Business Rules**:
- Service name must be unique within a Project (not globally)
- Cannot be deleted if active monitoring is in progress (recommendation, not enforced)
- Monitoring only occurs if is_active = true

**Why it's NOT an Aggregate Root**:
- Services do not exist independently of Projects
- Service operations (CRUD) are meaningless without Project context
- Service identity is scoped to a Project, not global
- Deleting a Service does not affect other Services (no cross-service consistency needed)

---

### 3. HealthCheck (Entity within Service)

**Purpose**: Records the result of a single monitoring check.

**Characteristics**:
- Has unique identity (ID)
- Belongs to exactly one Service
- Immutable after creation (write-once, read-many)
- Historical data

**Lifecycle**:
- Created automatically by monitoring worker
- Never updated (immutable)
- Deleted when parent Service is deleted (cascade)

**Relationships**:
- **Parent**: Service (mandatory, foreign key)
- **Children**: Incident (1-to-1, optional via trigger_check_id)

**Business Rules**:
- Cannot be manually created via API (only by scheduler)
- Cannot be updated (historical integrity)
- Soft TTL (old records can be archived/deleted by background job)

---

### 4. Incident (Entity within Service)

**Purpose**: Represents a detected failure event.

**Characteristics**:
- Has unique identity (ID)
- Belongs to exactly one Service
- Mutable state (status, severity)
- Triggered by consecutive failures exceeding threshold

**Lifecycle**:
- Created automatically by incident detection service
- Updated by user actions (acknowledge, resolve) or AI analysis
- Deletion when parent Service is deleted (cascade)

**Relationships**:
- **Parent**: Service (mandatory, foreign key)
- **Children**: AIAnalysis (1-to-1, optional)
- **Related**: HealthCheck (via trigger_check_id)

**Business Rules**:
- Cannot be created manually (only by incident detection service)
- Status transitions: open → investigating/acknowledged → resolved
- Cannot be re-opened once resolved (create new incident instead)

---

### 5. AIAnalysis (Entity within Incident)

**Purpose**: Stores AI-generated root cause analysis for an incident.

**Characteristics**:
- Has unique identity (ID)
- Belongs to exactly one Incident (1-to-1 relationship)
- Immutable after creation (write-once)
- Includes cost tracking

**Lifecycle**:
- Created by user action (POST /incidents/{id}/analysis)
- Never updated (unless force_reanalyze=true, creates new record)
- Deleted when parent Incident is deleted (cascade)

**Relationships**:
- **Parent**: Incident (mandatory, foreign key, unique)
- **Children**: None

**Business Rules**:
- Cannot be created without an Incident
- Model and cost tracking are mandatory
- Can be regenerated with force_reanalyze flag

---

## Value Objects

Value Objects in ServiceSentinel are implemented as enums (immutable).

### ServiceType (Enum)
- `http_api`, `https_api`, `gcp_endpoint`, `firebase`, `websocket`, `grpc`
- Describes the type of service being monitored

### HttpMethod (Enum)
- `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`
- Describes the HTTP method for the health check

### IncidentStatus (Enum)
- `open`, `investigating`, `acknowledged`, `resolved`
- Describes the current state of an incident

### IncidentSeverity (Enum)
- `low`, `medium`, `high`, `critical`
- Describes the impact level of an incident

---

## Domain Services

Domain Services encapsulate business logic that doesn't naturally fit within an entity.

### 1. MonitoringWorker (Domain Service)

**Purpose**: Performs health checks for active services.

**Responsibilities**:
- Fetch active services from database
- Execute HTTP/HTTPS requests to service endpoints
- Create HealthCheck records
- Trigger incident detection

**Why it's a Domain Service**:
- Coordinates multiple entities (Service, HealthCheck, Incident)
- Business logic spans multiple aggregates
- Stateless (no persistent identity)

---

### 2. IncidentDetectionService (Domain Service)

**Purpose**: Detects incidents based on failure patterns.

**Responsibilities**:
- Analyze consecutive failures
- Compare against failure_threshold
- Create Incident records
- Determine incident severity

**Why it's a Domain Service**:
- Complex business logic (pattern detection)
- Involves multiple entities
- Stateless

---

### 3. AIAnalysisService (Domain Service)

**Purpose**: Generates AI-powered root cause analysis for incidents.

**Responsibilities**:
- Gather incident context (service config, recent health checks, error messages)
- Call AI API (OpenAI, Anthropic, Google)
- Parse AI response
- Create AIAnalysis record
- Track costs

**Why it's a Domain Service**:
- Integrates external system (AI API)
- Coordinates multiple entities
- Complex business logic
- Stateless

---

## Relationships and Boundaries

### Aggregate Boundaries

```
┌─────────────────────────────────────────────────────┐
│ Project (Aggregate Root)                            │
│ ┌─────────────────────────────────────────────────┐ │
│ │ APIKey (Entity)                                 │ │
│ │ - Provides authentication                       │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ Service (Entity)                                │ │
│ │ ┌───────────────────────────────────────────┐   │ │
│ │ │ HealthCheck (Entity)                      │   │ │
│ │ │ - Immutable historical record             │   │ │
│ │ └───────────────────────────────────────────┘   │ │
│ │                                                 │ │
│ │ ┌───────────────────────────────────────────┐   │ │
│ │ │ Incident (Entity)                         │   │ │
│ │ │ ┌─────────────────────────────────────┐   │   │ │
│ │ │ │ AIAnalysis (Entity)                 │   │   │ │
│ │ │ │ - 1-to-1 relationship with Incident │   │   │ │
│ │ │ └─────────────────────────────────────┘   │   │ │
│ │ └───────────────────────────────────────────┘   │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Cascade Delete Rules

- **Project deleted** → All APIKeys, Services, HealthChecks, Incidents, AIAnalyses deleted
- **Service deleted** → All HealthChecks, Incidents, AIAnalyses deleted
- **Incident deleted** → AIAnalysis deleted (if exists)
- **APIKey deleted** → No cascade (independent entity)
- **HealthCheck deleted** → No cascade (leaf entity)
- **AIAnalysis deleted** → No cascade (leaf entity)

### Cross-Aggregate References

- APIKey references Project (by project_id)
- Service references Project (by project_id)
- External systems (frontend) reference Project via API Key

**Rule**: Never directly reference entities inside another aggregate. Always go through the aggregate root.

---

## Why Project is the Aggregate Root

### 1. Clear Transactional Boundary

When a Project is deleted, all associated data must be deleted atomically. This is a single transaction that maintains consistency.

### 2. Invariant Enforcement

Projects enforce invariants such as:
- All Services within a Project have unique names
- All API Keys within a Project are valid and active
- Project-level quotas (future feature: max services per project)

### 3. External Reference Point

External systems (frontend, CLI, third-party integrations) interact with the system through Projects, not Services. API Keys are project-scoped, not service-scoped.

### 4. Business Logic Cohesion

Business rules like "a project can have at most 100 services" or "a project must have at least one active API key" are naturally enforced at the Project level.

### 5. Scalability and Multi-Tenancy

Project-scoping enables:
- Data isolation between teams
- Separate billing/quotas per project
- Role-based access control (future feature)

---

## Why Services are NOT Aggregate Roots

### 1. No Independent Identity

Services do not have meaning outside of a Project. A Service's identity is scoped to its Project. Two projects can have services with the same name without conflict.

### 2. No Cross-Service Consistency Rules

There are no business rules that require consistency across multiple Services. Each Service is monitored independently. If one Service fails, it doesn't affect other Services.

### 3. No External References

External systems do not directly reference Services. They reference Projects and then query for Services within that Project. API Keys grant access to a Project, not to individual Services.

### 4. Lifecycle Dependency

Services cannot exist without a Project. When a Project is deleted, all Services are deleted. This parent-child relationship indicates that Service is an entity within the Project aggregate, not an independent aggregate.

### 5. Simplified Transactional Logic

By making Project the aggregate root, we avoid complex distributed transactions. All Service operations happen within the context of a single Project, making transactions simple and atomic.

---

## Domain Model Diagram

### Mermaid Diagram

```mermaid
erDiagram
    PROJECT ||--o{ API_KEY : "has"
    PROJECT ||--o{ SERVICE : "contains"
    SERVICE ||--o{ HEALTH_CHECK : "monitors via"
    SERVICE ||--o{ INCIDENT : "triggers"
    INCIDENT ||--o| AI_ANALYSIS : "analyzed by"
    HEALTH_CHECK ||--o| INCIDENT : "triggers"

    PROJECT {
        int id PK
        string name
        string description
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    API_KEY {
        int id PK
        int project_id FK
        string key_value UK
        string name
        boolean is_active
        datetime created_at
        datetime expires_at
        datetime last_used_at
        int usage_count
    }

    SERVICE {
        int id PK
        int project_id FK
        string name
        string endpoint_url
        enum http_method
        enum service_type
        json headers
        json request_body
        json expected_status_codes
        int timeout_seconds
        int check_interval_seconds
        int failure_threshold
        boolean is_active
        datetime created_at
        datetime updated_at
        datetime last_checked_at
    }

    HEALTH_CHECK {
        int id PK
        int service_id FK
        boolean is_alive
        int status_code
        int latency_ms
        text response_body
        text error_message
        string error_type
        datetime checked_at
        boolean needs_analysis
    }

    INCIDENT {
        int id PK
        int service_id FK
        int trigger_check_id FK
        string title
        text description
        enum status
        enum severity
        int consecutive_failures
        int total_affected_checks
        datetime detected_at
        datetime resolved_at
        datetime acknowledged_at
        boolean ai_analysis_requested
        boolean ai_analysis_completed
    }

    AI_ANALYSIS {
        int id PK
        int incident_id FK UK
        string model_used
        int prompt_tokens
        int completion_tokens
        float total_cost_usd
        text root_cause_hypothesis
        float confidence_score
        json debug_checklist
        json suggested_actions
        json related_error_patterns
        text raw_response
        datetime analyzed_at
        int analysis_duration_ms
    }
```

### ASCII Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         PROJECT                              │
│  (Aggregate Root)                                            │
│  - id, name, description, is_active                         │
│  - created_at, updated_at                                   │
└──────┬────────────────────────────────────────────┬─────────┘
       │                                            │
       │ 1:N                                   1:N │
       ▼                                            ▼
┌──────────────┐                         ┌──────────────────┐
│   API_KEY    │                         │     SERVICE      │
│              │                         │                  │
│ - key_value  │                         │ - endpoint_url   │
│ - name       │                         │ - http_method    │
│ - is_active  │                         │ - service_type   │
│ - expires_at │                         │ - is_active      │
└──────────────┘                         └─────────┬────────┘
                                                   │
                                          1:N      │
                              ┌───────────────────┴──────────┐
                              │                              │
                              ▼ 1:N                          ▼ 1:N
                     ┌──────────────────┐          ┌──────────────────┐
                     │  HEALTH_CHECK    │          │    INCIDENT      │
                     │                  │          │                  │
                     │ - is_alive       │          │ - title          │
                     │ - status_code    │          │ - status         │
                     │ - latency_ms     │          │ - severity       │
                     │ - checked_at     │          │ - detected_at    │
                     └──────────────────┘          └─────────┬────────┘
                                                             │
                                                             │ 1:1
                                                             ▼
                                                   ┌──────────────────┐
                                                   │   AI_ANALYSIS    │
                                                   │                  │
                                                   │ - root_cause     │
                                                   │ - debug_checklist│
                                                   │ - analyzed_at    │
                                                   └──────────────────┘
```

---

## Summary

### Key Points

1. **Project is the Aggregate Root**: All domain operations are scoped to a Project
2. **APIKey provides authentication**: Project-scoped access control
3. **Service is an entity within Project**: Not an independent aggregate
4. **HealthCheck is immutable**: Historical data, never updated
5. **Incident is mutable**: State transitions based on user actions
6. **AIAnalysis is write-once**: Immutable after creation (unless regenerated)

### Design Decisions

| Decision | Rationale |
|----------|-----------|
| Project as Aggregate Root | Enables multi-tenancy, clear transactional boundaries, scalability |
| Service NOT as Aggregate Root | No cross-service consistency rules, lifecycle dependency on Project |
| APIKey scoped to Project | Simplifies authentication, enables project-level access control |
| Cascade delete from Project | Maintains referential integrity, prevents orphaned data |
| Immutable HealthCheck | Historical data integrity, simplifies querying |
| Mutable Incident | Requires user actions to transition states |

---

## Additional Resources

- **README_CLI.md**: Frontend refactoring guide
- **API_FLOWS.md**: Service perspective API flows
- **OpenAPI Spec**: `/docs` endpoint on running server

---

**Document Version**: 2.0.0
**Last Updated**: 2026-01-15
**Author**: ServiceSentinel Backend Team

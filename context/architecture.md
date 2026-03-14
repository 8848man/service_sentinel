# System Architecture

The system monitors registered services, detects failures,
and notifies users when incidents occur.

The architecture separates monitoring execution, incident processing,
and user-driven AI analysis to ensure scalability and cost control.

---

# System Components

## Client (Web / Mobile Applications)

Responsibilities:

- user interaction
- data visualization
- communication with API server
- local caching of static and preset data

Two client types are supported:

- **Web application** for detailed monitoring configuration, project management, and incident inspection
- **Mobile application** for simplified service management and rapid incident response

## API Server

Responsibilities:

- request routing
- authentication and authorization
- application business logic
- persistence coordination
- incident management
- handling AI analysis requests

## Monitoring Scheduler

Responsibilities:

- schedules monitoring jobs
- determines monitoring intervals for registered services
- dispatches monitoring tasks to workers

## Background Worker

Responsibilities:

- executes monitoring jobs
- performs service health checks
- evaluates service responses
- produces monitoring results
- detects incidents


## Notification System

Responsibilities:

- delivers incident notifications
- sends alerts to registered users


## AI Analysis Service

Responsibilities:

- analyzes incident context
- generates potential root cause explanations
- provides troubleshooting suggestions

AI analysis is triggered **on-demand by users** rather than automatically during monitoring execution.


## Database

PostgreSQL relational database.

Responsibilities:

- persistent data storage
- transactional consistency
- service configuration storage
- monitoring result storage
- incident history storage
- AI analysis result storage

---

# System Interactions

Client -> API Server

API Server -> Database

Monitoring Scheduler -> Background Worker

Background Worker -> Database

Background Worker -> Notification System

Client -> API Server (AI analysis request)

API Server -> AI Analysis Service

AI Analysis Service -> Database

---

# Monitoring Pipeline

The monitoring system follows the pipeline below.

Service Endpoint
    ↓
Monitoring Scheduler
    ↓
Monitoring Worker
    ↓
Health Evaluation
    ↓
Incident Detection
    ↓
Notification

Monitoring policies such as thresholds, retry logic, and incident resolution rules
are defined in feature specifications.

---

# AI Analysis Flow

AI-powered incident analysis is performed only when requested by users.

User
    ↓
Client Request
    ↓
API Server
    ↓
AI Analysis Service
    ↓
Analysis Result Storage

---

# Domain Overview

Detailed domain definitions are described in `domain-model.md`.
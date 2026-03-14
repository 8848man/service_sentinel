# Backend Refactoring Plan

Aligns `be/app/` with `context/project_conventions.md`.

All paths are relative to `be/`.

---

## Step 1 — Remove v1/v2 legacy files and router registrations

### What to change

**1.1 Edit `app/main.py`**

Remove these import lines:
```python
from app.api import services, incidents, dashboard
from app.api import projects, services_v2, incidents_v2, dashboard_v2
```

Remove these router-registration blocks:
```python
# Include routers - V1 (Legacy, un-authenticated)
app.include_router(services.router, prefix="/api/v1")
app.include_router(incidents.router, prefix="/api/v1")
app.include_router(dashboard.router, prefix="/api/v1")

# Include routers - V2 (Project-scoped with authentication)
app.include_router(projects.router, prefix="/api/v2")
app.include_router(services_v2.router, prefix="/api/v2")
app.include_router(incidents_v2.router, prefix="/api/v2")
app.include_router(dashboard_v2.router, prefix="/api/v2")
```

**1.2 Delete these files:**
- `app/api/dashboard.py`
- `app/api/dashboard_v2.py`
- `app/api/incidents.py`
- `app/api/incidents_v2.py`
- `app/api/projects.py`
- `app/api/services.py`
- `app/api/services_v2.py`

### Affected imports
Only `app/main.py` imports from these modules. No other files reference them.

### Completion criteria
- `app/api/` contains only `__init__.py` and the `v3/` subdirectory.
- `app/main.py` contains no `/api/v1` or `/api/v2` router registrations.
- `python -c "from app.main import app"` succeeds without `ModuleNotFoundError`.

### Checklist before next step
- [ ] `app/api/` has no v1/v2 files remaining
- [ ] `app/main.py` router section contains only v3 includes
- [ ] Application starts without import errors

---

## Step 2 — Move `scheduler.py` into `services/monitoring/`

### What to change

**2.1 Move file:**
- Source: `app/scheduler.py`
- Target: `app/services/monitoring/scheduler.py`

The file content is unchanged. No internal imports need updating (it already imports from `app.services.monitoring.monitoring_worker` and `app.core.config`).

**2.2 Edit `app/main.py`**

Replace:
```python
from app.scheduler import start_scheduler, stop_scheduler
```
With:
```python
from app.services.monitoring.scheduler import start_scheduler, stop_scheduler
```

### Affected imports
Only `app/main.py` imports from `app.scheduler`.

### Completion criteria
- `app/scheduler.py` no longer exists.
- `app/services/monitoring/scheduler.py` exists with identical content.
- `app/main.py` imports from `app.services.monitoring.scheduler`.

### Checklist before next step
- [ ] `app/scheduler.py` deleted
- [ ] `app/services/monitoring/scheduler.py` created with identical content
- [ ] `app/main.py` import updated
- [ ] Application starts without import errors

---

## Step 3 — Merge `core/notification/` into `services/notification/`

This step has six sub-steps. Complete them in order; do not commit until the sub-step is done.

---

### Step 3.1 — Move module-level files

**Move (content unchanged):**
- `app/core/notification/context.py` → `app/services/notification/context.py`
- `app/core/notification/decision.py` → `app/services/notification/decision.py`
- `app/core/notification/enum.py` → `app/services/notification/enum.py`
- `app/core/notification/policy_chain.py` → `app/services/notification/policy_chain.py`

No import lines inside these four files reference `app.core.notification`, so their internal content is unchanged.

### Completion criteria
- All four files exist at the new paths under `app/services/notification/`.
- The old files no longer exist under `app/core/notification/`.

---

### Step 3.2 — Move `policies/` subtree

**Move (content unchanged):**
- `app/core/notification/policies/__init__.py` → `app/services/notification/policies/__init__.py`
- `app/core/notification/policies/base.py` → `app/services/notification/policies/base.py`
- `app/core/notification/policies/chain.py` → `app/services/notification/policies/chain.py`
- `app/core/notification/policies/incident.py` → `app/services/notification/policies/incident.py`
- `app/core/notification/policies/project.py` → `app/services/notification/policies/project.py`
- `app/core/notification/policies/service.py` → `app/services/notification/policies/service.py`
- `app/core/notification/policies/user_plan.py` → `app/services/notification/policies/user_plan.py`

### Completion criteria
- `app/services/notification/policies/` contains all seven files above.
- `app/core/notification/policies/` is empty (or removed).

---

### Step 3.3 — Move `rules/` subtree

**Move (content unchanged):**
- `app/core/notification/rules/__init__.py` → `app/services/notification/rules/__init__.py`
- `app/core/notification/rules/evaluator.py` → `app/services/notification/rules/evaluator.py`
- `app/core/notification/rules/parser.py` → `app/services/notification/rules/parser.py`
- `app/core/notification/rules/rule.py` → `app/services/notification/rules/rule.py`

### Completion criteria
- `app/services/notification/rules/` contains all four files.
- `app/core/notification/rules/` is empty (or removed).

---

### Step 3.4 — Update imports in moved files

Edit the following files that were just moved to `app/services/notification/` and still contain `app.core.notification` import paths.

**`app/services/notification/policies/base.py`**
```python
# Before
from app.core.notification.decision import NotificationDecision
# After
from app.services.notification.decision import NotificationDecision
```

**`app/services/notification/policies/chain.py`**
```python
# Before
from app.core.notification.context import NotificationContext
from app.core.notification.decision import NotificationDecision
from app.core.notification.policies.base import NotificationPolicy
# After
from app.services.notification.context import NotificationContext
from app.services.notification.decision import NotificationDecision
from app.services.notification.policies.base import NotificationPolicy
```

**`app/services/notification/policies/project.py`**
```python
# Before
from app.core.notification.policies.base import NotificationPolicy
from app.core.notification.decision import NotificationDecision
# After
from app.services.notification.policies.base import NotificationPolicy
from app.services.notification.decision import NotificationDecision
```

**`app/services/notification/policies/service.py`**
```python
# Before
from app.core.notification.policies.base import NotificationPolicy
from app.core.notification.decision import NotificationDecision
# After
from app.services.notification.policies.base import NotificationPolicy
from app.services.notification.decision import NotificationDecision
```

---

### Step 3.5 — Update imports in existing callers

Edit every file outside `core/notification/` that imports from `app.core.notification.*`.

**`app/services/notification/context_factory.py`**
```python
# Before
from app.core.notification.context import NotificationContext
# After
from app.services.notification.context import NotificationContext
```

**`app/services/notification/usecase.py`**
```python
# Before
from app.core.notification.context import NotificationContext
from app.core.notification.decision import NotificationDecision
from app.core.notification.policies.chain import PolicyChain
from app.core.notification.policies.base import NotificationPolicy
# After
from app.services.notification.context import NotificationContext
from app.services.notification.decision import NotificationDecision
from app.services.notification.policies.chain import PolicyChain
from app.services.notification.policies.base import NotificationPolicy
```

**`app/services/notification/senders/base.py`**
```python
# Before
from app.core.notification.context import NotificationContext
# After
from app.services.notification.context import NotificationContext
```

**`app/services/notification/senders/firebase_sender.py`**
```python
# Before
from app.core.notification.context import NotificationContext
# After
from app.services.notification.context import NotificationContext
```

**`app/services/notification/senders/log.py`**
```python
# Before
from app.core.notification.context import NotificationContext
# After
from app.services.notification.context import NotificationContext
```

**`app/services/incident_service.py`**
```python
# Before
from app.core.notification.context import NotificationContext
# After
from app.services.notification.context import NotificationContext
```

**`app/services/monitoring/monitoring_worker.py`**
```python
# Before
from app.core.notification.policies.project import ProjectPolicy
from app.core.notification.policies.service import ServicePolicy
# After
from app.services.notification.policies.project import ProjectPolicy
from app.services.notification.policies.service import ServicePolicy
```

**`app/main_notification_test.py`**
```python
# Before
from app.core.notification.context import NotificationContext
# After
from app.services.notification.context import NotificationContext
```

---

### Step 3.6 — Delete `core/notification/`

Delete:
- `app/core/notification/__init__.py`
- The now-empty directory `app/core/notification/` (including subdirectories if not already gone).

### Completion criteria for Step 3 (all sub-steps)
- `app/core/notification/` directory does not exist.
- `grep -r "app.core.notification" app/` returns no results.
- All moved policy/context/decision files exist under `app/services/notification/`.

### Checklist before next step
- [ ] No file in `app/` contains `from app.core.notification`
- [ ] `app/services/notification/` contains `context.py`, `decision.py`, `enum.py`, `policy_chain.py`
- [ ] `app/services/notification/policies/` contains all seven policy files
- [ ] `app/services/notification/rules/` contains all four rule files
- [ ] `app/core/notification/` is deleted
- [ ] Application starts without import errors

---

## Step 4 — Rename non-conforming `schemas/` files to `*_schema.py`

The convention requires all schema files to follow `{resource}_schema.py`. Three files do not:

| Current path | Target path |
|---|---|
| `app/schemas/auth_context.py` | `app/schemas/auth_context_schema.py` |
| `app/schemas/device_token.py` | `app/schemas/device_token_schema.py` |
| `app/schemas/common.py` | `app/schemas/common_schema.py` |

---

### Step 4.1 — Rename `auth_context.py` → `auth_context_schema.py`

**Move:** `app/schemas/auth_context.py` → `app/schemas/auth_context_schema.py`
(File content unchanged.)

**Update these callers:**

`app/core/auth_v3.py`
```python
# Before
from app.schemas.auth_context import AuthContext
# After
from app.schemas.auth_context_schema import AuthContext
```

`app/api/v3/dashboard.py`
```python
# Before
from app.schemas.auth_context import AuthContext
# After
from app.schemas.auth_context_schema import AuthContext
```

`app/api/v3/incidents.py`
```python
# Before
from app.schemas.auth_context import AuthContext
# After
from app.schemas.auth_context_schema import AuthContext
```

`app/api/v3/projects.py`
```python
# Before
from app.schemas.auth_context import AuthContext
# After
from app.schemas.auth_context_schema import AuthContext
```

`app/api/v3/services.py`
```python
# Before
from app.schemas.auth_context import AuthContext
# After
from app.schemas.auth_context_schema import AuthContext
```

---

### Step 4.2 — Rename `device_token.py` → `device_token_schema.py`

**Move:** `app/schemas/device_token.py` → `app/schemas/device_token_schema.py`
(File content unchanged.)

**Update this caller:**

`app/api/v3/device_token.py`
```python
# Before
from app.schemas.device_token import DeviceTokenRegisterRequest
# After
from app.schemas.device_token_schema import DeviceTokenRegisterRequest
```

---

### Step 4.3 — Rename `common.py` → `common_schema.py`

**Move:** `app/schemas/common.py` → `app/schemas/common_schema.py`
(File content unchanged — currently empty.)

Run `grep -r "from app.schemas.common import\|from app.schemas import common" app/` to confirm no callers exist before committing.

### Completion criteria for Step 4
- `app/schemas/` contains no files without the `_schema.py` suffix (other than `__init__.py`).
- `grep -r "from app.schemas.auth_context import\|from app.schemas.device_token import\|from app.schemas.common import" app/` returns no results.

### Checklist before next step
- [ ] `app/schemas/auth_context.py` deleted; `auth_context_schema.py` exists
- [ ] `app/schemas/device_token.py` deleted; `device_token_schema.py` exists
- [ ] `app/schemas/common.py` deleted; `common_schema.py` exists
- [ ] All five callers of `auth_context` updated
- [ ] `device_token` caller updated
- [ ] Application starts without import errors

---

## Step 5 — Remove schema imports from repositories

Convention: repositories must not import from `schemas/`. They receive and return ORM model instances only. Schema conversion is the responsibility of the router or service layer.

---

### Step 5.1 — `health_check_repository.py`

**Source:** `app/repositories/health_check_repository.py`

**Current violation:**
```python
from app.schemas.health_check_schema import HealthCheckCreate
```
Used as a type hint: `def create(self, data: dict | HealthCheckCreate) -> HealthCheck`

**Fix:**
1. Delete the import line.
2. Change the method signature:
   ```python
   # Before
   def create(self, data: dict | HealthCheckCreate) -> HealthCheck:
   # After
   def create(self, data: dict) -> HealthCheck:
   ```
3. Remove the `isinstance(data, dict)` branch — the body already handles the dict case. The method becomes:
   ```python
   def create(self, data: dict) -> HealthCheck:
       health_check = HealthCheck(**data)
       self.db.add(health_check)
       self.db.commit()
       self.db.refresh(health_check)
       return health_check
   ```

**Callers to update:** Any caller that passes a `HealthCheckCreate` instance must change to `health_check_repo.create(data.model_dump())`.
Run `grep -r "health_check_repository\|HealthCheckRepository" app/services app/api` to find all call sites.

---

### Step 5.2 — `incident_repository.py`

**Source:** `app/repositories/incident_repository.py`

**Current violation:**
```python
from app.schemas.incident_schema import IncidentCreate
```
Used as a type hint: `def create(self, data: IncidentCreate | dict) -> Incident`

**Fix:**
1. Delete the import line.
2. Change the method signature:
   ```python
   # Before
   def create(self, data: IncidentCreate | dict) -> Incident:
   # After
   def create(self, data: dict) -> Incident:
   ```
3. Remove the `isinstance(data, dict)` branch:
   ```python
   def create(self, data: dict) -> Incident:
       incident = Incident(**data)
       self.db.add(incident)
       self.db.commit()
       self.db.refresh(incident)
       return incident
   ```

**Callers to update:** Run `grep -r "incident_repository\|IncidentRepository" app/services app/api` and update any call that passes an `IncidentCreate` object to pass `.model_dump()` instead.

---

### Step 5.3 — `service_repository.py`

**Source:** `app/repositories/service_repository.py`

**Current violation:**
```python
from app.schemas.service_schema import ServiceCreate, ServiceUpdate
```
Used in two method signatures:
- `def create(self, project_id: int, data: ServiceCreate) -> Service`
- `def update(self, service_id: int, data: ServiceUpdate) -> Optional[Service]`

**Fix:**
1. Delete the import line.
2. Change `create` to accept `dict`:
   ```python
   # Before
   def create(self, project_id: int, data: ServiceCreate) -> Service:
       service = Service(**data.model_dump(exclude_unset=True, mode='json'))
       service.endpoint_url = str(data.endpoint_url)
   # After
   def create(self, project_id: int, data: dict) -> Service:
       service = Service(**data)
       # endpoint_url is already a string — caller must convert before passing
   ```
3. Change `update` to accept `dict`:
   ```python
   # Before
   def update(self, service_id: int, data: ServiceUpdate) -> Optional[Service]:
       update_data = data.model_dump(exclude_unset=True)
   # After
   def update(self, service_id: int, data: dict) -> Optional[Service]:
       update_data = data
   ```

**Callers to update:** Run `grep -r "service_repo\.create\|service_repo\.update\|ServiceRepository" app/services app/api`.
Each caller that passes `ServiceCreate`/`ServiceUpdate` objects must call `.model_dump(exclude_unset=True, mode='json')` (for create) or `.model_dump(exclude_unset=True)` (for update) before passing to the repository.

---

### Step 5.4 — `project_repository.py`

**Source:** `app/repositories/project_repository.py`

**Current violations:**
```python
from app.schemas.project_schema import ProjectHealth, ProjectResponse
```
- `ProjectHealth` is used as a return type and instantiated directly in `get_health_map()`.
- `ProjectResponse` is imported but not used in any method body — dead import.

**Fix — part A: move `ProjectHealth` to the models layer**

1. Open `app/schemas/project_schema.py` and locate the `ProjectHealth` class (lines ~24–31).
2. Copy `ProjectHealth` into `app/models/project.py` as a standalone Pydantic `BaseModel` (no SQLAlchemy mixins needed — it is a computed view, not an ORM table).
3. In `app/schemas/project_schema.py`, replace the inline `ProjectHealth` definition with a re-export:
   ```python
   from app.models.project import ProjectHealth  # re-export for schema consumers
   ```
4. In `app/api/v3/projects.py`, the existing import `from app.schemas.project_schema import ProjectHealth` continues to work via the re-export — no change needed there.

**Fix — part B: update `project_repository.py`**

1. Replace:
   ```python
   from app.schemas.project_schema import ProjectHealth, ProjectResponse
   ```
   With:
   ```python
   from app.models.project import ProjectHealth
   ```
2. `ProjectResponse` was a dead import; it is simply removed.

### Completion criteria for Step 5
- `grep -r "from app.schemas" app/repositories/` returns no results.
- All repository `create`/`update` methods accept `dict` instead of schema objects.
- `ProjectHealth` is defined in `app/models/project.py` and re-exported from `app/schemas/project_schema.py`.
- Application starts without import errors.

### Checklist before closing
- [ ] `health_check_repository.py` has no schema import; `create` accepts `dict`
- [ ] `incident_repository.py` has no schema import; `create` accepts `dict`
- [ ] `service_repository.py` has no schema import; `create`/`update` accept `dict`
- [ ] `project_repository.py` imports `ProjectHealth` from `app.models.project`
- [ ] `app/models/project.py` defines `ProjectHealth`
- [ ] `app/schemas/project_schema.py` re-exports `ProjectHealth` from models
- [ ] All callers of the updated repository methods pass `dict` (not schema objects)
- [ ] `grep -r "from app.schemas" app/repositories/` returns nothing

# Frontend Refactoring Plan

Generated from: `fe/lib/` analysis against `context/project_conventions.md`

---

## Deviation Summary

| # | Violation | Affected |
|---|-----------|----------|
| A | `features/*/infrastructure/` should be `features/*/data/` | api_monitoring, dashboard, incident, project |
| B | `features/*/application/use_cases/` should be `features/*/domain/usecases/` | api_monitoring, dashboard, incident, project |
| C | `features/*/application/providers/` should be `features/*/presentation/providers/` | api_monitoring, dashboard, incident, project |
| D | `core/di/repository_providers.dart` wires all feature repos; each feature must have its own `di/` layer | all features |
| E | `features/auth/presentation/dialogs/` is not a valid layer; dialogs belong in `widgets/` | auth |
| F | No `public.dart` barrel files exist anywhere | all layers |
| G | `features/api_monitoring/domain/repositories/dashboard_repository.dart` is an orphan — same interface exists at `features/dashboard/domain/repositories/` | api_monitoring |
| H | Duplicate widget files in api_monitoring and project presentations | api_monitoring, project |

---

## Step 1 — Rename `api_monitoring/infrastructure/` to `data/`

**Concern:** Layer naming (infrastructure → data)

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/api_monitoring/infrastructure/data_sources/local_service_data_source_impl.dart` | `fe/lib/features/api_monitoring/data/data_sources/local_service_data_source_impl.dart` |
| `fe/lib/features/api_monitoring/infrastructure/data_sources/remote_service_data_source_impl.dart` | `fe/lib/features/api_monitoring/data/data_sources/remote_service_data_source_impl.dart` |
| `fe/lib/features/api_monitoring/infrastructure/data_sources/service_data_source.dart` | `fe/lib/features/api_monitoring/data/data_sources/service_data_source.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/health_check_dto.dart` | `fe/lib/features/api_monitoring/data/models/health_check_dto.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/health_check_dto.freezed.dart` | `fe/lib/features/api_monitoring/data/models/health_check_dto.freezed.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/health_check_dto.g.dart` | `fe/lib/features/api_monitoring/data/models/health_check_dto.g.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/service_dto.dart` | `fe/lib/features/api_monitoring/data/models/service_dto.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/service_dto.freezed.dart` | `fe/lib/features/api_monitoring/data/models/service_dto.freezed.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/service_dto.g.dart` | `fe/lib/features/api_monitoring/data/models/service_dto.g.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/service_stats_dto.dart` | `fe/lib/features/api_monitoring/data/models/service_stats_dto.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/service_stats_dto.freezed.dart` | `fe/lib/features/api_monitoring/data/models/service_stats_dto.freezed.dart` |
| `fe/lib/features/api_monitoring/infrastructure/models/service_stats_dto.g.dart` | `fe/lib/features/api_monitoring/data/models/service_stats_dto.g.dart` |
| `fe/lib/features/api_monitoring/infrastructure/repositories/service_repository_impl.dart` | `fe/lib/features/api_monitoring/data/repositories/service_repository_impl.dart` |

### Affected Imports

**`fe/lib/features/api_monitoring/data/repositories/service_repository_impl.dart`** (self-update after move):
```dart
// OLD
import 'package:service_sentinel_fe_v2/features/api_monitoring/infrastructure/data_sources/local_service_data_source_impl.dart';
// NEW
import 'package:service_sentinel_fe_v2/features/api_monitoring/data/data_sources/local_service_data_source_impl.dart';
```
Note: All other relative imports within this file (`'../data_sources/service_data_source.dart'` etc.) are unchanged because the internal directory structure is preserved.

**`fe/lib/core/di/repository_providers.dart`**:
```dart
// OLD
import '../../features/api_monitoring/infrastructure/data_sources/local_service_data_source_impl.dart';
import '../../features/api_monitoring/infrastructure/data_sources/remote_service_data_source_impl.dart';
import '../../features/api_monitoring/infrastructure/repositories/service_repository_impl.dart';
// NEW
import '../../features/api_monitoring/data/data_sources/local_service_data_source_impl.dart';
import '../../features/api_monitoring/data/data_sources/remote_service_data_source_impl.dart';
import '../../features/api_monitoring/data/repositories/service_repository_impl.dart';
```

### Completion Criteria
- `fe/lib/features/api_monitoring/infrastructure/` directory no longer exists.
- `fe/lib/features/api_monitoring/data/` directory contains the same 13 files.
- `flutter analyze` reports no new errors for the `api_monitoring` feature.

### Checklist
- [ ] All 13 files moved via `git mv` (not copy+delete)
- [ ] Package import in `service_repository_impl.dart` updated
- [ ] Three import lines in `core/di/repository_providers.dart` updated
- [ ] `infrastructure/` directory removed
- [ ] `flutter analyze` passes

---

## Step 2 — Rename `dashboard/infrastructure/` to `data/`

**Concern:** Layer naming (infrastructure → data)

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/dashboard/infrastructure/data_sources/global_dashboard_data_source.dart` | `fe/lib/features/dashboard/data/data_sources/global_dashboard_data_source.dart` |
| `fe/lib/features/dashboard/infrastructure/data_sources/remote_global_dashboard_data_source_impl.dart` | `fe/lib/features/dashboard/data/data_sources/remote_global_dashboard_data_source_impl.dart` |
| `fe/lib/features/dashboard/infrastructure/models/dashboard_metrics_dto.dart` | `fe/lib/features/dashboard/data/models/dashboard_metrics_dto.dart` |
| `fe/lib/features/dashboard/infrastructure/models/dashboard_metrics_dto.freezed.dart` | `fe/lib/features/dashboard/data/models/dashboard_metrics_dto.freezed.dart` |
| `fe/lib/features/dashboard/infrastructure/models/dashboard_metrics_dto.g.dart` | `fe/lib/features/dashboard/data/models/dashboard_metrics_dto.g.dart` |
| `fe/lib/features/dashboard/infrastructure/models/dashboard_overview_dto.dart` | `fe/lib/features/dashboard/data/models/dashboard_overview_dto.dart` |
| `fe/lib/features/dashboard/infrastructure/models/dashboard_overview_dto.freezed.dart` | `fe/lib/features/dashboard/data/models/dashboard_overview_dto.freezed.dart` |
| `fe/lib/features/dashboard/infrastructure/models/dashboard_overview_dto.g.dart` | `fe/lib/features/dashboard/data/models/dashboard_overview_dto.g.dart` |
| `fe/lib/features/dashboard/infrastructure/models/global_dashboard_metrics_dto.dart` | `fe/lib/features/dashboard/data/models/global_dashboard_metrics_dto.dart` |
| `fe/lib/features/dashboard/infrastructure/models/global_dashboard_metrics_dto.freezed.dart` | `fe/lib/features/dashboard/data/models/global_dashboard_metrics_dto.freezed.dart` |
| `fe/lib/features/dashboard/infrastructure/models/global_dashboard_metrics_dto.g.dart` | `fe/lib/features/dashboard/data/models/global_dashboard_metrics_dto.g.dart` |
| `fe/lib/features/dashboard/infrastructure/models/service_health_summary_dto.dart` | `fe/lib/features/dashboard/data/models/service_health_summary_dto.dart` |
| `fe/lib/features/dashboard/infrastructure/models/service_health_summary_dto.freezed.dart` | `fe/lib/features/dashboard/data/models/service_health_summary_dto.freezed.dart` |
| `fe/lib/features/dashboard/infrastructure/models/service_health_summary_dto.g.dart` | `fe/lib/features/dashboard/data/models/service_health_summary_dto.g.dart` |
| `fe/lib/features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart` | `fe/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart` |

### Affected Imports

**`fe/lib/core/di/repository_providers.dart`**:
```dart
// OLD
import '../../features/dashboard/infrastructure/data_sources/global_dashboard_data_source.dart';
import '../../features/dashboard/infrastructure/data_sources/remote_global_dashboard_data_source_impl.dart';
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart' as global;
// NEW
import '../../features/dashboard/data/data_sources/global_dashboard_data_source.dart';
import '../../features/dashboard/data/data_sources/remote_global_dashboard_data_source_impl.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart' as global;
```

Note: Relative imports within moved files (e.g., `'../models/...'`) are unchanged.

### Completion Criteria
- `fe/lib/features/dashboard/infrastructure/` directory no longer exists.
- `fe/lib/features/dashboard/data/` contains the same 15 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 15 files moved via `git mv`
- [ ] Three import lines in `core/di/repository_providers.dart` updated
- [ ] `infrastructure/` directory removed
- [ ] `flutter analyze` passes

---

## Step 3 — Rename `incident/infrastructure/` to `data/`

**Concern:** Layer naming (infrastructure → data)

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/incident/infrastructure/data_sources/incident_data_source.dart` | `fe/lib/features/incident/data/data_sources/incident_data_source.dart` |
| `fe/lib/features/incident/infrastructure/data_sources/local_incident_data_source_impl.dart` | `fe/lib/features/incident/data/data_sources/local_incident_data_source_impl.dart` |
| `fe/lib/features/incident/infrastructure/data_sources/remote_incident_data_source_impl.dart` | `fe/lib/features/incident/data/data_sources/remote_incident_data_source_impl.dart` |
| `fe/lib/features/incident/infrastructure/models/ai_analysis_dto.dart` | `fe/lib/features/incident/data/models/ai_analysis_dto.dart` |
| `fe/lib/features/incident/infrastructure/models/ai_analysis_dto.freezed.dart` | `fe/lib/features/incident/data/models/ai_analysis_dto.freezed.dart` |
| `fe/lib/features/incident/infrastructure/models/ai_analysis_dto.g.dart` | `fe/lib/features/incident/data/models/ai_analysis_dto.g.dart` |
| `fe/lib/features/incident/infrastructure/models/incident_dto.dart` | `fe/lib/features/incident/data/models/incident_dto.dart` |
| `fe/lib/features/incident/infrastructure/models/incident_dto.freezed.dart` | `fe/lib/features/incident/data/models/incident_dto.freezed.dart` |
| `fe/lib/features/incident/infrastructure/models/incident_dto.g.dart` | `fe/lib/features/incident/data/models/incident_dto.g.dart` |
| `fe/lib/features/incident/infrastructure/repositories/incident_repository_impl.dart` | `fe/lib/features/incident/data/repositories/incident_repository_impl.dart` |

### Affected Imports

**`fe/lib/core/di/repository_providers.dart`**:
```dart
// OLD
import '../../features/incident/infrastructure/data_sources/local_incident_data_source_impl.dart';
import '../../features/incident/infrastructure/data_sources/remote_incident_data_source_impl.dart';
import '../../features/incident/infrastructure/repositories/incident_repository_impl.dart';
// NEW
import '../../features/incident/data/data_sources/local_incident_data_source_impl.dart';
import '../../features/incident/data/data_sources/remote_incident_data_source_impl.dart';
import '../../features/incident/data/repositories/incident_repository_impl.dart';
```

### Completion Criteria
- `fe/lib/features/incident/infrastructure/` directory no longer exists.
- `fe/lib/features/incident/data/` contains the same 10 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 10 files moved via `git mv`
- [ ] Three import lines in `core/di/repository_providers.dart` updated
- [ ] `infrastructure/` directory removed
- [ ] `flutter analyze` passes

---

## Step 4 — Rename `project/infrastructure/` to `data/`

**Concern:** Layer naming (infrastructure → data)

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/project/infrastructure/data_sources/bootstrap_data_source.dart` | `fe/lib/features/project/data/data_sources/bootstrap_data_source.dart` |
| `fe/lib/features/project/infrastructure/data_sources/local_project_data_source_impl.dart` | `fe/lib/features/project/data/data_sources/local_project_data_source_impl.dart` |
| `fe/lib/features/project/infrastructure/data_sources/project_data_source.dart` | `fe/lib/features/project/data/data_sources/project_data_source.dart` |
| `fe/lib/features/project/infrastructure/data_sources/remote_api_key_data_source.dart` | `fe/lib/features/project/data/data_sources/remote_api_key_data_source.dart` |
| `fe/lib/features/project/infrastructure/data_sources/remote_bootstrap_data_source_impl.dart` | `fe/lib/features/project/data/data_sources/remote_bootstrap_data_source_impl.dart` |
| `fe/lib/features/project/infrastructure/data_sources/remote_project_data_source_impl.dart` | `fe/lib/features/project/data/data_sources/remote_project_data_source_impl.dart` |
| `fe/lib/features/project/infrastructure/models/api_key_dto.dart` | `fe/lib/features/project/data/models/api_key_dto.dart` |
| `fe/lib/features/project/infrastructure/models/api_key_dto.freezed.dart` | `fe/lib/features/project/data/models/api_key_dto.freezed.dart` |
| `fe/lib/features/project/infrastructure/models/api_key_dto.g.dart` | `fe/lib/features/project/data/models/api_key_dto.g.dart` |
| `fe/lib/features/project/infrastructure/models/bootstrap_dto.dart` | `fe/lib/features/project/data/models/bootstrap_dto.dart` |
| `fe/lib/features/project/infrastructure/models/bootstrap_dto.freezed.dart` | `fe/lib/features/project/data/models/bootstrap_dto.freezed.dart` |
| `fe/lib/features/project/infrastructure/models/bootstrap_dto.g.dart` | `fe/lib/features/project/data/models/bootstrap_dto.g.dart` |
| `fe/lib/features/project/infrastructure/models/project_dto.dart` | `fe/lib/features/project/data/models/project_dto.dart` |
| `fe/lib/features/project/infrastructure/models/project_dto.freezed.dart` | `fe/lib/features/project/data/models/project_dto.freezed.dart` |
| `fe/lib/features/project/infrastructure/models/project_dto.g.dart` | `fe/lib/features/project/data/models/project_dto.g.dart` |
| `fe/lib/features/project/infrastructure/models/project_health_dto.dart` | `fe/lib/features/project/data/models/project_health_dto.dart` |
| `fe/lib/features/project/infrastructure/models/project_health_dto.freezed.dart` | `fe/lib/features/project/data/models/project_health_dto.freezed.dart` |
| `fe/lib/features/project/infrastructure/models/project_health_dto.g.dart` | `fe/lib/features/project/data/models/project_health_dto.g.dart` |
| `fe/lib/features/project/infrastructure/repositories/api_key_repository_impl.dart` | `fe/lib/features/project/data/repositories/api_key_repository_impl.dart` |
| `fe/lib/features/project/infrastructure/repositories/bootstrap_repository_impl.dart` | `fe/lib/features/project/data/repositories/bootstrap_repository_impl.dart` |
| `fe/lib/features/project/infrastructure/repositories/project_repository_impl.dart` | `fe/lib/features/project/data/repositories/project_repository_impl.dart` |

### Affected Imports

**`fe/lib/core/di/repository_providers.dart`**:
```dart
// OLD
import '../../features/project/infrastructure/data_sources/local_project_data_source_impl.dart';
import '../../features/project/infrastructure/data_sources/remote_api_key_data_source.dart';
import '../../features/project/infrastructure/data_sources/remote_bootstrap_data_source_impl.dart';
import '../../features/project/infrastructure/data_sources/remote_project_data_source_impl.dart';
import '../../features/project/infrastructure/repositories/api_key_repository_impl.dart';
import '../../features/project/infrastructure/repositories/bootstrap_repository_impl.dart';
import '../../features/project/infrastructure/repositories/project_repository_impl.dart';
// NEW
import '../../features/project/data/data_sources/local_project_data_source_impl.dart';
import '../../features/project/data/data_sources/remote_api_key_data_source.dart';
import '../../features/project/data/data_sources/remote_bootstrap_data_source_impl.dart';
import '../../features/project/data/data_sources/remote_project_data_source_impl.dart';
import '../../features/project/data/repositories/api_key_repository_impl.dart';
import '../../features/project/data/repositories/bootstrap_repository_impl.dart';
import '../../features/project/data/repositories/project_repository_impl.dart';
```

### Completion Criteria
- `fe/lib/features/project/infrastructure/` directory no longer exists.
- `fe/lib/features/project/data/` contains the same 21 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 21 files moved via `git mv`
- [ ] Seven import lines in `core/di/repository_providers.dart` updated
- [ ] `infrastructure/` directory removed
- [ ] `flutter analyze` passes

---

## Step 5 — Move `api_monitoring/application/use_cases/` to `domain/usecases/`

**Concern:** Use cases belong in `domain/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/api_monitoring/application/use_cases/create_service.dart` | `fe/lib/features/api_monitoring/domain/usecases/create_service.dart` |
| `fe/lib/features/api_monitoring/application/use_cases/delete_service.dart` | `fe/lib/features/api_monitoring/domain/usecases/delete_service.dart` |
| `fe/lib/features/api_monitoring/application/use_cases/load_services.dart` | `fe/lib/features/api_monitoring/domain/usecases/load_services.dart` |
| `fe/lib/features/api_monitoring/application/use_cases/trigger_health_check.dart` | `fe/lib/features/api_monitoring/domain/usecases/trigger_health_check.dart` |
| `fe/lib/features/api_monitoring/application/use_cases/update_service.dart` | `fe/lib/features/api_monitoring/domain/usecases/update_service.dart` |

### Affected Imports

**In each moved use case file** (depth is unchanged: both paths are 4 levels deep from `lib/`):
```dart
// OLD (relative to application/use_cases/)
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
// NEW (relative to domain/usecases/)
import '../entities/service.dart';
import '../repositories/service_repository.dart';
```
Imports of `'../../../../core/...'` are unchanged (same directory depth).

**`fe/lib/features/api_monitoring/application/providers/service_provider.dart`**:
```dart
// OLD
import '../use_cases/load_services.dart';
import '../use_cases/create_service.dart';
import '../use_cases/update_service.dart';
import '../use_cases/delete_service.dart';
// NEW
import '../../domain/usecases/load_services.dart';
import '../../domain/usecases/create_service.dart';
import '../../domain/usecases/update_service.dart';
import '../../domain/usecases/delete_service.dart';
```

### Completion Criteria
- `fe/lib/features/api_monitoring/application/use_cases/` directory no longer exists.
- `fe/lib/features/api_monitoring/domain/usecases/` contains the 5 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 5 files moved via `git mv`
- [ ] Internal domain imports in each moved file updated (`../../domain/` → `../`)
- [ ] `service_provider.dart` use_case imports updated (4 lines)
- [ ] `flutter analyze` passes

---

## Step 6 — Move `dashboard/application/use_cases/` to `domain/usecases/`

**Concern:** Use cases belong in `domain/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/dashboard/application/use_cases/get_dashboard_matrix.dart` | `fe/lib/features/dashboard/domain/usecases/get_dashboard_matrix.dart` |
| `fe/lib/features/dashboard/application/use_cases/get_dashboard_overview.dart` | `fe/lib/features/dashboard/domain/usecases/get_dashboard_overview.dart` |
| `fe/lib/features/dashboard/application/use_cases/get_global_dashboard.dart` | `fe/lib/features/dashboard/domain/usecases/get_global_dashboard.dart` |

### Affected Imports

**In each moved use case file**:
```dart
// OLD (relative to application/use_cases/)
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/...';
// NEW (relative to domain/usecases/)
import '../repositories/dashboard_repository.dart';
import '../entities/...';
```

**`fe/lib/features/dashboard/application/providers/dashboard_provider.dart`**:
```dart
// OLD (package imports)
import 'package:service_sentinel_fe_v2/features/dashboard/application/use_cases/get_dashboard_matrix.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/application/use_cases/get_dashboard_overview.dart';
// NEW
import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_matrix.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_overview.dart';

// OLD (relative import)
import '../use_cases/get_global_dashboard.dart';
// NEW
import '../../domain/usecases/get_global_dashboard.dart';
```

### Completion Criteria
- `fe/lib/features/dashboard/application/use_cases/` directory no longer exists.
- `fe/lib/features/dashboard/domain/usecases/` contains the 3 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 3 files moved via `git mv`
- [ ] Internal domain imports in each moved file updated
- [ ] Two package imports in `dashboard_provider.dart` updated
- [ ] One relative import in `dashboard_provider.dart` updated
- [ ] `flutter analyze` passes

---

## Step 7 — Move `incident/application/use_cases/` to `domain/usecases/`

**Concern:** Use cases belong in `domain/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/incident/application/use_cases/acknowledge_incident.dart` | `fe/lib/features/incident/domain/usecases/acknowledge_incident.dart` |
| `fe/lib/features/incident/application/use_cases/load_incidents.dart` | `fe/lib/features/incident/domain/usecases/load_incidents.dart` |
| `fe/lib/features/incident/application/use_cases/request_ai_analysis.dart` | `fe/lib/features/incident/domain/usecases/request_ai_analysis.dart` |
| `fe/lib/features/incident/application/use_cases/resolve_incident.dart` | `fe/lib/features/incident/domain/usecases/resolve_incident.dart` |
| `fe/lib/features/incident/application/use_cases/update_incident.dart` | `fe/lib/features/incident/domain/usecases/update_incident.dart` |

### Affected Imports

**In each moved use case file**:
```dart
// OLD
import '../../domain/entities/incident.dart';
import '../../domain/repositories/incident_repository.dart';
// NEW
import '../entities/incident.dart';
import '../repositories/incident_repository.dart';
```

**`fe/lib/features/incident/application/providers/incident_provider.dart`**:
```dart
// OLD
import '../use_cases/load_incidents.dart';
import '../use_cases/acknowledge_incident.dart';
import '../use_cases/resolve_incident.dart';
import '../use_cases/update_incident.dart';
import '../use_cases/request_ai_analysis.dart';
// NEW
import '../../domain/usecases/load_incidents.dart';
import '../../domain/usecases/acknowledge_incident.dart';
import '../../domain/usecases/resolve_incident.dart';
import '../../domain/usecases/update_incident.dart';
import '../../domain/usecases/request_ai_analysis.dart';
```

### Completion Criteria
- `fe/lib/features/incident/application/use_cases/` directory no longer exists.
- `fe/lib/features/incident/domain/usecases/` contains the 5 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 5 files moved via `git mv`
- [ ] Internal domain imports in each moved file updated
- [ ] Five import lines in `incident_provider.dart` updated
- [ ] `flutter analyze` passes

---

## Step 8 — Move `project/application/use_cases/` to `domain/usecases/`

**Concern:** Use cases belong in `domain/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/project/application/use_cases/bootstrap_guest_user.dart` | `fe/lib/features/project/domain/usecases/bootstrap_guest_user.dart` |
| `fe/lib/features/project/application/use_cases/create_project.dart` | `fe/lib/features/project/domain/usecases/create_project.dart` |
| `fe/lib/features/project/application/use_cases/delete_project.dart` | `fe/lib/features/project/domain/usecases/delete_project.dart` |
| `fe/lib/features/project/application/use_cases/get_project_health.dart` | `fe/lib/features/project/domain/usecases/get_project_health.dart` |
| `fe/lib/features/project/application/use_cases/load_projects.dart` | `fe/lib/features/project/domain/usecases/load_projects.dart` |
| `fe/lib/features/project/application/use_cases/migrate_local_projects_to_server.dart` | `fe/lib/features/project/domain/usecases/migrate_local_projects_to_server.dart` |
| `fe/lib/features/project/application/use_cases/update_project.dart` | `fe/lib/features/project/domain/usecases/update_project.dart` |

### Affected Imports

**In each moved use case file**:
```dart
// OLD
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
// NEW
import '../entities/project.dart';
import '../repositories/project_repository.dart';
```

**`fe/lib/features/project/application/providers/bootstrap_provider.dart`**:
```dart
// OLD
import '../use_cases/bootstrap_guest_user.dart';
// NEW
import '../../domain/usecases/bootstrap_guest_user.dart';
```

**`fe/lib/features/project/application/providers/project_provider.dart`**:
```dart
// OLD
import '../use_cases/load_projects.dart';
import '../use_cases/create_project.dart';
import '../use_cases/update_project.dart';
import '../use_cases/delete_project.dart';
// NEW
import '../../domain/usecases/load_projects.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/update_project.dart';
import '../../domain/usecases/delete_project.dart';
```

Note: Verify `project_health_provider.dart` for any `../use_cases/` imports and apply the same pattern.

### Completion Criteria
- `fe/lib/features/project/application/use_cases/` directory no longer exists.
- `fe/lib/features/project/domain/usecases/` contains the 7 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 7 files moved via `git mv`
- [ ] Internal domain imports in each moved file updated
- [ ] Use_case imports in `bootstrap_provider.dart` updated (1 line)
- [ ] Use_case imports in `project_provider.dart` updated (4 lines)
- [ ] Use_case imports in `project_health_provider.dart` verified/updated
- [ ] `flutter analyze` passes

---

## Step 9 — Move `api_monitoring/application/providers/` to `presentation/providers/`

**Concern:** Providers belong in `presentation/providers/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/api_monitoring/application/providers/service_provider.dart` | `fe/lib/features/api_monitoring/presentation/providers/service_provider.dart` |
| `fe/lib/features/api_monitoring/application/providers/service_provider.g.dart` | `fe/lib/features/api_monitoring/presentation/providers/service_provider.g.dart` |

### Affected Imports

**`fe/lib/features/api_monitoring/presentation/providers/service_provider.dart`** (self — after move):

No import changes are required. Both `application/providers/` and `presentation/providers/` are at depth 4 from `lib/`, so all existing relative paths (`../../../../core/di/repository_providers.dart`, `../../domain/usecases/...`, `../../domain/entities/...`) resolve identically from the new location.

**Files that import `service_provider.dart` from outside** — search for:
```
import '../../application/providers/service_provider.dart'
import 'package:service_sentinel_fe_v2/features/api_monitoring/application/providers/service_provider.dart'
```
Update both forms to the new path. Expected importers: screens and view_models in `api_monitoring/presentation/`.

After this step, `fe/lib/features/api_monitoring/application/` is empty and should be deleted.

### Completion Criteria
- `fe/lib/features/api_monitoring/application/` directory no longer exists.
- `fe/lib/features/api_monitoring/presentation/providers/` contains both files.
- All importers of `service_provider.dart` use the new path.
- `flutter analyze` passes.

### Checklist
- [ ] Both files moved via `git mv`
- [ ] All files importing from `application/providers/` updated (grep the codebase)
- [ ] `application/` directory removed
- [ ] `flutter analyze` passes

---

## Step 10 — Move `dashboard/application/providers/` to `presentation/providers/`

**Concern:** Providers belong in `presentation/providers/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/dashboard/application/providers/dashboard_provider.dart` | `fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart` |
| `fe/lib/features/dashboard/application/providers/dashboard_provider.g.dart` | `fe/lib/features/dashboard/presentation/providers/dashboard_provider.g.dart` |

### Affected Imports

**`fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart`** (self — after move):

No import changes required. The depth is unchanged (both `application/providers/` and `presentation/providers/` are 4 levels deep), so all relative and package imports remain valid.

**Files that import `dashboard_provider.dart` from outside** — search for:
```
import '../../application/providers/dashboard_provider.dart'
import 'package:service_sentinel_fe_v2/features/dashboard/application/providers/dashboard_provider.dart'
```
Expected importers: `features/dashboard/presentation/screens/dashboard_screen.dart` and `features/dashboard/presentation/view_models/dashboard_screen_view_model.dart`.

After this step, `fe/lib/features/dashboard/application/` is empty and should be deleted.

### Completion Criteria
- `fe/lib/features/dashboard/application/` directory no longer exists.
- `fe/lib/features/dashboard/presentation/providers/` contains both files.
- `flutter analyze` passes.

### Checklist
- [ ] Both files moved via `git mv`
- [ ] All importers updated (grep codebase)
- [ ] `application/` directory removed
- [ ] `flutter analyze` passes

---

## Step 11 — Move `incident/application/providers/` to `presentation/providers/`

**Concern:** Providers belong in `presentation/providers/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/incident/application/providers/incident_provider.dart` | `fe/lib/features/incident/presentation/providers/incident_provider.dart` |
| `fe/lib/features/incident/application/providers/incident_provider.g.dart` | `fe/lib/features/incident/presentation/providers/incident_provider.g.dart` |

### Affected Imports

**Self (after move):** No changes — depth is unchanged, all relative imports remain valid.

**Files that import `incident_provider.dart` from outside** — search for:
```
import '../../application/providers/incident_provider.dart'
import 'package:service_sentinel_fe_v2/features/incident/application/providers/incident_provider.dart'
```
Expected importers: screens in `incident/presentation/screens/`.

After this step, `fe/lib/features/incident/application/` is empty and should be deleted.

### Completion Criteria
- `fe/lib/features/incident/application/` directory no longer exists.
- `fe/lib/features/incident/presentation/providers/` contains both files.
- `flutter analyze` passes.

### Checklist
- [ ] Both files moved via `git mv`
- [ ] All importers updated (grep codebase)
- [ ] `application/` directory removed
- [ ] `flutter analyze` passes

---

## Step 12 — Move `project/application/providers/` to `presentation/providers/`

**Concern:** Providers belong in `presentation/providers/`, not `application/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/project/application/providers/bootstrap_provider.dart` | `fe/lib/features/project/presentation/providers/bootstrap_provider.dart` |
| `fe/lib/features/project/application/providers/bootstrap_provider.g.dart` | `fe/lib/features/project/presentation/providers/bootstrap_provider.g.dart` |
| `fe/lib/features/project/application/providers/project_health_provider.dart` | `fe/lib/features/project/presentation/providers/project_health_provider.dart` |
| `fe/lib/features/project/application/providers/project_health_provider.g.dart` | `fe/lib/features/project/presentation/providers/project_health_provider.g.dart` |
| `fe/lib/features/project/application/providers/project_provider.dart` | `fe/lib/features/project/presentation/providers/project_provider.dart` |
| `fe/lib/features/project/application/providers/project_provider.g.dart` | `fe/lib/features/project/presentation/providers/project_provider.g.dart` |

### Affected Imports

**Self (after move):** No changes — depth unchanged, all relative and package imports remain valid.

**Files that import project providers from outside** — search for:
```
import '../../application/providers/project_provider.dart'
import '../../application/providers/bootstrap_provider.dart'
import '../../application/providers/project_health_provider.dart'
import 'package:service_sentinel_fe_v2/features/project/application/providers/...'
```
Expected importers: screens in `project/presentation/screens/`, `core/migration/` files, and possibly `core/router/app_router.dart`.

After this step, `fe/lib/features/project/application/` is empty and should be deleted.

### Completion Criteria
- `fe/lib/features/project/application/` directory no longer exists.
- `fe/lib/features/project/presentation/providers/` contains all 6 files.
- `flutter analyze` passes.

### Checklist
- [ ] All 6 files moved via `git mv`
- [ ] All importers updated (grep codebase)
- [ ] `application/` directory removed
- [ ] `flutter analyze` passes

---

## Step 13 — Move `auth/presentation/dialogs/` to `presentation/widgets/`

**Concern:** `dialogs/` is not a valid sublayer; dialog widgets belong in `widgets/`

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/auth/presentation/dialogs/sign_up_dialog.dart` | `fe/lib/features/auth/presentation/widgets/sign_up_dialog.dart` |

### Affected Imports

**`fe/lib/features/auth/presentation/widgets/sign_up_dialog.dart`** (self — after move):

No changes required. The file uses package imports for `core/` dependencies, which are location-independent.

**Files that import `sign_up_dialog.dart`** — search for:
```
import '../dialogs/sign_up_dialog.dart'
import './dialogs/sign_up_dialog.dart'
import 'package:service_sentinel_fe_v2/features/auth/presentation/dialogs/sign_up_dialog.dart'
```
Update to `'../widgets/sign_up_dialog.dart'` or the equivalent package import. Expected importers: `features/auth/presentation/screens/login_screen.dart` or `signup_screen.dart`.

After this step, `fe/lib/features/auth/presentation/dialogs/` is empty and should be deleted.

### Completion Criteria
- `fe/lib/features/auth/presentation/dialogs/` directory no longer exists.
- `fe/lib/features/auth/presentation/widgets/sign_up_dialog.dart` exists.
- `flutter analyze` passes.

### Checklist
- [ ] File moved via `git mv`
- [ ] All importers updated
- [ ] `dialogs/` directory removed
- [ ] `flutter analyze` passes

---

## Step 14 — Create `api_monitoring/di/` and extract its repository provider

**Concern:** Each feature must own its own `di/` layer; `core/di/repository_providers.dart` must not wire feature repositories

### New File

**`fe/lib/features/api_monitoring/di/repository_providers.dart`** (create):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/repository_providers.dart' show dioClientProvider; // or providers.dart
import '../../../core/data/data_source_mode_provider.dart';
import '../../../core/state/project_session_notifier.dart';
import '../domain/repositories/service_repository.dart';
import '../data/data_sources/local_service_data_source_impl.dart';
import '../data/data_sources/remote_service_data_source_impl.dart';
import '../data/repositories/service_repository_impl.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  // move body verbatim from core/di/repository_providers.dart
});
```

### Source File Edits

**`fe/lib/core/di/repository_providers.dart`**: Remove the `serviceRepositoryProvider` block and its associated imports (`local_service_data_source_impl.dart`, `remote_service_data_source_impl.dart`, `service_repository_impl.dart`, `service_repository.dart`).

**`fe/lib/features/api_monitoring/presentation/providers/service_provider.dart`**:
```dart
// OLD
import '../../../../core/di/repository_providers.dart';
// NEW
import '../../di/repository_providers.dart';
```

### Completion Criteria
- `serviceRepositoryProvider` is defined in `features/api_monitoring/di/repository_providers.dart` only.
- It no longer appears in `core/di/repository_providers.dart`.
- `flutter analyze` passes.

### Checklist
- [ ] `features/api_monitoring/di/repository_providers.dart` created with correct content
- [ ] `serviceRepositoryProvider` block removed from `core/di/repository_providers.dart`
- [ ] Dangling imports removed from `core/di/repository_providers.dart`
- [ ] `service_provider.dart` DI import updated
- [ ] `flutter analyze` passes

---

## Step 15 — Create `dashboard/di/` and extract its repository provider

**Concern:** Each feature must own its own `di/` layer

### New File

**`fe/lib/features/dashboard/di/repository_providers.dart`** (create):

Move `remoteDashboardDataSourceProvider` and `dashboardRepositoryProvider` verbatim from `core/di/repository_providers.dart`, updating imports to be relative to the new location.

### Source File Edits

**`fe/lib/core/di/repository_providers.dart`**: Remove `remoteDashboardDataSourceProvider` and `dashboardRepositoryProvider` blocks and their associated imports (`global_dashboard_data_source.dart`, `remote_global_dashboard_data_source_impl.dart`, `dashboard_repository_impl.dart`).

**`fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart`**:
```dart
// OLD
import '../../../../core/di/repository_providers.dart';
// NEW
import '../../di/repository_providers.dart';
```

### Completion Criteria
- Both dashboard repository providers are defined in `features/dashboard/di/repository_providers.dart` only.
- `flutter analyze` passes.

### Checklist
- [ ] `features/dashboard/di/repository_providers.dart` created
- [ ] Dashboard provider blocks removed from `core/di/repository_providers.dart`
- [ ] Dangling imports removed from `core/di/repository_providers.dart`
- [ ] `dashboard_provider.dart` DI import updated
- [ ] `flutter analyze` passes

---

## Step 16 — Create `incident/di/` and extract its repository provider

**Concern:** Each feature must own its own `di/` layer

### New File

**`fe/lib/features/incident/di/repository_providers.dart`** (create):

Move `incidentRepositoryProvider` verbatim from `core/di/repository_providers.dart`.

### Source File Edits

**`fe/lib/core/di/repository_providers.dart`**: Remove `incidentRepositoryProvider` block and its associated imports.

**`fe/lib/features/incident/presentation/providers/incident_provider.dart`**:
```dart
// OLD
import '../../../../core/di/repository_providers.dart';
// NEW
import '../../di/repository_providers.dart';
```

### Completion Criteria
- `incidentRepositoryProvider` is defined in `features/incident/di/` only.
- `flutter analyze` passes.

### Checklist
- [ ] `features/incident/di/repository_providers.dart` created
- [ ] Incident provider block removed from `core/di/repository_providers.dart`
- [ ] `incident_provider.dart` DI import updated
- [ ] `flutter analyze` passes

---

## Step 17 — Create `project/di/` and extract its repository providers

**Concern:** Each feature must own its own `di/` layer

### New File

**`fe/lib/features/project/di/repository_providers.dart`** (create):

Move `bootstrapRepositoryProvider`, `projectRepositoryProvider`, and `apiKeyRepositoryProvider` verbatim from `core/di/repository_providers.dart`.

### Source File Edits

**`fe/lib/core/di/repository_providers.dart`**: Remove all three project provider blocks and their associated imports. After this step, only `authRepositoryProvider` remains in this file (handled in Step 18).

**`fe/lib/features/project/presentation/providers/bootstrap_provider.dart`**:
```dart
// OLD
import '../../../../core/di/providers.dart';
import '../../../../core/di/repository_providers.dart';
// NEW — guestApiKeyServiceProvider comes from core/di/providers.dart (unchanged)
import '../../../../core/di/providers.dart';
import '../../di/repository_providers.dart';
```

**`fe/lib/features/project/presentation/providers/project_provider.dart`**:
```dart
// OLD
import 'package:service_sentinel_fe_v2/core/di/providers.dart';
import '../../../../core/di/repository_providers.dart';
// NEW
import 'package:service_sentinel_fe_v2/core/di/providers.dart';
import '../../di/repository_providers.dart';
```

Also update `project_health_provider.dart` if it imports `repository_providers.dart`.

### Completion Criteria
- All three project repository providers are defined in `features/project/di/` only.
- `core/di/repository_providers.dart` contains only `authRepositoryProvider`.
- `flutter analyze` passes.

### Checklist
- [ ] `features/project/di/repository_providers.dart` created
- [ ] Three provider blocks removed from `core/di/repository_providers.dart`
- [ ] `bootstrap_provider.dart` DI import updated
- [ ] `project_provider.dart` DI import updated
- [ ] `project_health_provider.dart` DI import verified/updated
- [ ] `flutter analyze` passes

---

## Step 18 — Move `authRepositoryProvider` to `core/auth/di/`

**Concern:** Auth's repository provider belongs in `core/auth/di/`, matching the convention for core sub-features

### New File

**`fe/lib/core/auth/di/repository_providers.dart`** (create):

Move `authRepositoryProvider` verbatim from `core/di/repository_providers.dart`, updating its import of `AuthRepository` to a relative path.

### Source File Edits

**`fe/lib/core/di/repository_providers.dart`**: After removing `authRepositoryProvider`, this file is empty. Delete it.

**Files that import `authRepositoryProvider`** — search for:
```
import '../../../../core/di/repository_providers.dart'
import 'package:service_sentinel_fe_v2/core/di/repository_providers.dart'
```
In each file that uses `authRepositoryProvider`, update the import to `'core/auth/di/repository_providers.dart'` or the equivalent relative path.

### Completion Criteria
- `fe/lib/core/di/repository_providers.dart` no longer exists.
- `authRepositoryProvider` is defined in `fe/lib/core/auth/di/repository_providers.dart` only.
- `flutter analyze` passes.

### Checklist
- [ ] `core/auth/di/repository_providers.dart` created
- [ ] `core/di/repository_providers.dart` deleted
- [ ] All importers of `authRepositoryProvider` updated to new path
- [ ] `flutter analyze` passes

---

## Step 19 — Remove orphan `api_monitoring/domain/repositories/dashboard_repository.dart`

**Concern:** `features/api_monitoring/domain/repositories/dashboard_repository.dart` duplicates the interface at `features/dashboard/domain/repositories/dashboard_repository.dart`

### Pre-Step Investigation Required

Before removing the file, grep for all importers:
```bash
grep -r "api_monitoring/domain/repositories/dashboard_repository" fe/lib/
grep -r "api_monitoring.*dashboard_repository" fe/lib/
```

If zero importers are found, proceed with deletion. If importers exist, update them to use `features/dashboard/domain/repositories/dashboard_repository.dart` instead.

### Source → Target

| Source | Target |
|--------|--------|
| `fe/lib/features/api_monitoring/domain/repositories/dashboard_repository.dart` | *(deleted)* |

### Completion Criteria
- `fe/lib/features/api_monitoring/domain/repositories/dashboard_repository.dart` no longer exists.
- No file imports it.
- `flutter analyze` passes.

### Checklist
- [ ] Grep confirms zero importers (or all importers have been redirected)
- [ ] File deleted
- [ ] `flutter analyze` passes

---

## Step 20 — Add `public.dart` barrel files to all layers

**Concern:** Convention requires each layer to expose a `public.dart` barrel file for external imports

### Files to Create

For each path below, create a `public.dart` that re-exports all public Dart symbols in that directory (excluding generated `.freezed.dart` and `.g.dart` files).

```
fe/lib/core/auth/domain/public.dart
fe/lib/core/auth/data/public.dart
fe/lib/core/auth/di/public.dart
fe/lib/core/auth/application/public.dart

fe/lib/features/api_monitoring/domain/public.dart
fe/lib/features/api_monitoring/data/public.dart
fe/lib/features/api_monitoring/di/public.dart
fe/lib/features/api_monitoring/presentation/public.dart

fe/lib/features/dashboard/domain/public.dart
fe/lib/features/dashboard/data/public.dart
fe/lib/features/dashboard/di/public.dart
fe/lib/features/dashboard/presentation/public.dart

fe/lib/features/incident/domain/public.dart
fe/lib/features/incident/data/public.dart
fe/lib/features/incident/di/public.dart
fe/lib/features/incident/presentation/public.dart

fe/lib/features/project/domain/public.dart
fe/lib/features/project/data/public.dart
fe/lib/features/project/di/public.dart
fe/lib/features/project/presentation/public.dart

fe/lib/features/auth/presentation/public.dart
```

### Format

Each file uses the `export` directive:
```dart
// fe/lib/features/api_monitoring/domain/public.dart
export 'entities/service.dart';
export 'entities/health_check.dart';
export 'repositories/service_repository.dart';
export 'usecases/create_service.dart';
export 'usecases/delete_service.dart';
export 'usecases/load_services.dart';
export 'usecases/trigger_health_check.dart';
export 'usecases/update_service.dart';
```

Do NOT export `.freezed.dart` or `.g.dart` files — consumers import the source file only.

### Completion Criteria
- All listed `public.dart` files exist.
- Each `public.dart` exports all non-generated `.dart` files in its directory.
- `flutter analyze` passes.

### Checklist
- [ ] All 21 `public.dart` files created
- [ ] Each exports only non-generated files
- [ ] No circular exports introduced
- [ ] `flutter analyze` passes

---

## Step 21 — Resolve duplicate widget files

**Concern:** Two functionally identical (or near-identical) dialog widgets exist under each feature's `presentation/widgets/`

### Files Requiring Investigation

**api_monitoring**:
- `fe/lib/features/api_monitoring/presentation/widgets/create_service_dialog.dart`
- `fe/lib/features/api_monitoring/presentation/widgets/create_service_set_dialog.dart`
- `fe/lib/features/api_monitoring/presentation/widgets/create_service_set_form.dart`
- `fe/lib/features/api_monitoring/presentation/widgets/service_create_dialog.dart`

**project**:
- `fe/lib/features/project/presentation/widgets/create_project_dialog.dart`
- `fe/lib/features/project/presentation/widgets/project_create_dialog.dart`

### Pre-Step Investigation Required

For each pair, read both files and determine:
1. Which file is actively imported by screens or view_models (the live one).
2. Which file has no importers (the orphan).

```bash
grep -r "service_create_dialog\|create_service_dialog\|create_service_set" fe/lib/
grep -r "project_create_dialog\|create_project_dialog" fe/lib/
```

### Action

Delete the orphan file(s). Do not modify the live file.

### Completion Criteria
- No duplicate widget files for the same UI concept exist.
- `flutter analyze` passes.

### Checklist
- [ ] Grep run to identify live vs. orphan files
- [ ] Orphan file(s) deleted
- [ ] Live file(s) confirmed to still compile
- [ ] `flutter analyze` passes

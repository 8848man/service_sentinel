# Frontend Barrel File Refactor Plan

> **Scope**: Update all cross-layer imports that bypass `public.dart` barrel files.
> **Rules**: Do NOT modify any source files until executing a step. Do NOT execute any refactoring outside the described steps.
> **Package name**: `service_sentinel_fe_v2`

---

## Available Barrel Files (reference)

| Layer path | Barrel file |
|---|---|
| `core/auth/domain/` | `core/auth/domain/public.dart` |
| `core/auth/data/` | `core/auth/data/public.dart` |
| `core/auth/di/` | `core/auth/di/public.dart` |
| `core/auth/application/` | `core/auth/application/public.dart` |
| `features/api_monitoring/domain/` | `features/api_monitoring/domain/public.dart` |
| `features/api_monitoring/presentation/` | `features/api_monitoring/presentation/public.dart` |
| `features/dashboard/domain/` | `features/dashboard/domain/public.dart` |
| `features/dashboard/data/` | `features/dashboard/data/public.dart` |
| `features/dashboard/presentation/` | `features/dashboard/presentation/public.dart` |
| `features/dashboard/di/` | `features/dashboard/di/public.dart` |
| `features/incident/domain/` | `features/incident/domain/public.dart` |
| `features/incident/data/` | `features/incident/data/public.dart` |
| `features/incident/presentation/` | `features/incident/presentation/public.dart` |
| `features/incident/di/` | `features/incident/di/public.dart` |
| `features/project/domain/` | `features/project/domain/public.dart` |
| `features/project/data/` | `features/project/data/public.dart` |
| `features/project/presentation/` | `features/project/presentation/public.dart` |
| `features/project/di/` | `features/project/di/public.dart` |
| `features/auth/presentation/` | `features/auth/presentation/public.dart` |

---

## Group 1 — core (auth)

### Step 1.1

**File**: `fe/lib/core/auth/application/providers/auth_provider.dart`

**Current imports to replace** (lines 6–8 and 15):

```dart
import 'package:service_sentinel_fe_v2/core/auth/data/repositories/device_token_repository.dart';
import 'package:service_sentinel_fe_v2/core/auth/di/repository_providers.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/usecases/register_device_token.dart';
```

```dart
import '../../domain/entities/auth_state.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/core/auth/data/public.dart';
import 'package:service_sentinel_fe_v2/core/auth/di/public.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';
```

> The relative import `'../../domain/entities/auth_state.dart'` is already covered by `core/auth/domain/public.dart` (which exports `entities/auth_state.dart`). Remove the relative import; the single package import above covers it.

**Completion criteria**: File compiles without error. No `import` in this file references a path deeper than a `public.dart` within `core/auth/`.

---

### Step 1.2

**File**: `fe/lib/core/auth/data/repositories/auth_repository.dart`

**Current import to replace** (line 7):

```dart
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/user.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `core/auth/domain/`.

---

### Step 1.3

**File**: `fe/lib/core/auth/data/repositories/device_token_repository.dart`

**Current import to replace** (line 2):

```dart
import 'package:service_sentinel_fe_v2/core/auth/domain/repositories/device_token_repository.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `core/auth/domain/`.

---

### Step 1.4

**File**: `fe/lib/core/auth/di/repository_providers.dart`

**Current imports to replace** (lines 2 and 4):

```dart
import 'package:service_sentinel_fe_v2/core/auth/data/repositories/auth_repository.dart';
```

```dart
import '../domain/repositories/auth_repository.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/core/auth/data/public.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';
```

> The relative import `'../domain/repositories/auth_repository.dart'` (domain interface) and the package import of the data implementation are both covered by their respective barrel files.

**Completion criteria**: File compiles without error. No import in this file references an individual file under `core/auth/data/` or `core/auth/domain/`.

---

## Group 2 — auth (features/auth)

### Step 2.1

**File**: `fe/lib/features/auth/presentation/screens/login_screen.dart`

**Current imports to replace** (lines 7–8):

```dart
import 'package:service_sentinel_fe_v2/core/auth/application/providers/auth_provider.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/auth_state.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/core/auth/application/public.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `core/auth/application/` or `core/auth/domain/`.

---

### Step 2.2

**File**: `fe/lib/features/auth/presentation/widgets/login_form_section.dart`

**Current imports to replace** (lines 3 and 5):

```dart
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/auth_state.dart';
```

```dart
import '../../../../core/auth/application/providers/auth_provider.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/core/auth/application/public.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `core/auth/`.

---

## Group 3 — api_monitoring

### Step 3.1

**File**: `fe/lib/features/api_monitoring/presentation/widgets/create_service_set_form.dart`

**Current import to replace** (line 6):

```dart
import 'package:service_sentinel_fe_v2/features/api_monitoring/domain/entities/service.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/api_monitoring/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/api_monitoring/domain/`.

---

## Group 4 — dashboard

### Step 4.1

**File**: `fe/lib/features/dashboard/data/data_sources/global_dashboard_data_source.dart`

**Current imports to replace** (lines 1–2 and 4):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
```

```dart
import '../../domain/entities/global_dashboard_metrics.dart';
```

**Replace all three with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
```

> `dashboard_matrics.dart`, `dashboard_overview.dart`, and `global_dashboard_metrics.dart` are all exported by `features/dashboard/domain/public.dart`.

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/`.

---

### Step 4.2

**File**: `fe/lib/features/dashboard/data/data_sources/remote_global_dashboard_data_source_impl.dart`

**Current imports to replace** (lines 4–6):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import '../../domain/entities/global_dashboard_metrics.dart';
```

**Replace all three with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
```

> Lines 2–3 (`data/models/dashboard_metrics_dto.dart`, `data/models/dashboard_overview_dto.dart`) are intra-layer (data→data) and are left unchanged.

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/`.

---

### Step 4.3

**File**: `fe/lib/features/dashboard/data/models/dashboard_metrics_dto.dart`

**Current import to replace** (line 2):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/`.

---

### Step 4.4

**File**: `fe/lib/features/dashboard/data/models/dashboard_overview_dto.dart`

**Current import to replace** (line 3):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
```

> Line 2 (`data/models/service_health_summary_dto.dart`) is intra-layer (data→data) and is left unchanged.

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/`.

---

### Step 4.5

**File**: `fe/lib/features/dashboard/data/models/service_health_summary_dto.dart`

**Current import to replace** (line 3):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/service_health_summary.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
```

> Line 2 (`core/constants/enums.dart`) has no barrel file; leave it unchanged.

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/`.

---

### Step 4.6

**File**: `fe/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`

**Current imports to replace** (lines 1–2 and 6–7):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
```

```dart
import '../../domain/entities/global_dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
```

**Replace all four with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/`.

---

### Step 4.7

**File**: `fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart`

**Current imports to replace** (lines 4–10):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_matrix.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_overview.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import '../../domain/usecases/get_global_dashboard.dart';
import '../../domain/entities/global_dashboard_metrics.dart';
import '../../di/repository_providers.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/di/public.dart';
```

> All six domain imports collapse into `domain/public.dart`. The `di/repository_providers.dart` import is covered by `features/dashboard/di/public.dart` (which exports `repository_providers.dart`).

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/` or `features/dashboard/di/`.

---

### Step 4.8

**File**: `fe/lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Current imports to replace** (lines 5 and 7):

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
```

```dart
import '../../../../core/auth/application/providers/auth_provider.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';
import 'package:service_sentinel_fe_v2/core/auth/application/public.dart';
```

> Line 4 (`presentation/providers/dashboard_provider.dart`) is intra-layer (presentation→presentation) and is left unchanged.

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/dashboard/domain/` or `core/auth/application/`.

---

## Group 5 — project

### Step 5.1

**File**: `fe/lib/features/project/data/repositories/project_repository_impl.dart`

**Current import to replace** (line 1):

```dart
import 'package:service_sentinel_fe_v2/features/project/domain/entities/project_health.dart';
```

**Replace with**:

```dart
import 'package:service_sentinel_fe_v2/features/project/domain/public.dart';
```

**Completion criteria**: File compiles without error. No import in this file references an individual file under `features/project/domain/`.

---

## Group 6 — incident

No violations found. The `incident` feature already uses barrel files correctly across all layers.

---

## Summary

| Group | Files affected | Import changes |
|---|---|---|
| core/auth | 4 | 7 |
| features/auth | 2 | 4 |
| api_monitoring | 1 | 1 |
| dashboard | 8 | 19 |
| project | 1 | 1 |
| incident | 0 | 0 |
| **Total** | **16** | **32** |

## Final verification checklist

- [ ] Run `flutter analyze` from `fe/` — zero barrel-related import warnings
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs` — generated `.g.dart` and `.freezed.dart` files rebuild cleanly
- [ ] Run `flutter test` — all tests pass
- [ ] Grep for any remaining direct internal imports: `grep -r "import 'package:service_sentinel_fe_v2/.*/(entities|repositories|usecases|data_sources|models|providers|screens|widgets|view_models|states)/" fe/lib/ | grep -v public.dart | grep -v ".g.dart" | grep -v ".freezed."` — output must be empty

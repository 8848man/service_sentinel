# Project Conventions

## Frontend (Flutter)

### Folder Structure

```
lib/
├── app.dart        ← single file: ServiceSentinelApp (MaterialApp.router)
├── core/
└── features/
```

**app.dart** — AppRoot and MaterialApp configuration in a single file. Does not contain business logic. Router is located in `core/router/`.

**core/** — Global non-UI logic. Manages session, cache, auth state, and shared data that must persist across features. Sub-directories vary in layering depth:

- `core/auth/` — full layers: `domain/` (entities/, repositories/, usecases/), `data/` (dto/, repositories/), `di/`, `application/` (providers/, utils/)
- `core/settings/` — partial layers: `domain/`, `application/`, `infrastructure/`, `presentation/` (screens/, view_models/, widgets/)
- All other core sub-directories are flat (no sub-layers):

```
core/
├── config/         ← app configuration constants
├── constants/      ← enums, spacing
├── data/           ← data source mode helpers
├── di/             ← root-level Riverpod provider overrides
├── error/          ← AppError types, Result<T>, error handler
├── extensions/     ← BuildContext extensions
├── infrastructure/ ← GuestApiKeyService
├── l10n/           ← locale provider
├── migration/      ← migration state and service
├── navigation/     ← MainScaffold
├── network/        ← DioClient, AuthenticationInterceptor
├── router/         ← GoRouter configuration
├── services/       ← DeviceRegistrationService
├── state/          ← ProjectSession, ProjectSessionNotifier
├── storage/        ← SecureStorage wrapper
└── theme/          ← AppTheme, AppColors, ThemeProvider
```

**features/** — Screen-level features. Standard structure (exemplified by `api_monitoring/`): `domain/`, `data/`, `di/`, `presentation/` (screens/, widgets/, states/, providers/, view_models/).

Exceptions:
- `analysis/` — presentation only (screens/, widgets/); no domain/data/di
- `auth/` — presentation only (screens/, widgets/); domain/data/di live in `core/auth/`
- `dashboard/` — adds `application/use_cases/`; presentation omits widgets/ and states/
- `incident/`, `project/` — add `application/use_cases/`; presentation omits states/ and view_models/

Features may contain nested features under `features/{feature}/features/` when a feature has distinct sub-screens.

### Layer Rules

- **domain/** — entities, repository interfaces, usecases. No Flutter/external dependencies.
- **data/** — repository implementations, DTOs, API calls.
- **di/** — DI bindings only. Wires repository implementations to domain interfaces and provides usecases.
- **application/** (core and some features) — session/cache state management via Riverpod providers.
- **presentation/states/** — freezed classes only. Pure data, no logic.
- **presentation/providers/** — FutureProvider or StreamProvider for data fetching. UI watches these directly. No state mutation.
- **presentation/view_models/** — Notifier classes. Handles user interactions and state changes. Uses `@riverpod` annotation; generated `.g.dart` files live alongside.

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `{name}Provider` (generated), Notifiers: `{Name}ViewModel`
- State models: `{Name}State`
- Each layer should expose a `public.dart` barrel file for external imports. Currently only `core/auth/` sub-layers implement this consistently; treat it as a convention goal, not the current state of all layers.

---

## Backend (Python / FastAPI)

### Folder Structure

```
app/
├── api/
│   └── v3/                     ← all active routers (v1/v2 removed)
├── core/                       ← config, database, auth, firebase
├── models/                     ← SQLAlchemy ORM models
├── repositories/               ← database access layer
├── schemas/                    ← Pydantic request/response schemas
└── services/
    ├── monitoring/              ← monitoring worker + scheduler
    ├── notification/            ← notification policy evaluation and dispatch
    │   ├── channels/            ← FCM, Email, Slack, Webhook channel implementations
    │   ├── policies/            ← per-resource notification policies
    │   ├── rules/               ← rule parser and evaluator
    │   ├── senders/             ← sender abstractions (Firebase, log)
    │   └── templates/           ← message templates
    └── ai_analysis_service.py  ← AI analysis (flat file, no subdirectory)
```

### Layer Rules

- **api/v3/** — request routing, auth dependency injection, calls repositories or services. No business logic.
- **models/** — SQLAlchemy model definitions only. No schema imports.
- **repositories/** — database access only. Returns ORM model instances. Must not import from `schemas/`. Schema conversion happens in the router or service layer.
- **schemas/** — Pydantic models for request validation and response serialization. Filename convention: `{resource}_schema.py`.
- **services/** — business logic that spans multiple repositories or involves external calls (AI, notifications, HTTP checks).
- **core/** — app-wide infrastructure: database session, config settings, Firebase init, auth helpers.
- **services/monitoring/** — contains both the monitoring worker and the scheduler. `scheduler.py` lives here, not at the project root.
- **services/notification/** — notification policy evaluation and dispatch in one place. Not split across `core/` and `services/`.

### Naming Conventions

- Files: `snake_case.py`
- Classes: `PascalCase`
- Schemas: `{Resource}Create`, `{Resource}Update`, `{Resource}Response` pattern
- Repositories: `{Resource}Repository`
- Services: `{Resource}Service` or `{Name}UseCase`

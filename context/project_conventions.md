# Project Conventions

## Frontend (Flutter)

### Folder Structure

```
lib/
├── app/
├── core/
└── features/
```

**app/** — AppRoot, MaterialApp configuration, scaffold, adaptor, wrapper. Does not contain business logic. Router is located in `core/router/`.

**core/** — Global non-UI logic. Manages session, cache, auth state, and shared data that must persist across features. Each sub-feature follows the layer structure below. `application/` is the primary layer; `presentation/` is only added when shared widgets exist.

```
core/
└── {feature}/
    ├── domain/
    ├── data/
    ├── di/
    ├── application/
    └── presentation/  ← shared widgets only, optional
```

**features/** — Screen-level features. Each feature is self-contained.

```
features/
└── {feature}/
    ├── domain/
    ├── data/
    ├── di/             ← repository + usecase DI bindings
    └── presentation/
        ├── screens/
        ├── widgets/
        ├── states/     ← freezed state models
        ├── providers/  ← FutureProvider / StreamProvider (data fetch, read-only)
        └── view_models/ ← Notifier (user interaction, state mutation)
```

Features may contain nested features under `features/{feature}/features/` when a feature has distinct sub-screens.

### Layer Rules

- **domain/** — entities, repository interfaces, usecases. No Flutter/external dependencies.
- **data/** — repository implementations, DTOs, API calls.
- **di/** — DI bindings only. Wires repository implementations to domain interfaces and provides usecases.
- **application/** (core only) — session/cache state management via Riverpod providers.
- **presentation/states/** — freezed classes only. Pure data, no logic.
- **presentation/providers/** — FutureProvider or StreamProvider for data fetching. UI watches these directly. No state mutation.
- **presentation/view_models/** — Notifier classes. Handles user interactions and state changes. Uses `@riverpod` annotation; generated `.g.dart` files live alongside.

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `{name}Provider` (generated), Notifiers: `{Name}ViewModel`
- State models: `{Name}State`
- Each layer exposes a `public.dart` barrel file for external imports

---

## Backend (Python / FastAPI)

### Folder Structure

```
app/
├── api/
│   └── v3/             ← all active routers (v1/v2 removed)
├── core/               ← config, database, auth, firebase
├── models/             ← SQLAlchemy ORM models
├── repositories/       ← database access layer
├── schemas/            ← Pydantic request/response schemas
└── services/
    ├── monitoring/     ← monitoring worker + scheduler
    ├── notification/   ← notification policy + dispatch
    └── ai/             ← AI analysis
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

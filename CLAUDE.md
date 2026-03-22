# Service Sentinel

AI-powered API monitoring platform. Users register service endpoints; the system periodically runs health checks, opens incidents on failure, and provides on-demand Gemini-powered root cause analysis.

For detailed specifications, read the context documents before making changes:

- `context/architecture.md` — system components and interaction flow
- `context/domain_model.md` — entity definitions, business rules, plan limits
- `context/api_conventions.md` — endpoint patterns, auth, status codes, error format
- `context/project_conventions.md` — folder structure and layer rules for BE and FE
- `context/tech_stack.md` — framework versions and external service integrations

---

## Repository Layout

```
service_sentinel/
├── context/          ← architecture, domain, API, and convention docs (read-only reference)
├── be/               ← Python / FastAPI backend  (app/ package root)
└── fe/               ← Flutter frontend          (lib/ package root)
```

---

## Backend (`be/`)

**Entry point**: `be/main.py`
**Package root**: imports use `from app.…` (the `be/` directory is `app/` at runtime)

### Folder map

```
be/
├── main.py
├── api/v3/           ← routers: projects, services, incidents, dashboard, user, device_token, subscription
├── core/             ← config, database, firebase, auth_v3, plan_limits
├── models/           ← SQLAlchemy ORM models (no schema imports)
├── repositories/     ← DB access only; returns ORM instances
├── schemas/          ← Pydantic request/response models ({Resource}Create / Update / Response)
└── services/
    ├── ai_analysis_service.py   ← AIAnalysisService; uses Gemini SDK (google-generativeai)
    ├── incident_service.py      ← IncidentService; called by monitoring worker
    ├── inactivity_service.py
    ├── device_token_service.py
    ├── monitoring/
    │   ├── monitoring_worker.py ← executes health checks; calls IncidentService, not Notification directly
    │   └── scheduler.py        ← APScheduler; lives here, not at project root
    └── notification/
        ├── channels/            ← FCM, Email, Slack, Webhook
        ├── policies/            ← per-resource notification policies
        ├── rules/               ← rule parser and evaluator
        ├── senders/             ← Firebase, log
        └── templates/
```

### Key implementation facts

- **AI**: `AIAnalysisService` uses `google.generativeai` SDK. API key = `settings.AI_API_KEY`; model defaults to `"gemini-pro"` (override via `AI_MODEL` env var). The service is **disabled by default** (`AI_ENABLED=False`). On `force_reanalyze=True`, the existing `AIAnalysis` row is deleted before re-creation.
- **Monitoring pipeline**: `MonitoringWorker.check_service()` → on failure calls `incident_service.handle_failure()`; on success calls `incident_service.resolve_if_healthy()`. The worker passes a `NotifyIncidentUseCase` instance to `IncidentService`; the worker never calls the notification system directly.
- **Notification on resolution**: not yet implemented — the corresponding call in `resolve_if_healthy` is commented out.
- **Incident threshold**: incident is created when failures within a rolling window of `(check_interval_seconds / 60) × failure_threshold` minutes reach `failure_threshold`. Not strictly consecutive. Once an open incident exists, each subsequent failure increments `consecutive_failures` directly.
- **Plan limits** (`core/plan_limits.py`): free → 3 projects / 10 services; pro → 10 / 20; max → 10 / 50. Expired/cancelled subscriptions fall back to free limits. Guest projects always apply free limits.
- **Auth**: Firebase ID token (`Authorization: Bearer`) takes priority over API key (`X-API-Key`) when both headers are present. Two endpoints require no auth: `POST /api/v3/projects/bootstrap` and `GET /api/v3/dashboard/global`.
- **`HealthCheckResult`** is a lightweight projection for dashboards only — not linked to incidents or AI analysis. `Service` has no `health_check_results` ORM attribute (`back_populates` not defined).
- **`SubscriptionHistory`** model exists but is not yet implemented — planned for future billing integration.
- **Dev files**: `test_db.py` and `main_notification_test.py` are one-off dev scripts, not part of the test suite.

### Commands

```bash
cd be
uvicorn app.main:app --reload          # dev server (port 5173)
pytest                                  # run tests
alembic upgrade head                   # apply migrations
alembic revision --autogenerate -m ""  # generate migration
```

### Do NOT

- Import `schemas/` from `repositories/` — schema conversion belongs in the router or service layer.
- Put business logic in `api/v3/` routers — routers call repositories or services only.
- Add models to `models/` that import from `schemas/`.
- Hardcode `AI_API_KEY` or any secret in source files.
- Call the notification system directly from `monitoring_worker.py`.

---

## Frontend (`fe/`)

**Entry point**: `fe/main.dart` → `fe/app.dart` (MaterialApp.router, no business logic)
**Package name**: `service_sentinel_fe_v2`
**API base**: configured in `core/config/app_config.dart`; defaults to the Cloud Run URL; override with `--dart-define=API_BASE_URL=http://localhost:5173` for local dev.

### Folder map

```
fe/
├── app.dart
├── main.dart
├── firebase_options.dart
├── l10n/                    ← en + ko ARB files + generated localizations
├── core/
│   ├── auth/                ← full layers: domain/, data/, di/, application/
│   ├── settings/            ← partial layers: domain/, application/, infrastructure/, presentation/
│   ├── config/              ← AppConfig (API URL, timeouts)
│   ├── constants/           ← enums, AppSpacing, plan_limits
│   ├── data/                ← DataSourceMode helpers
│   ├── di/                  ← root-level Riverpod provider overrides
│   ├── error/               ← AppError, Result<T>, error_handler
│   ├── extensions/          ← BuildContext extensions
│   ├── infrastructure/      ← GuestApiKeyService
│   ├── l10n/                ← locale provider
│   ├── migration/           ← migration state and service
│   ├── navigation/          ← MainScaffold, MainAppBar
│   ├── network/             ← DioClient, AuthenticationInterceptor
│   ├── router/              ← GoRouter (app_router.dart); routes defined in AppRoutes
│   ├── services/            ← DeviceRegistrationService
│   ├── state/               ← ProjectSession, ProjectSessionNotifier
│   ├── storage/             ← SecureStorage wrapper
│   └── theme/               ← AppTheme, AppColors, ThemeProvider
└── features/
    ├── analysis/            ← presentation only (screens/, widgets/); no domain/data/di
    ├── api_monitoring/      ← full layers + standard presentation
    ├── auth/                ← presentation only; domain/data/di live in core/auth/
    ├── dashboard/           ← adds application/use_cases/; presentation omits widgets/ and states/
    ├── incident/            ← adds application/use_cases/; presentation omits states/ and view_models/
    ├── project/             ← adds application/use_cases/; presentation omits states/ and view_models/
    └── subscription/        ← full layers
```

### Routes (`core/router/app_router.dart`)

| Route | Screen |
|---|---|
| `/` | SplashScreen |
| `/login` | LoginScreen |
| `/project-selection` | ProjectSelectionScreen |
| `/project/:id` | ProjectDetailScreen |
| `/project/:id/edit` | ProjectEditScreen |
| `/main/dashboard` | DashboardScreen |
| `/main/services` | ServicesScreen |
| `/service/:id` | ServiceDetailScreen |
| `/service/:id/edit` | ServiceEditScreen |
| `/main/incidents` | IncidentsScreen |
| `/incident/:id` | IncidentDetailScreen |
| `/main/analysis` | AnalysisOverviewScreen |
| `/main/settings` | SettingsScreen |
| `/upgrade` | UpgradeScreen |

### Layer rules

- **domain/**: entities, repository interfaces, use cases. No Flutter or external dependencies.
- **data/**: repository implementations, DTOs, API calls via DioClient.
- **di/**: DI bindings only — wires implementations to interfaces and provides use cases.
- **application/**: session/cache state via Riverpod providers (core and some features).
- **presentation/states/**: `freezed` classes only — pure data, no logic.
- **presentation/providers/**: `FutureProvider` or `StreamProvider` — UI watches directly, no state mutation.
- **presentation/view_models/**: `Notifier` classes with `@riverpod` annotation; generated `.g.dart` files live alongside.

### Naming conventions

- Files: `snake_case.dart` | Classes: `PascalCase`
- Providers: `{name}Provider` (generated) | Notifiers: `{Name}ViewModel` | States: `{Name}State`
- DTOs: `{Resource}Dto` | Each layer should expose a `public.dart` barrel file (currently consistent only in `core/auth/` sub-layers — treat as a convention goal)

### Commands

```bash
cd fe
flutter run --dart-define=API_BASE_URL=http://localhost:5173   # local dev
flutter build apk                                               # Android
flutter build ios                                               # iOS
dart run build_runner build --delete-conflicting-outputs       # regenerate .g.dart / .freezed.dart
flutter gen-l10n                                                # regenerate l10n
```

### Do NOT

- Put business logic in `app.dart` — it is router configuration only.
- Add Flutter/external dependencies to `domain/` layers.
- Import between features directly — go through `core/` or `di/` bindings.
- Mutate state inside `presentation/providers/` — that belongs in `view_models/`.
- Skip regenerating `.g.dart` files after modifying `@riverpod` annotated classes or `freezed` models.

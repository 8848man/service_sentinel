# Core Logic Contracts - Index

Quick reference for navigating all core logic contracts.

---

## 📑 Documentation

| Document | Description |
|----------|-------------|
| `STEP_2_CONTRACTS.md` | Comprehensive documentation of all contracts |
| `CONTRACTS_SUMMARY.md` | Quick visual summary |
| `CONTRACTS_INDEX.md` | This file - navigation index |

---

## 🗂️ File Locations

### Core Infrastructure

```
lib/core/
├── error/
│   ├── result.dart                      ← Result<T> type for error handling
│   ├── app_error.dart                   ← Error hierarchy
│   └── error_handler.dart               ← Error conversion logic
├── constants/
│   └── enums.dart                       ← Global enums (SourceOfTruth, ServiceType, etc.)
├── di/
│   ├── providers.dart                   ← Global DioClient provider
│   └── repository_providers.dart        ← Repository switching providers
└── storage/
    └── secure_storage.dart              ← API key & project ID storage
```

---

### Auth Feature

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   ├── user.dart                    ← User, GuestUser
│   │   └── auth_state.dart              ← AuthState (with sourceOfTruth)
│   └── repositories/
│       └── auth_repository.dart         ← Auth contract
└── application/
    └── providers/
        └── auth_provider.dart           ← AuthStateNotifier + helpers
```

---

### Project Feature

```
lib/features/project/
├── domain/
│   ├── entities/
│   │   ├── project.dart                 ← Project, ProjectCreate, ProjectUpdate, ProjectStats
│   │   └── api_key.dart                 ← ApiKey, ApiKeyCreate
│   └── repositories/
│       ├── project_repository.dart      ← Project operations contract
│       └── api_key_repository.dart      ← API key operations contract
├── application/
│   └── use_cases/
│       ├── load_projects.dart           ← Load projects with filtering
│       ├── create_project.dart          ← Create project with validation
│       └── migrate_local_projects_to_server.dart  ← Migration logic
└── infrastructure/
    ├── data_sources/
    │   └── project_data_source.dart     ← Local vs Remote data source contracts
    └── models/
        ├── project_dto.dart             ← DTOs for API communication
        └── api_key_dto.dart             ← API key DTOs
```

---

### API Monitoring Feature

```
lib/features/api_monitoring/
├── domain/
│   ├── entities/
│   │   ├── service.dart                 ← Service, ServiceCreate, ServiceUpdate
│   │   └── health_check.dart            ← HealthCheck
│   └── repositories/
│       ├── service_repository.dart      ← Service operations contract
│       └── dashboard_repository.dart    ← Dashboard aggregation contract
├── application/
│   └── use_cases/
│       ├── load_services.dart           ← Load services with filtering
│       └── trigger_health_check.dart    ← Manual health check
└── infrastructure/
    ├── data_sources/
    │   └── service_data_source.dart     ← Local vs Remote data source contracts
    └── models/
        ├── service_dto.dart             ← Service DTOs
        └── health_check_dto.dart        ← Health check DTOs
```

---

### Incident Feature

```
lib/features/incident/
├── domain/
│   ├── entities/
│   │   ├── incident.dart                ← Incident, IncidentUpdate
│   │   └── ai_analysis.dart             ← AiAnalysis
│   └── repositories/
│       └── incident_repository.dart     ← Incident operations contract
├── application/
│   └── use_cases/
│       ├── load_incidents.dart          ← Load incidents with filtering
│       └── request_ai_analysis.dart     ← Request AI analysis
└── infrastructure/
    ├── data_sources/
    │   └── incident_data_source.dart    ← Local vs Remote data source contracts
    └── models/
        ├── incident_dto.dart            ← Incident DTOs
        └── ai_analysis_dto.dart         ← AI analysis DTOs
```

---

## 🔍 Quick Search Guide

### Looking for...

#### **Error Handling?**
→ `lib/core/error/result.dart`

#### **Auth State Management?**
→ `lib/features/auth/application/providers/auth_provider.dart`

#### **Source of Truth Logic?**
→ `lib/features/auth/domain/entities/auth_state.dart`

#### **Repository Switching?**
→ `lib/core/di/repository_providers.dart`

#### **Migration Logic?**
→ `lib/features/project/application/use_cases/migrate_local_projects_to_server.dart`

#### **API Key Management?**
→ `lib/features/project/domain/entities/api_key.dart`
→ `lib/core/storage/secure_storage.dart`

#### **Domain Entities?**
→ `lib/features/{feature}/domain/entities/`

#### **Repository Contracts?**
→ `lib/features/{feature}/domain/repositories/`

#### **Use Cases?**
→ `lib/features/{feature}/application/use_cases/`

#### **DTOs?**
→ `lib/features/{feature}/infrastructure/models/`

---

## 🎯 Key Concepts

### Result Type
```dart
Result<T> = Success<T> | Failure<AppError>
```
**Location:** `lib/core/error/result.dart`

### Auth State
```dart
AuthState {
  user: User
  isAuthenticated: bool
  sourceOfTruth: SourceOfTruth  // Local or Server
  currentProjectId: String?
  apiKey: String?
}
```
**Location:** `lib/features/auth/domain/entities/auth_state.dart`

### Repository Pattern
```dart
// Domain: Interface
abstract class ProjectRepository {
  Future<Result<List<Project>>> getAll();
}

// Infrastructure: Local Implementation
class LocalProjectRepository implements ProjectRepository {
  // Uses Hive
}

// Infrastructure: Remote Implementation
class RemoteProjectRepository implements ProjectRepository {
  // Uses REST API
}

// Provider: Switches based on auth
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return isAuthenticated ? RemoteImpl() : LocalImpl();
});
```

### DTO Pattern
```dart
// Domain Entity (pure, immutable)
class Project {
  final String id;
  final String name;
  final bool isActive;
}

// DTO (maps to backend API)
@JsonSerializable()
class ProjectDto {
  @JsonKey(name: 'is_active') final bool isActive;

  Project toDomain() => ...
  static ProjectDto fromDomain(Project p) => ...
}
```

---

## 📋 Cheatsheet

### Creating a New Feature

1. **Domain Layer**
   ```
   features/{feature}/domain/
   ├── entities/{entity}.dart
   └── repositories/{entity}_repository.dart
   ```

2. **Application Layer**
   ```
   features/{feature}/application/
   └── use_cases/{action}_{entity}.dart
   ```

3. **Infrastructure Layer**
   ```
   features/{feature}/infrastructure/
   ├── data_sources/{entity}_data_source.dart
   └── models/{entity}_dto.dart
   ```

4. **Providers**
   ```
   core/di/repository_providers.dart
   ← Add switching provider
   ```

### Adding a New Entity

1. Define in `domain/entities/{entity}.dart`
2. Add repository interface in `domain/repositories/{entity}_repository.dart`
3. Add data source contracts in `infrastructure/data_sources/{entity}_data_source.dart`
4. Add DTOs in `infrastructure/models/{entity}_dto.dart`
5. Add use cases in `application/use_cases/`
6. Add repository provider in `core/di/repository_providers.dart`

---

## 🚀 Implementation Order (Next Steps)

### Phase 3: Infrastructure

1. **Firebase Auth**
   - Implement `FirebaseAuthRepository`
   - Handle auth state stream
   - Wrap Firebase types (no leakage)

2. **Hive Local Storage**
   - Set up Hive boxes for each entity
   - Implement Local data sources
   - Implement Local repositories

3. **REST API**
   - Create Retrofit API clients
   - Implement Remote data sources
   - Implement Remote repositories
   - Add auth interceptors

4. **Wire Providers**
   - Complete repository switching logic
   - Add all dependencies

### Phase 4: UI

1. Connect screens to use cases
2. Add loading/error states
3. Implement migration flow UI
4. Add real-time updates

---

## ✅ Quick Validation

Before moving to Phase 3, verify:

- [ ] Can you find any domain entity?
- [ ] Can you find its repository contract?
- [ ] Can you find its data source contracts (Local + Remote)?
- [ ] Can you find its DTOs?
- [ ] Can you find use cases for it?
- [ ] Does the repository provider switch Local ↔ Remote?
- [ ] Is AuthState driving the switching?
- [ ] Are all entities immutable (freezed)?
- [ ] Do all operations return `Result<T>`?
- [ ] Are DTOs handling backend API format?

If YES to all → Ready for Phase 3! ✅

---

**End of Contracts Index**

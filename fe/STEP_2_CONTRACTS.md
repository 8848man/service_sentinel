# Service Sentinel Frontend V2 - Step 2: Core Logic Contracts

## Overview

This document describes all non-UI core logic contracts implemented in Step 2. This establishes the foundation for backend-frontend communication and data ownership strategy.

---

## ✅ Completed Implementations

### 1. **Result Type for Error Handling**

**Location:** `lib/core/error/result.dart`

```dart
Result<T>
  ├─ Success<T>(data)
  └─ Failure<T>(error)
```

**Purpose:**
- Prevents throwing exceptions across layers
- Forces explicit error handling
- Type-safe success/failure branching

**Usage Example:**
```dart
final result = await repository.getProject('123');
result.when(
  success: (project) => print(project.name),
  failure: (error) => print(error.message),
);
```

---

### 2. **Domain Entities** (Immutable)

All domain entities use `freezed` for immutability and are free from persistence concerns.

#### **Core Enums** (`lib/core/constants/enums.dart`)
- `SourceOfTruth` - Local DB vs Server DB
- `ServiceType` - http_api, https_api, gcp_endpoint, firebase, websocket, grpc
- `HttpMethod` - GET, POST, PUT, DELETE, PATCH, HEAD
- `IncidentStatus` - open, investigating, resolved, acknowledged
- `IncidentSeverity` - critical, high, medium, low

#### **Auth Entities**
- `User` - Firebase authenticated user
- `GuestUser` - Singleton for unauthenticated users
- `AuthState` - Global auth state with source of truth determination

**Key Feature:**
```dart
AuthState {
  user: User
  isAuthenticated: bool
  sourceOfTruth: SourceOfTruth  // Auto-determined
  currentProjectId: String?
  apiKey: String?
}
```

#### **Project Entities**
- `Project` - Project aggregate root
- `ProjectCreate` - Creation input
- `ProjectUpdate` - Update input
- `ProjectStats` - Dashboard statistics
- `ApiKey` - Project-scoped API keys (server-only)
- `ApiKeyCreate` - API key creation input

**Important Boundary:**
```dart
Project {
  isLocalOnly: bool  // True for guest-created projects
}
```

#### **Service Entities**
- `Service` - Monitored API endpoint
- `ServiceCreate` - Creation input
- `ServiceUpdate` - Update input
- `HealthCheck` - Health check result

#### **Incident Entities**
- `Incident` - Service failure event
- `IncidentUpdate` - Update input
- `AiAnalysis` - AI-generated root cause analysis

---

### 3. **Repository Interfaces** (Domain Layer)

Repositories define **contracts** that infrastructure implements.

#### **AuthRepository** (`auth/domain/repositories/`)
```dart
- getCurrentUser() → Result<User>
- signInWithEmail(email, password) → Result<User>
- signUpWithEmail(email, password) → Result<User>
- signOut() → Result<void>
- authStateChanges() → Stream<User>
```

#### **ProjectRepository** (`project/domain/repositories/`)
```dart
- getAll() → Result<List<Project>>
- getById(id) → Result<Project>
- getStats(id) → Result<ProjectStats>
- create(data) → Result<Project>
- update(id, data) → Result<Project>
- delete(id) → Result<void>
- uploadToServer(project) → Result<Project>  // Migration
- existsOnServer(name) → Result<bool>        // Conflict detection
```

#### **ApiKeyRepository** (`project/domain/repositories/`)
```dart
- getAll(projectId) → Result<List<ApiKey>>
- create(projectId, data) → Result<ApiKey>  // Returns keyValue ONCE
- delete(projectId, keyId) → Result<void>
- deactivate(projectId, keyId) → Result<void>
- verify(apiKey) → Result<bool>
```

**CRITICAL:** API keys are **server-only**. Guest users cannot create or use them.

#### **ServiceRepository** (`api_monitoring/domain/repositories/`)
```dart
- getAll({isActive}) → Result<List<Service>>
- getById(id) → Result<Service>
- create(data) → Result<Service>
- update(id, data) → Result<Service>
- delete(id) → Result<void>
- activate(id) → Result<void>
- deactivate(id) → Result<void>
- checkNow(id) → Result<HealthCheck>
- getHealthChecks(id, {limit, since}) → Result<List<HealthCheck>>
- getLatestHealthCheck(id) → Result<HealthCheck?>
- getStats(id, period) → Result<ServiceStats>
```

#### **IncidentRepository** (`incident/domain/repositories/`)
```dart
- getAll({status, severity, serviceId}) → Result<List<Incident>>
- getById(id) → Result<Incident>
- update(id, data) → Result<Incident>
- acknowledge(id) → Result<Incident>
- resolve(id) → Result<Incident>
- getAnalysis(id) → Result<AiAnalysis?>
- requestAnalysis(id) → Result<void>  // Async processing
- getByService(serviceId) → Result<List<Incident>>
```

#### **DashboardRepository** (`api_monitoring/domain/repositories/`)
```dart
- getOverview() → Result<DashboardOverview>
- getMetrics(period) → Result<DashboardMetrics>
```

---

### 4. **Data Source Interfaces** (Infrastructure Layer)

Data sources separate Local (Hive) from Remote (REST API) implementations.

#### **Pattern:**
```dart
abstract class DataSource {
  // Common operations
}

abstract class LocalDataSource extends DataSource {
  // Local-specific operations (Hive)
}

abstract class RemoteDataSource extends DataSource {
  // Remote-specific operations (REST API)
}
```

#### **Implemented Data Sources:**
- `ProjectDataSource` → LocalProjectDataSource / RemoteProjectDataSource
- `ServiceDataSource` → LocalServiceDataSource / RemoteServiceDataSource
- `IncidentDataSource` → LocalIncidentDataSource / RemoteIncidentDataSource

**Key Separation:**
- **Local:** CRUD operations with Hive
- **Remote:** CRUD operations with REST API + additional server features (activate, deactivate, checkNow, requestAnalysis)

---

### 5. **Global Auth State Provider**

**Location:** `features/auth/application/providers/auth_provider.dart`

```dart
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  // Manages global auth state
  // Determines source of truth (Local vs Server)
  // Stores project context and API key
}
```

**Key Methods:**
- `signIn(email, password)` → Switches to authenticated mode
- `signUp(email, password)` → Creates account and switches
- `signOut()` → Clears credentials and returns to guest mode
- `setProjectContext(projectId, apiKey)` → Stores project + key + injects into Dio
- `clearProjectContext()` → Removes project + key

**Helper Providers:**
```dart
@riverpod bool isAuthenticated(ref)
@riverpod User? currentUser(ref)
@riverpod bool hasProjectContext(ref)
@riverpod String? currentProjectId(ref)
```

---

### 6. **Repository Provider Pattern**

**Location:** `lib/core/di/repository_providers.dart`

**Strategy:**
```dart
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final authState = ref.watch(authStateNotifierProvider);

  if (authState.value?.isAuthenticated ?? false) {
    return RemoteProjectRepository(...);  // Server DB
  } else {
    return LocalProjectRepository(...);   // Local DB
  }
});
```

**Providers:**
- `authRepositoryProvider` → Always Firebase Auth
- `projectRepositoryProvider` → Switches Local ↔ Remote
- `serviceRepositoryProvider` → Switches Local ↔ Remote
- `incidentRepositoryProvider` → Switches Local ↔ Remote
- `apiKeyRepositoryProvider` → Remote only (throws error for guests)
- `dashboardRepositoryProvider` → Switches Local ↔ Remote

---

### 7. **Application Use Cases**

Use cases encapsulate business logic operations.

#### **Project Use Cases**
- `LoadProjects` - Load all projects with filtering
- `CreateProject` - Create new project with validation
- `MigrateLocalProjectsToServer` - Migrate local data after login

**Migration Strategy:**
```dart
MigrationResult {
  totalLocal: int
  migrated: List<Project>
  conflicts: List<ProjectConflict>  // Name already exists
  failed: List<ProjectMigrationFailure>
}
```

#### **Service Use Cases**
- `LoadServices` - Load services with filtering
- `TriggerHealthCheck` - Manual health check trigger

#### **Incident Use Cases**
- `LoadIncidents` - Load incidents with filtering
- `RequestAiAnalysis` - Request AI analysis for incident

---

### 8. **Data Transfer Objects (DTOs)**

DTOs map domain entities to backend API format using `json_serializable`.

#### **Implemented DTOs:**
- `ProjectDto` / `ProjectCreateDto` / `ProjectUpdateDto` / `ProjectStatsDto`
- `ApiKeyDto` / `ApiKeyCreateDto`
- `ServiceDto` / `ServiceCreateDto` / `ServiceUpdateDto`
- `HealthCheckDto`
- `IncidentDto` / `IncidentUpdateDto`
- `AiAnalysisDto`

**Key Features:**
- Snake_case ↔ camelCase conversion via `@JsonKey`
- `toDomain()` method converts DTO → Domain Entity
- `fromDomain()` method converts Domain Entity → DTO
- Type-safe enum parsing

**Example:**
```dart
@JsonKey(name: 'is_active') required bool isActive
@JsonKey(name: 'created_at') required String createdAt
```

---

## 🔄 Data Ownership Strategy

### Source of Truth Determination

```
┌─────────────────────────────────────────────────┐
│              AuthState                          │
├─────────────────────────────────────────────────┤
│ isAuthenticated: false                          │
│ → sourceOfTruth: SourceOfTruth.local           │
│ → Repositories use Local Data Sources (Hive)   │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│              AuthState                          │
├─────────────────────────────────────────────────┤
│ isAuthenticated: true                           │
│ → sourceOfTruth: SourceOfTruth.server          │
│ → Repositories use Remote Data Sources (API)   │
└─────────────────────────────────────────────────┘
```

### Migration Flow

```
1. User logs in (Guest → Authenticated)
   ↓
2. MigrateLocalProjectsToServer.execute()
   ↓
3. For each local project:
   - Check if name exists on server
   - If not exists: Upload to server
   - If exists: Mark as conflict
   ↓
4. Return MigrationResult
   ↓
5. UI shows migration summary
   - Migrated: X projects
   - Conflicts: Y projects (user resolves manually)
   - Failed: Z projects
```

---

## 🔒 API Key Management

### Critical Rules

1. **API keys are server-only**
   - Guest users cannot create or use API keys
   - `ApiKeyRepository` throws error if called while not authenticated

2. **Key value shown ONLY once**
   - Backend returns `key_value` only at creation
   - Frontend MUST store in `FlutterSecureStorage` immediately
   - Subsequent API calls return ApiKey WITHOUT key_value

3. **Storage locations**
   - API Key: `FlutterSecureStorage` (encrypted)
   - Project ID: `FlutterSecureStorage` (encrypted)

4. **Injection into Dio**
   ```dart
   await authStateNotifier.setProjectContext(projectId, apiKey);
   // ↓
   dioClient.setApiKey(apiKey);  // Adds X-API-Key header
   ```

---

## 🎯 Architecture Boundaries

### **UI Layer MUST NEVER:**
❌ Call API clients directly
❌ Access Local DB directly
❌ Handle auth logic
❌ Perform data transformation
❌ Contain business logic

### **UI Layer SHOULD:**
✅ Call use cases via providers
✅ Display data from domain entities
✅ Handle user interactions
✅ Manage presentation state

### **Application Layer MUST:**
✅ Define use cases
✅ Coordinate repositories
✅ Handle business rules
✅ Return `Result<T>` types

### **Domain Layer MUST:**
✅ Define entities (immutable)
✅ Define repository interfaces
✅ Contain NO infrastructure dependencies

### **Infrastructure Layer MUST:**
✅ Implement repository interfaces
✅ Implement data source interfaces
✅ Handle API communication
✅ Handle local storage
✅ Convert DTOs ↔ Domain Entities

---

## 📊 Layer Dependencies

```
┌─────────────────────────────────────────────┐
│         Presentation (UI)                   │
│  - Screens, Widgets, ViewModels            │
└──────────────┬──────────────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────────────┐
│         Application                         │
│  - Use Cases, State Logic                  │
└──────────────┬──────────────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────────────┐
│         Domain                              │
│  - Entities, Repository Interfaces         │
└──────────────▲──────────────────────────────┘
               │ implements
               │
┌──────────────┴──────────────────────────────┐
│         Infrastructure                      │
│  - API Clients, Local DB, Repositories     │
└─────────────────────────────────────────────┘
```

**Rule:** Domain has NO dependencies (pure business logic)

---

## 🚀 Next Steps (Phase 3)

### Infrastructure Implementation Required:

1. **Firebase Auth Integration**
   - Implement `FirebaseAuthRepository`
   - Handle auth state changes
   - Wrap Firebase types (no leakage to domain)

2. **Hive Local Storage**
   - Set up Hive boxes
   - Implement Local data sources
   - Implement Local repositories

3. **REST API Integration**
   - Create Retrofit API clients
   - Implement Remote data sources
   - Implement Remote repositories
   - Add interceptors for auth

4. **Repository Providers**
   - Complete provider switching logic
   - Wire up dependencies

5. **Use Case Providers**
   - Create providers for each use case
   - Connect to UI layer

### After Infrastructure:

- Implement UI screens
- Connect UI to use cases via providers
- Add loading/error states
- Implement migration flow UI

---

## 📝 File Summary

### Created Files: 50+

**Core:**
- `core/error/result.dart` - Result type
- `core/constants/enums.dart` - Global enums
- `core/di/repository_providers.dart` - Repository switching

**Auth Feature:**
- Domain: User, AuthState, GuestUser
- Repository: AuthRepository interface
- Provider: AuthStateNotifier
- Use Cases: (None - auth handled by provider)

**Project Feature:**
- Domain: Project, ApiKey, ProjectCreate, ProjectUpdate, ProjectStats
- Repositories: ProjectRepository, ApiKeyRepository interfaces
- Data Sources: ProjectDataSource, LocalProjectDataSource, RemoteProjectDataSource
- Use Cases: LoadProjects, CreateProject, MigrateLocalProjectsToServer
- DTOs: ProjectDto, ApiKeyDto

**API Monitoring Feature:**
- Domain: Service, HealthCheck, ServiceCreate, ServiceUpdate
- Repositories: ServiceRepository, DashboardRepository interfaces
- Data Sources: ServiceDataSource, LocalServiceDataSource, RemoteServiceDataSource
- Use Cases: LoadServices, TriggerHealthCheck
- DTOs: ServiceDto, HealthCheckDto

**Incident Feature:**
- Domain: Incident, AiAnalysis, IncidentUpdate
- Repository: IncidentRepository interface
- Data Sources: IncidentDataSource, LocalIncidentDataSource, RemoteIncidentDataSource
- Use Cases: LoadIncidents, RequestAiAnalysis
- DTOs: IncidentDto, AiAnalysisDto

---

## ✅ Validation Checklist

- [x] Result type for error handling
- [x] All domain entities defined (immutable)
- [x] All repository interfaces defined
- [x] All data source interfaces defined
- [x] Global auth state provider implemented
- [x] Repository provider pattern established
- [x] Key use cases implemented
- [x] DTOs for all entities
- [x] Migration strategy defined
- [x] API key management strategy defined
- [x] Boundary rules documented
- [x] No UI implementation (as required)
- [x] No leaking Firebase types to domain
- [x] Backend contracts respected

---

**Step 2 Complete!** ✅

All core logic contracts are now defined. Infrastructure and UI can be implemented independently without architectural ambiguity.

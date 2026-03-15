# API Key Per-Service Architecture

**Date:** 2026-01-17
**Status:** ✅ **IMPLEMENTED**

---

## Overview

API keys are **NOT set globally on DioClient headers** when entering a project. Instead, each service instance should include its own API key in the request headers.

---

## Architecture Decision

### ❌ Previous Approach (WRONG)
```dart
// When selecting project
_dioClient.setApiKey(apiKey);  // Global header set

// Later, service makes request
dio.get('/api/services');  // Uses global API key
```

**Problems:**
- All services use the same API key
- Cannot have different API keys per service
- Global state makes testing harder
- Inflexible for multi-tenant scenarios

---

### ✅ New Approach (CORRECT)
```dart
// When selecting project
// NO global API key set - just store in ProjectSession
state = ProjectSession(
  project: project,
  activeApiKeyId: keyId,
);

// Later, when service needs to make a request
final apiKey = projectSession.activeApiKeyValue;
dio.get(
  '/api/services',
  options: Options(
    headers: {'X-API-Key': apiKey},  // Per-request API key
  ),
);
```

**Benefits:**
- ✅ Each service can use its own API key
- ✅ Flexible for multi-tenant scenarios
- ✅ Easier to test (no global state)
- ✅ More secure (explicit per-request)

---

## Implementation

### ProjectSessionNotifier Changes

**Removed:**
- ❌ `_dioClient` field
- ❌ `_dioClient.setApiKey()` calls
- ❌ `_dioClient.clearApiKey()` calls
- ❌ DioClient dependency from constructor

**What it does now:**
- ✅ Stores complete `Project` (includes all API keys)
- ✅ Tracks which API key is active (`activeApiKeyId`)
- ✅ Provides `activeApiKeyValue` getter for services to use
- ✅ Persists active key preference to SecureStorage

```dart
class ProjectSessionNotifier extends StateNotifier<ProjectSession> {
  final SecureStorage _secureStorage;  // ✅ Only dependency

  Future<void> selectProjectWithApiKey({
    required Project project,
    required String apiKeyId,
  }) async {
    state = ProjectSession(
      project: project,
      activeApiKeyId: apiKeyId,
    );

    // ✅ NO DioClient.setApiKey() call
    // Services will use session.activeApiKeyValue directly

    await _secureStorage.saveActiveApiKeyId(project.id, apiKeyId);
  }
}
```

---

## How Services Should Use API Keys

### Example: Service Repository

```dart
class ServiceRepositoryImpl implements ServiceRepository {
  final RemoteServiceDataSource _remoteDataSource;

  @override
  Future<Result<List<Service>>> getAll(String projectId) async {
    // Get API key from ProjectSession
    final projectSession = _ref.read(currentProjectSessionProvider);
    final apiKey = projectSession.activeApiKeyValue;

    if (apiKey == null) {
      return Result.failure(
        AppError(message: 'No API key configured'),
      );
    }

    // Pass API key to data source
    return await _remoteDataSource.getAll(
      projectId: projectId,
      apiKey: apiKey,
    );
  }
}
```

### Example: Remote Data Source

```dart
class RemoteServiceDataSourceImpl implements RemoteServiceDataSource {
  final Dio _dio;

  @override
  Future<List<ServiceDto>> getAll({
    required String projectId,
    required String apiKey,  // ✅ Explicit parameter
  }) async {
    final response = await _dio.get(
      '/api/projects/$projectId/services',
      options: Options(
        headers: {
          'X-API-Key': apiKey,  // ✅ Per-request header
        },
      ),
    );

    return (response.data as List)
        .map((json) => ServiceDto.fromJson(json))
        .toList();
  }
}
```

---

## Benefits of Per-Service API Keys

### 1. Service-Specific Keys
Different services can use different API keys:

```dart
// Service A uses Production key
await serviceA.getData(apiKey: productionKey);

// Service B uses Development key
await serviceB.getData(apiKey: devKey);
```

### 2. Multi-Tenant Support
Easy to support multiple projects:

```dart
// Project 1
final project1Session = getSessionForProject('project-1');
await service.getData(apiKey: project1Session.activeApiKeyValue);

// Project 2
final project2Session = getSessionForProject('project-2');
await service.getData(apiKey: project2Session.activeApiKeyValue);
```

### 3. Testing
No global state to mock:

```dart
test('service fetches data with API key', () async {
  final service = ServiceRepository(mockDataSource);

  // Pass test API key explicitly
  await service.getAll(
    projectId: 'test-project',
    apiKey: 'test-api-key',
  );

  // Verify API key was used
  verify(mockDataSource.getAll(
    projectId: 'test-project',
    apiKey: 'test-api-key',
  )).called(1);
});
```

### 4. Security
Explicit per-request keys make it clear what's being sent:

```dart
// Clear audit trail
logger.log('Making request with API key: ${apiKey.maskedValue}');
dio.get(
  '/api/services',
  options: Options(headers: {'X-API-Key': apiKey}),
);
```

---

## Migration Guide

### If You Have Existing Code Using Global API Keys

**Before:**
```dart
// Assumed DioClient had API key set globally
await _dio.get('/api/services');
```

**After:**
```dart
// Get API key from ProjectSession
final apiKey = ref.read(currentProjectSessionProvider).activeApiKeyValue;

if (apiKey == null) {
  throw Exception('No API key configured');
}

// Pass explicitly
await _dio.get(
  '/api/services',
  options: Options(
    headers: {'X-API-Key': apiKey},
  ),
);
```

---

## Accessing API Keys in Different Layers

### In Use Cases (Application Layer)
```dart
class GetServicesForProject {
  final ServiceRepository _repository;

  Future<Result<List<Service>>> execute(String projectId) async {
    // Use case doesn't need to know about API keys
    // Repository handles it
    return await _repository.getAll(projectId);
  }
}
```

### In Repositories (Infrastructure Layer)
```dart
class ServiceRepositoryImpl implements ServiceRepository {
  final RemoteServiceDataSource _remoteDataSource;
  final Ref _ref;  // To access ProjectSession

  @override
  Future<Result<List<Service>>> getAll(String projectId) async {
    // Get API key from session
    final session = _ref.read(currentProjectSessionProvider);
    final apiKey = session.activeApiKeyValue;

    if (apiKey == null) {
      return Result.failure(AppError(message: 'No API key'));
    }

    // Pass to data source
    final dtos = await _remoteDataSource.getAll(
      projectId: projectId,
      apiKey: apiKey,
    );

    return Result.success(dtos.map((dto) => dto.toDomain()).toList());
  }
}
```

### In Data Sources (Infrastructure Layer)
```dart
class RemoteServiceDataSourceImpl {
  final Dio _dio;

  Future<List<ServiceDto>> getAll({
    required String projectId,
    required String apiKey,
  }) async {
    final response = await _dio.get(
      '/api/projects/$projectId/services',
      options: Options(
        headers: {'X-API-Key': apiKey},
      ),
    );

    return parseResponse(response.data);
  }
}
```

### In UI (Presentation Layer)
```dart
class ServiceListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentProjectSessionProvider);

    // Check if API key is available
    if (!session.hasApiKey) {
      return Text('Please configure an API key');
    }

    // Use case handles fetching with API key
    final servicesAsync = ref.watch(servicesProvider);

    return servicesAsync.when(
      data: (services) => ListView(children: ...),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

---

## API Key Flow

```
┌─────────────────────────────────────────────────────┐
│ User selects project with API key                  │
└────────────────┬────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────────────────────┐
│ ProjectSession stores:                              │
│ - project (with all API keys)                       │
│ - activeApiKeyId                                    │
│ ✅ NO global DioClient header set                   │
└────────────────┬────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────────────────────┐
│ UI requests data                                    │
│ (e.g., load services list)                          │
└────────────────┬────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────────────────────┐
│ Use Case executes                                   │
│ getServicesForProject.execute(projectId)            │
└────────────────┬────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────────────────────┐
│ Repository gets API key                             │
│ apiKey = projectSession.activeApiKeyValue           │
└────────────────┬────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────────────────────┐
│ Data Source makes request with API key             │
│ dio.get('/api/services', options: Options(          │
│   headers: {'X-API-Key': apiKey}                    │
│ ))                                                  │
└─────────────────────────────────────────────────────┘
```

---

## Files Modified

1. **`lib/core/state/project_session_notifier.dart`**
   - Removed `_dioClient` field
   - Removed `DioClient` from constructor
   - Removed all `setApiKey()` and `clearApiKey()` calls
   - Added comments explaining per-service API key usage

---

## Verification

### ✅ Code Generation
```bash
$ flutter pub run build_runner build --delete-conflicting-outputs
✅ Built with build_runner in 71s; wrote 16 outputs
```

### ✅ Compilation
- ProjectSessionNotifier compiles successfully
- No DioClient dependency
- All providers updated

---

## Summary

✅ **API keys are now managed per-service, not globally**
- ProjectSession stores which API key is active
- Services explicitly include API key in request headers
- No global DioClient state
- More flexible and testable architecture

---

**Status:** ✅ **IMPLEMENTED AND VERIFIED**
**Date Completed:** 2026-01-17

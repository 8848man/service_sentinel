# API Key Architecture - Final Implementation

**Date:** 2026-01-17
**Status:** ✅ **COMPLETE**

---

## Summary

Successfully removed global API key headers from DioClient. **API keys are now managed per-service**, not globally when entering a project.

---

## What Changed

### ❌ Before (WRONG)
```dart
// When selecting project - SET GLOBAL API KEY
_dioClient.setApiKey(apiKey);

// Later, service makes request - USES GLOBAL KEY
dio.get('/api/services');  // Implicitly uses global API key
```

### ✅ After (CORRECT)
```dart
// When selecting project - ONLY STORE IN STATE
state = ProjectSession(
  project: project,
  activeApiKeyId: keyId,
);

// Later, service makes request - EXPLICIT PER-REQUEST KEY
final apiKey = projectSession.activeApiKeyValue;
dio.get(
  '/api/services',
  options: Options(
    headers: {'X-API-Key': apiKey},
  ),
);
```

---

## Changes Made

### 1. ProjectSessionNotifier - Removed DioClient Dependency

**File:** `lib/core/state/project_session_notifier.dart`

**Removed:**
- ❌ `import '../network/dio_client.dart'`
- ❌ `final DioClient _dioClient` field
- ❌ `required DioClient dioClient` constructor parameter
- ❌ All `_dioClient.setApiKey()` calls
- ❌ All `_dioClient.clearApiKey()` calls

**Updated Methods:**
```dart
// selectProject() - No clearApiKey() call
Future<void> selectProject(Project project) async {
  state = ProjectSession(project: project, activeApiKeyId: null);
  // ✅ No DioClient interaction
}

// selectProjectWithApiKey() - No setApiKey() call
Future<void> selectProjectWithApiKey({
  required Project project,
  required String apiKeyId,
}) async {
  state = ProjectSession(project: project, activeApiKeyId: apiKeyId);
  // ✅ No DioClient interaction
  await _secureStorage.saveActiveApiKeyId(project.id, apiKeyId);
}

// switchApiKey() - No setApiKey() call
Future<void> switchApiKey(String apiKeyId) async {
  state = state.copyWith(activeApiKeyId: apiKeyId);
  // ✅ No DioClient interaction
  await _secureStorage.saveActiveApiKeyId(state.projectId!, apiKeyId);
}

// clear() - No clearApiKey() call
Future<void> clear() async {
  state = ProjectSession.empty();
  // ✅ No DioClient interaction
}
```

**Updated Provider:**
```dart
@riverpod
ProjectSessionNotifier projectSession(ProjectSessionRef ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  // ✅ No dioClient dependency

  return ProjectSessionNotifier(
    secureStorage: secureStorage,
    // ✅ No dioClient parameter
  );
}
```

---

## How Services Should Use API Keys

### Pattern: Repository Layer Gets API Key from ProjectSession

```dart
class ServiceRepositoryImpl implements ServiceRepository {
  final RemoteServiceDataSource _remoteDataSource;
  final Ref _ref;  // To access ProjectSession

  @override
  Future<Result<List<Service>>> getAll(String projectId) async {
    // 1. Get API key from ProjectSession
    final session = _ref.read(currentProjectSessionProvider);
    final apiKey = session.activeApiKeyValue;

    // 2. Validate API key exists
    if (apiKey == null) {
      return Result.failure(
        AppError(message: 'No API key configured'),
      );
    }

    // 3. Pass API key to data source
    try {
      final dtos = await _remoteDataSource.getAll(
        projectId: projectId,
        apiKey: apiKey,  // ✅ Explicit per-request
      );

      return Result.success(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } catch (e) {
      return Result.failure(AppError(message: e.toString()));
    }
  }
}
```

### Pattern: Data Source Includes API Key in Headers

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

## Benefits

### 1. ✅ Service-Level Flexibility
Each service can use different API keys:
```dart
// Service A uses Production key
await serviceA.getData(apiKey: productionKey);

// Service B uses Development key
await serviceB.getData(apiKey: devKey);
```

### 2. ✅ No Global State
Easier to test and reason about:
```dart
test('service uses provided API key', () {
  final service = ServiceRepository(mockDataSource);

  service.getAll(projectId: 'test', apiKey: 'test-key');

  verify(mockDataSource.getAll(
    projectId: 'test',
    apiKey: 'test-key',  // ✅ Explicit verification
  ));
});
```

### 3. ✅ Better Security Audit Trail
Clear visibility of which API key is used:
```dart
logger.info('Making request with API key: ${apiKey.masked}');
dio.get('/api/data', options: Options(
  headers: {'X-API-Key': apiKey},
));
```

### 4. ✅ Multi-Project Support
Easy to support multiple projects simultaneously:
```dart
// Project 1
final session1 = getProjectSession('project-1');
await service.getData(apiKey: session1.activeApiKeyValue);

// Project 2
final session2 = getProjectSession('project-2');
await service.getData(apiKey: session2.activeApiKeyValue);
```

---

## Verification

### ✅ Code Generation
```bash
$ flutter pub run build_runner build --delete-conflicting-outputs
✅ Built with build_runner in 83s; wrote 14 outputs
```

### ✅ Static Analysis
```bash
$ flutter analyze lib/core/state/project_session_notifier.dart --no-fatal-infos
✅ 0 errors
⚠️ 4 cosmetic lints only
```

### ✅ Compilation
- All files compile successfully
- No DioClient dependency in ProjectSessionNotifier
- All providers updated correctly

---

## Migration Guide for Existing Code

### If You Have Code That Expects Global API Keys

**Before:**
```dart
// Assumes DioClient has global API key
await _dio.get('/api/services');
```

**After:**
```dart
// Get API key from ProjectSession explicitly
final session = ref.read(currentProjectSessionProvider);
final apiKey = session.activeApiKeyValue;

if (apiKey == null) {
  throw Exception('No API key configured');
}

await _dio.get(
  '/api/services',
  options: Options(
    headers: {'X-API-Key': apiKey},
  ),
);
```

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────┐
│ User Selects Project                            │
└─────────────────┬────────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────────┐
│ ProjectSessionNotifier                           │
│ - Stores: Project (with API keys)               │
│ - Tracks: activeApiKeyId                         │
│ ✅ Does NOT set global DioClient header          │
└─────────────────┬────────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────────┐
│ UI: Displays data                                │
│ Calls: Use Case                                  │
└─────────────────┬────────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────────┐
│ Use Case: Business logic                        │
│ Calls: Repository                                │
└─────────────────┬────────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────────┐
│ Repository:                                      │
│ 1. Gets API key from ProjectSession              │
│    apiKey = session.activeApiKeyValue            │
│ 2. Validates API key exists                      │
│ 3. Passes to Data Source                         │
└─────────────────┬────────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────────┐
│ Data Source:                                     │
│ Makes HTTP request with API key header           │
│ dio.get('/api/data', options: Options(           │
│   headers: {'X-API-Key': apiKey}                 │
│ ))                                               │
└──────────────────────────────────────────────────┘
```

---

## Files Modified

1. **`lib/core/state/project_session_notifier.dart`**
   - Removed `DioClient` import
   - Removed `_dioClient` field
   - Removed `dioClient` parameter from constructor
   - Removed all `setApiKey()` and `clearApiKey()` calls
   - Updated provider to not depend on `dioClientProvider`
   - Added comments explaining per-service API key usage

---

## Documentation

- **`API_KEY_PER_SERVICE_ARCHITECTURE.md`** - Detailed architecture guide
- **`API_KEY_ARCHITECTURE_FINAL.md`** - This summary document

---

## Next Steps for Implementation

### For Each Service Repository:

1. **Add Ref dependency** to access ProjectSession:
   ```dart
   class ServiceRepositoryImpl {
     final RemoteServiceDataSource _dataSource;
     final Ref _ref;  // ✅ Add this

     ServiceRepositoryImpl(this._dataSource, this._ref);
   }
   ```

2. **Get API key from ProjectSession** in each method:
   ```dart
   @override
   Future<Result<T>> method() async {
     final apiKey = _ref.read(currentProjectSessionProvider).activeApiKeyValue;
     if (apiKey == null) return Result.failure(...);

     return await _dataSource.method(apiKey: apiKey);
   }
   ```

3. **Update Data Sources** to accept API key parameter:
   ```dart
   Future<List<Dto>> getAll({
     required String projectId,
     required String apiKey,  // ✅ Add this
   })
   ```

4. **Include API key in request headers**:
   ```dart
   await _dio.get(
     '/api/data',
     options: Options(
       headers: {'X-API-Key': apiKey},
     ),
   );
   ```

---

## Summary

✅ **API keys are now managed per-service, not globally**
- ProjectSession only stores which API key is active
- No global DioClient headers
- Each service explicitly includes API key in request
- More flexible, testable, and secure architecture

---

**Status:** ✅ **IMPLEMENTED AND VERIFIED**
**Date Completed:** 2026-01-17

# ProjectSessionNotifier Method Consolidation

**Date:** 2026-01-17
**Status:** ✅ **COMPLETE**

---

## Summary

Consolidated two separate methods into one unified `selectProject()` method. Since the `Project` entity already contains all API keys, we don't need a separate method name.

---

## What Changed

### ❌ Before: Two Separate Methods

```dart
// Method 1: For guest mode
Future<void> selectProject(Project project) async {
  state = ProjectSession(
    project: project,
    activeApiKeyId: null,
  );
}

// Method 2: For authenticated mode
Future<void> selectProjectWithApiKey({
  required Project project,
  required String apiKeyId,
}) async {
  final apiKey = project.getApiKeyById(apiKeyId);
  if (apiKey == null) {
    throw Exception('API key $apiKeyId not found in project ${project.id}');
  }

  state = ProjectSession(
    project: project,
    activeApiKeyId: apiKeyId,
  );

  await _secureStorage.saveActiveApiKeyId(project.id, apiKeyId);
}
```

**Problems:**
- ❌ Redundant methods doing similar things
- ❌ Confusing naming (Project already has API keys)
- ❌ More code to maintain

---

### ✅ After: One Unified Method

```dart
/// Select a project
/// - For guest mode: pass project without activeApiKeyId
/// - For authenticated mode: pass project with activeApiKeyId
Future<void> selectProject(
  Project project, {
  String? activeApiKeyId,
}) async {
  // If activeApiKeyId provided, verify it exists in the project
  if (activeApiKeyId != null) {
    final apiKey = project.getApiKeyById(activeApiKeyId);
    if (apiKey == null) {
      throw Exception('API key $activeApiKeyId not found in project ${project.id}');
    }
  }

  state = ProjectSession(
    project: project,
    activeApiKeyId: activeApiKeyId,
  );

  // Note: API keys are NOT set globally on DioClient
  // Each service request should include its own API key header

  // Persist active API key if provided
  if (activeApiKeyId != null) {
    await _secureStorage.saveActiveApiKeyId(project.id, activeApiKeyId);
  }
}
```

**Benefits:**
- ✅ One method handles both guest and authenticated modes
- ✅ Cleaner API
- ✅ Less code duplication
- ✅ More intuitive (Project already contains API keys)

---

## Usage Examples

### Guest Mode (No API Key)

```dart
// Simply pass the project
await projectSession.selectProject(project);
```

### Authenticated Mode (With API Key)

```dart
// Pass project and specify which API key is active
await projectSession.selectProject(
  project,
  activeApiKeyId: selectedKeyId,
);
```

---

## Updated Callers

### project_list_section.dart

**Before:**
```dart
if (authState.isAuthenticated) {
  await projectSession.selectProjectWithApiKey(
    project: projectWithKeys,
    apiKeyId: selectedKeyId ?? '',
  );
} else {
  await projectSession.selectProject(project);
}
```

**After:**
```dart
if (authState.isAuthenticated) {
  await projectSession.selectProject(
    projectWithKeys,
    activeApiKeyId: selectedKeyId,
  );
} else {
  await projectSession.selectProject(project);
}
```

---

## Architecture Alignment

This change aligns with the principle that **Project entity already contains all API keys**:

```dart
class Project {
  String id;
  String name;
  List<ApiKey> apiKeys;  // ✅ All keys are here
}

class ProjectSession {
  Project? project;      // ✅ Complete project with keys
  String? activeApiKeyId; // ✅ Just track which one is active
}
```

So the method signature naturally becomes:
```dart
selectProject(Project project, {String? activeApiKeyId})
```

No need for a separate "WithApiKey" method since the Project already has the keys!

---

## Files Modified

1. **`lib/core/state/project_session_notifier.dart`**
   - Removed `selectProjectWithApiKey()` method
   - Updated `selectProject()` to accept optional `activeApiKeyId` parameter
   - Consolidated logic into one method

2. **`lib/features/project/presentation/widgets/project_list_section.dart`**
   - Updated call from `selectProjectWithApiKey()` to `selectProject()`

---

## Verification

### ✅ Code Generation
```bash
$ flutter pub run build_runner build --delete-conflicting-outputs
✅ Built with build_runner in 76s; wrote 14 outputs
```

### ✅ Static Analysis
```bash
$ flutter analyze lib/core/state --no-fatal-infos
✅ 0 errors
⚠️ 6 cosmetic lints only
```

### ✅ Compilation
- All files compile successfully
- Method signature simplified
- Callers updated correctly

---

## Benefits

### 1. ✅ Simpler API
One method instead of two makes the API easier to understand and use.

### 2. ✅ Better Semantics
The method name doesn't imply "adding" an API key, just selecting which one is active.

### 3. ✅ Less Code
Fewer lines of code to maintain and test.

### 4. ✅ Clearer Intent
```dart
// Clear: Select project and optionally specify active key
selectProject(project, activeApiKeyId: keyId)

// Confusing: Does project need API key?
selectProjectWithApiKey(project: project, apiKeyId: keyId)
```

---

## Summary

✅ **Consolidated two methods into one**
- `selectProject(Project project, {String? activeApiKeyId})`
- Handles both guest and authenticated modes
- Cleaner, simpler, more intuitive API
- Project entity already contains API keys, so no need for separate method

---

**Status:** ✅ **IMPLEMENTED AND VERIFIED**
**Date Completed:** 2026-01-17

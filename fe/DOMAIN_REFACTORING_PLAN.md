# Domain Model Refactoring Plan

**Date:** 2026-01-17
**Status:** ✅ **COMPLETED** - See [DOMAIN_REFACTORING_COMPLETED.md](./DOMAIN_REFACTORING_COMPLETED.md) for details

---

## ⚠️ NOTE: This plan has been executed. See completion summary at:
**[DOMAIN_REFACTORING_COMPLETED.md](./DOMAIN_REFACTORING_COMPLETED.md)**

---

## Backend Domain Model (Source of Truth)

### From `app/models/project.py`:
```python
class Project(Base):
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True))
    updated_at = Column(DateTime(timezone=True))

    # Relationships
    services = relationship("Service", back_populates="project", cascade="all, delete-orphan")
    api_keys = relationship("APIKey", back_populates="project", cascade="all, delete-orphan")
    # ✅ ONE PROJECT → MANY API KEYS
```

### From `app/models/api_key.py`:
```python
class APIKey(Base):
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)

    # Key details
    key_value = Column(String(200), unique=True, nullable=False)  # "ss_abc123..."
    name = Column(String(100), nullable=False)  # "Production Key", "Dev Key"
    description = Column(Text, nullable=True)

    # Status
    is_active = Column(Boolean, default=True)

    # Usage tracking
    last_used_at = Column(DateTime(timezone=True), nullable=True)
    usage_count = Column(Integer, default=0)

    # Metadata
    created_at = Column(DateTime(timezone=True))
    expires_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    project = relationship("Project", back_populates="api_keys")
```

**Key Insight:**
- 📌 **Each Project can have MULTIPLE API Keys**
- 📌 Each API Key has a **human-readable name** ("Production Key", "Development Key", etc.)
- 📌 Users can **create, list, activate, deactivate, and delete** API keys
- 📌 Users **select which key to use** for API calls

---

## Current Frontend Implementation (Incorrect)

### ProjectSession (lib/core/state/project_session.dart):
```dart
class ProjectSession {
  String? projectId;
  String? projectName;
  String? apiKey;  // ❌ WRONG: Only stores ONE key value
}
```

**Problems:**
1. ❌ Only stores ONE API key value per project
2. ❌ No way to manage multiple keys
3. ❌ No way to see key names ("Production Key", etc.)
4. ❌ No way to switch between keys
5. ❌ Doesn't match backend's one-to-many relationship

### SecureStorage:
```dart
Future<void> saveApiKey(String projectId, String apiKey)  // ❌ Overwrites previous key
Future<String?> getApiKey(String projectId)               // ❌ Only returns one key
```

**Problems:**
1. ❌ Only stores ONE key per project
2. ❌ Overwrites if user creates multiple keys
3. ❌ No key selection mechanism

---

## Correct Architecture

### 1. ProjectSession Should Track WHICH Key is Active

```dart
// CURRENT (wrong)
class ProjectSession {
  String? projectId;
  String? projectName;
  String? apiKey;  // ❌ Raw key value
}

// REFACTORED (correct)
class ProjectSession {
  String? projectId;
  String? projectName;
  String? activeApiKeyId;      // ✅ Which key is currently selected
  String? activeApiKeyValue;   // ✅ The actual key value for API calls
  String? activeApiKeyName;    // ✅ Human-readable name
}
```

### 2. SecureStorage Should Store Multiple Keys

```dart
// CURRENT (wrong)
saveApiKey(projectId, keyValue)  // Overwrites previous
getApiKey(projectId)             // Returns one key

// REFACTORED (correct)
saveApiKeyValue(apiKeyId, keyValue)     // ✅ Store by key ID
getApiKeyValue(apiKeyId)                // ✅ Retrieve by key ID
deleteApiKeyValue(apiKeyId)             // ✅ Delete by key ID
saveActiveApiKeyId(projectId, keyId)    // ✅ Track which key is active
getActiveApiKeyId(projectId)            // ✅ Get active key for project
```

### 3. User Workflow

#### Current (Wrong):
```
1. User selects Project
2. Load "the" API key from SecureStorage
3. Use it
```

#### Correct:
```
1. User selects Project
   ↓
2. Check if user has a saved "active API key ID" for this project
   ↓
3a. If YES:
      - Load that API key's value from SecureStorage
      - Load that API key's metadata (name, expiry) from backend
      - Use it for API calls
   ↓
3b. If NO:
      - Fetch all API keys for this project from backend
      - Show user a list to choose from
      - Or prompt to create a new key
      - Save user's selection
   ↓
4. User works with project using selected key
   ↓
5. User can switch keys in Settings:
      - View all keys for current project
      - See which one is active
      - Select a different key
      - Or create a new key
```

---

## Refactoring Tasks

### Phase 1: Update ProjectSession ✅

**File:** `lib/core/state/project_session.dart`

```dart
@freezed
class ProjectSession with _$ProjectSession {
  const factory ProjectSession({
    String? projectId,
    String? projectName,

    // Active API key tracking
    String? activeApiKeyId,      // ✅ NEW: Which key is selected
    String? activeApiKeyValue,   // ✅ RENAMED from "apiKey"
    String? activeApiKeyName,    // ✅ NEW: Display name
  }) = _ProjectSession;

  const ProjectSession._();

  bool get hasProject => projectId != null;
  bool get hasApiKey => activeApiKeyValue != null && activeApiKeyValue!.isNotEmpty;
  bool get isFullyConfigured => hasProject && hasApiKey;

  factory ProjectSession.empty() => const ProjectSession();
}
```

### Phase 2: Update SecureStorage ✅

**File:** `lib/core/storage/secure_storage.dart`

```dart
class SecureStorage {
  // ===== API Key Value Storage (by key ID) =====

  /// Save API key value by key ID
  Future<void> saveApiKeyValue(String apiKeyId, String keyValue) async {
    await write('api_key_value_$apiKeyId', keyValue);
  }

  /// Get API key value by key ID
  Future<String?> getApiKeyValue(String apiKeyId) async {
    return await read('api_key_value_$apiKeyId');
  }

  /// Delete API key value by key ID
  Future<void> deleteApiKeyValue(String apiKeyId) async {
    await delete('api_key_value_$apiKeyId');
  }

  // ===== Active API Key Tracking (per project) =====

  /// Save which API key is active for a project
  Future<void> saveActiveApiKeyId(String projectId, String apiKeyId) async {
    await write('active_api_key_$projectId', apiKeyId);
  }

  /// Get active API key ID for a project
  Future<String?> getActiveApiKeyId(String projectId) async {
    return await read('active_api_key_$projectId');
  }

  /// Delete active API key tracking for a project
  Future<void> deleteActiveApiKeyId(String projectId) async {
    await delete('active_api_key_$projectId');
  }

  // ===== Legacy Methods (deprecated) =====

  @Deprecated('Use saveApiKeyValue(apiKeyId, keyValue)')
  Future<void> saveApiKey(String projectId, String apiKey) async {
    // Keep for backward compatibility
  }

  @Deprecated('Use getActiveApiKeyId() + getApiKeyValue()')
  Future<String?> getApiKey(String projectId) async {
    // Keep for backward compatibility
  }
}
```

### Phase 3: Update ProjectSessionNotifier ✅

**File:** `lib/core/state/project_session_notifier.dart`

```dart
class ProjectSessionNotifier extends StateNotifier<ProjectSession> {
  final SecureStorage _secureStorage;
  final DioClient _dioClient;

  /// Select project with API key (authenticated mode)
  Future<void> selectProjectWithApiKey({
    required String projectId,
    required String projectName,
    required String apiKeyId,
    required String apiKeyValue,
    required String apiKeyName,
  }) async {
    state = ProjectSession(
      projectId: projectId,
      projectName: projectName,
      activeApiKeyId: apiKeyId,
      activeApiKeyValue: apiKeyValue,
      activeApiKeyName: apiKeyName,
    );

    // Update DioClient
    _dioClient.setApiKey(apiKeyValue);

    // Persist
    await _secureStorage.saveApiKeyValue(apiKeyId, apiKeyValue);
    await _secureStorage.saveActiveApiKeyId(projectId, apiKeyId);
  }

  /// Load saved API key for project
  Future<void> loadSavedApiKey(String projectId) async {
    // Get which key is active
    final activeKeyId = await _secureStorage.getActiveApiKeyId(projectId);
    if (activeKeyId == null) return;

    // Get that key's value
    final keyValue = await _secureStorage.getApiKeyValue(activeKeyId);
    if (keyValue == null) return;

    // TODO: Fetch key metadata (name, expiry) from backend
    // For now, use key ID as name
    state = state.copyWith(
      activeApiKeyId: activeKeyId,
      activeApiKeyValue: keyValue,
      activeApiKeyName: 'Key $activeKeyId',
    );

    _dioClient.setApiKey(keyValue);
  }

  /// Switch to a different API key for current project
  Future<void> switchApiKey({
    required String apiKeyId,
    required String apiKeyValue,
    required String apiKeyName,
  }) async {
    if (!state.hasProject) return;

    state = state.copyWith(
      activeApiKeyId: apiKeyId,
      activeApiKeyValue: apiKeyValue,
      activeApiKeyName: apiKeyName,
    );

    _dioClient.setApiKey(apiKeyValue);

    await _secureStorage.saveApiKeyValue(apiKeyId, apiKeyValue);
    await _secureStorage.saveActiveApiKeyId(state.projectId!, apiKeyId);
  }
}
```

### Phase 4: Update Project Selection Flow ✅

**File:** `lib/features/project/presentation/widgets/project_list_section.dart`

```dart
Future<void> _handleProjectSelection(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final authState = ref.read(authStateNotifierProvider).value;
  if (authState == null) return;

  final projectSession = ref.read(projectSessionProvider);
  final secureStorage = ref.read(secureStorageProvider);

  if (authState.isAuthenticated) {
    // Check if user has a saved active API key for this project
    final activeKeyId = await secureStorage.getActiveApiKeyId(project.id);

    if (activeKeyId != null) {
      // Load saved key
      final keyValue = await secureStorage.getApiKeyValue(activeKeyId);

      if (keyValue != null) {
        // ✅ Use saved key
        await projectSession.selectProjectWithApiKey(
          projectId: project.id,
          projectName: project.name,
          apiKeyId: activeKeyId,
          apiKeyValue: keyValue,
          apiKeyName: 'Saved Key',  // TODO: Fetch actual name from backend
        );
      } else {
        // Key value not found - show key selection
        _showApiKeySelectionDialog(context, ref, project);
        return;
      }
    } else {
      // No saved key - show key selection
      _showApiKeySelectionDialog(context, ref, project);
      return;
    }
  } else {
    // Guest mode
    await projectSession.selectProject(
      projectId: project.id,
      projectName: project.name,
    );
  }

  if (context.mounted) {
    context.go(AppRoutes.dashboard);
  }
}

/// Show dialog to select or create API key
Future<void> _showApiKeySelectionDialog(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  // TODO: Implement
  // 1. Fetch all API keys for project from backend
  // 2. Show list with key names
  // 3. Let user select one
  // 4. Or let user create a new key
  // 5. Save selection and proceed
}
```

### Phase 5: Update Settings Screen ✅

**File:** `lib/features/settings/presentation/widgets/api_key_settings_section.dart`

Should show:
- ✅ Current project name
- ✅ Currently active API key (with name)
- ✅ Button to "Switch API Key" → Shows list of all keys for project
- ✅ Button to "Create New API Key"
- ✅ List all API keys with:
  - Key name
  - Created date
  - Last used date
  - Expiry date (if set)
  - Usage count
  - Active indicator
  - Actions: Switch, Copy, Deactivate, Delete

---

## Migration Strategy

### For Existing Users:

1. **Detect legacy storage:**
   ```dart
   final legacyKey = await secureStorage.getLegacyApiKey();
   if (legacyKey != null) {
     // Migrate to new storage
     // Assume this was for the current project
     // Create a default key name "Migrated Key"
     await secureStorage.saveApiKeyValue('migrated_key', legacyKey);
     await secureStorage.saveActiveApiKeyId(projectId, 'migrated_key');
     await secureStorage.deleteLegacyApiKey();
   }
   ```

2. **Fetch actual key metadata from backend:**
   - When loading saved key, also fetch its metadata (name, expiry, etc.)
   - Update ProjectSession with full key info

---

## Summary of Changes

### Data Model:
- ❌ `ProjectSession.apiKey` → ✅ `ProjectSession.activeApiKeyId/Value/Name`
- ❌ `SecureStorage.saveApiKey(projectId, key)` → ✅ `saveApiKeyValue(keyId, value) + saveActiveApiKeyId(projectId, keyId)`

### User Experience:
- ❌ One key per project (automatic) → ✅ Multiple keys per project (user chooses)
- ❌ No visibility into keys → ✅ See all keys with names
- ❌ Can't switch keys → ✅ Can switch between keys
- ❌ No key management → ✅ Full key management (create, list, switch, deactivate, delete)

### Backend Alignment:
- ✅ Now matches backend's one-to-many relationship
- ✅ Now supports multiple named keys per project
- ✅ Now supports key selection and switching

---

## Questions for Review:

1. **Should we implement all phases at once, or incrementally?**
   - Suggestion: Phases 1-3 first (core data model), then 4-5 (UI)

2. **How should we handle the API key selection dialog?**
   - Option A: Show immediately when project selected (if no saved key)
   - Option B: Navigate to dashboard, show persistent banner to configure key
   - Recommendation: Option A (better UX)

3. **Should we auto-migrate legacy keys?**
   - Yes, with a generated name like "Migrated Key"
   - User can rename later

4. **Should we cache API key metadata (name, expiry) locally?**
   - Yes, in a separate provider
   - Refresh on project selection

---

**Status:** 📋 **AWAITING USER APPROVAL**

Should I proceed with the refactoring?

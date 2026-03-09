import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error/app_error.dart';

/// Secure storage for sensitive data (API keys, tokens)
/// Supports project-scoped API key storage
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  const SecureStorage();

  /// Storage keys
  static const String _legacyApiKeyKey = 'api_key';
  static const String _projectIdKey = 'project_id';
  static const String _apiKeyPrefix =
      'api_key_project_'; // Legacy: one key per project
  static const String _apiKeyValuePrefix =
      'api_key_value_'; // New: multiple keys by ID
  static const String _activeApiKeyPrefix =
      'active_api_key_'; // Track active key per project
  static const String _deviceTokenKey = 'device_token';

  /// Write secure data
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageError(
        message: 'Failed to write secure data',
        originalError: e,
      );
    }
  }

  /// Read secure data
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageError(
        message: 'Failed to read secure data',
        originalError: e,
      );
    }
  }

  /// Delete secure data
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageError(
        message: 'Failed to delete secure data',
        originalError: e,
      );
    }
  }

  /// Clear all secure data
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageError(
        message: 'Failed to clear secure storage',
        originalError: e,
      );
    }
  }

  // ===== API Key Value Storage (by key ID) =====
  // Projects can have multiple API keys, each stored by its unique ID

  /// Save API key value by key ID
  Future<void> saveApiKeyValue(String apiKeyId, String keyValue) async {
    final key = '$_apiKeyValuePrefix$apiKeyId';
    await write(key, keyValue);
  }

  /// Get API key value by key ID
  Future<String?> getApiKeyValue(String apiKeyId) async {
    final key = '$_apiKeyValuePrefix$apiKeyId';
    return await read(key);
  }

  /// Delete API key value by key ID
  Future<void> deleteApiKeyValue(String apiKeyId) async {
    final key = '$_apiKeyValuePrefix$apiKeyId';
    await delete(key);
  }

  // ===== Active API Key Tracking (per project) =====
  // Track which API key is currently active for each project

  /// Save which API key is active for a project
  Future<void> saveActiveApiKeyId(int projectId, String apiKeyId) async {
    final key = '$_activeApiKeyPrefix$projectId';
    await write(key, apiKeyId);
  }

  /// Get active API key ID for a project
  Future<String?> getActiveApiKeyId(String projectId) async {
    final key = '$_activeApiKeyPrefix$projectId';
    return await read(key);
  }

  /// Delete active API key tracking for a project
  Future<void> deleteActiveApiKeyId(String projectId) async {
    final key = '$_activeApiKeyPrefix$projectId';
    await delete(key);
  }

  // ===== Legacy Methods (deprecated) =====
  // These methods store one key per project and will be phased out

  /// Save API key for a specific project (legacy - stores only one key)
  @Deprecated(
      'Use saveApiKeyValue(apiKeyId, keyValue) + saveActiveApiKeyId(projectId, apiKeyId)')
  Future<void> saveApiKey(String projectId, String apiKey) async {
    final key = '$_apiKeyPrefix$projectId';
    await write(key, apiKey);
  }

  /// Get API key for a specific project (legacy - returns only one key)
  @Deprecated('Use getActiveApiKeyId(projectId) + getApiKeyValue(apiKeyId)')
  Future<String?> getApiKey(String projectId) async {
    final key = '$_apiKeyPrefix$projectId';
    return await read(key);
  }

  /// Delete API key for a specific project (legacy)
  @Deprecated(
      'Use deleteApiKeyValue(apiKeyId) + deleteActiveApiKeyId(projectId)')
  Future<void> deleteApiKey(String projectId) async {
    final key = '$_apiKeyPrefix$projectId';
    await delete(key);
  }

  /// Save currently selected project ID
  Future<void> saveCurrentProjectId(String projectId) =>
      write(_projectIdKey, projectId);

  /// Get currently selected project ID
  Future<String?> getCurrentProjectId() => read(_projectIdKey);

  /// Delete currently selected project ID
  Future<void> deleteCurrentProjectId() => delete(_projectIdKey);

  Future<void> setDeviceToken(String token) async {
    await write(_deviceTokenKey, token);
  }

  Future<String?> getDeviceToken() async {
    return read(_deviceTokenKey);
  }

  /// Legacy: Save API key globally (backwards compatibility)
  @Deprecated('Use saveApiKey(projectId, apiKey) instead')
  Future<void> saveLegacyApiKey(String apiKey) =>
      write(_legacyApiKeyKey, apiKey);

  /// Legacy: Get global API key (backwards compatibility)
  @Deprecated('Use getApiKey(projectId) instead')
  Future<String?> getLegacyApiKey() => read(_legacyApiKeyKey);

  /// Legacy: Delete global API key (backwards compatibility)
  @Deprecated('Use deleteApiKey(projectId) instead')
  Future<void> deleteLegacyApiKey() => delete(_legacyApiKeyKey);
}

/// Secure Storage Provider
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return const SecureStorage();
});

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Guest API Key Service
///
/// Manages storage and retrieval of server-issued Guest API Keys.
/// Does NOT generate keys - keys are obtained from bootstrap endpoint.
///
/// Flow:
/// 1. User clicks "Create Project" (first time as guest)
/// 2. Bootstrap endpoint returns Guest API Key
/// 3. Store key in SharedPreferences
/// 4. Use key for all subsequent requests
///
/// Key Format: Server-defined (received from /v3/projects/bootstrap)
///
/// Request Header Rules:
/// - If Firebase Auth token exists: Send Authorization header (no X-API-KEY)
/// - If Firebase Auth token absent AND guest key exists: Send X-API-KEY header
/// - If no auth token and no guest key: Send no headers (requests will be unauthenticated)
class GuestApiKeyService {
  static const String _storageKey = 'guest_identification_key';
  static const String _legacyKeyPrefix = 'guest_'; // For migration detection

  final SharedPreferences _prefs;
  final Logger _logger = Logger();

  String? _cachedKey;

  GuestApiKeyService(this._prefs);

  /// Get stored Guest API Key
  /// Returns null if no key exists (user has not bootstrapped yet)
  /// This method is PURE storage retrieval - no generation logic
  String? getGuestKey() {
    // Return cached key if available
    if (_cachedKey != null) {
      return _cachedKey;
    }

    // Load from storage
    final storedKey = _prefs.getString(_storageKey);
    if (storedKey != null && storedKey.isNotEmpty) {
      _cachedKey = storedKey;
      return storedKey;
    }

    // No key exists - return null
    return null;
  }

  /// Store a server-issued Guest API Key
  /// Should ONLY be called after successful bootstrap API response
  Future<void> storeGuestKey(String key) async {
    await _prefs.setString(_storageKey, key);
    _cachedKey = key;
    _logger.i('Guest API Key stored successfully');
  }

  /// Clear Guest API Key (useful for logout/reset)
  Future<void> clearGuestKey() async {
    await _prefs.remove(_storageKey);
    _cachedKey = null;
    _logger.i('Guest API Key cleared');
  }

  /// Check if a Guest API Key exists
  /// Returns true if key is cached or stored in SharedPreferences
  bool hasGuestKey() {
    return _cachedKey != null || _prefs.containsKey(_storageKey);
  }

  /// Get the cached guest key without storage access
  /// Returns null if not yet loaded
  String? get cachedGuestKey => _cachedKey;

  /// Pre-load the guest key into cache (call during app initialization)
  /// This is safe because it only loads from storage, never generates
  void preloadGuestKey() {
    getGuestKey(); // Synchronously loads into cache
  }

  /// Migrate from old UUID-based guest identification to new Guest API Key
  /// Call this during app initialization to clear legacy UUID keys
  ///
  /// This method detects and removes old client-generated UUID keys
  /// (format: "guest_<uuid>_<timestamp>") to ensure clean migration
  Future<void> migrateFromUuidKey() async {
    final storedValue = _prefs.getString(_storageKey);

    if (storedValue != null && storedValue.startsWith(_legacyKeyPrefix)) {
      // Check if this looks like an old UUID-based key
      // Old format: guest_<uuid>_<timestamp>
      // New format: Server-defined (e.g., "gsk_..." or similar)

      final parts = storedValue.split('_');
      if (parts.length == 3 && parts[0] == 'guest') {
        // This is likely an old UUID-based key - clear it
        await _prefs.remove(_storageKey);
        _cachedKey = null;
        _logger.i('Migrated: Cleared old UUID-based guest key');
      }
    }
  }
}

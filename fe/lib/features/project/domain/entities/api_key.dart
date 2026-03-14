import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_key.freezed.dart';

/// API Key domain entity
/// Provides project-scoped authentication for server API
/// Mirrors backend model: app/models/api_key.py
/// NOTE: Only available for authenticated users
@freezed
class ApiKey with _$ApiKey {
  const factory ApiKey({
    required String id,
    required String projectId,
    required String keyValue,     // The actual key value (e.g., "ss_abc123...")
    required String name,          // Human-readable name (e.g., "Production Key")
    String? description,
    required bool isActive,
    DateTime? lastUsedAt,
    required int usageCount,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) = _ApiKey;

  const ApiKey._();

  /// Check if key is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if key is usable (active and not expired)
  bool get isUsable => isActive && !isExpired;

  /// Get masked key value for display (show first 8 and last 4 characters)
  String get maskedKeyValue {
    if (keyValue.length <= 12) {
      return '•' * keyValue.length;
    }

    final start = keyValue.substring(0, 8);
    final end = keyValue.substring(keyValue.length - 4);
    final masked = '•' * (keyValue.length - 12);

    return '$start$masked$end';
  }
}

/// API Key creation input
@freezed
class ApiKeyCreate with _$ApiKeyCreate {
  const factory ApiKeyCreate({
    required String name,
    String? description,
    DateTime? expiresAt,
  }) = _ApiKeyCreate;
}

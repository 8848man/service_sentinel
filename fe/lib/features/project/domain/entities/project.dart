import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/features/project/domain/entities/project_health.dart';
import 'api_key.dart';

part 'project.freezed.dart';

/// Project domain entity
/// Aggregate root for all monitoring data
/// Mirrors backend model: app/models/project.py
@freezed
class Project with _$Project {
  const factory Project({
    required int id,
    required String name,
    String? description,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Local-only flag to track if project exists only in local DB
    @Default(false) bool isLocalOnly,
    // API keys for this project (one-to-many relationship)
    @Default([]) List<ApiKey> apiKeys,
    ProjectHealth? health,
  }) = _Project;

  const Project._();

  /// Get all active API keys
  List<ApiKey> get activeApiKeys =>
      apiKeys.where((key) => key.isActive).toList();

  /// Get all usable API keys (active and not expired)
  List<ApiKey> get usableApiKeys =>
      apiKeys.where((key) => key.isUsable).toList();

  /// Check if project has any usable API keys
  bool get hasUsableApiKeys => usableApiKeys.isNotEmpty;

  /// Get API key by ID
  ApiKey? getApiKeyById(String keyId) {
    try {
      return apiKeys.firstWhere((key) => key.id == keyId);
    } catch (e) {
      return null;
    }
  }

  /// Get the most recently used API key
  ApiKey? get mostRecentlyUsedApiKey {
    if (apiKeys.isEmpty) return null;

    final keysWithUsage =
        apiKeys.where((key) => key.lastUsedAt != null).toList();
    if (keysWithUsage.isEmpty) return apiKeys.first;

    keysWithUsage.sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));
    return keysWithUsage.first;
  }
}

/// Project creation input
@freezed
class ProjectCreate with _$ProjectCreate {
  const factory ProjectCreate({
    required String name,
    String? description,
  }) = _ProjectCreate;
}

/// Project update input
@freezed
class ProjectUpdate with _$ProjectUpdate {
  const factory ProjectUpdate({
    String? name,
    String? description,
    bool? isActive,
  }) = _ProjectUpdate;
}

/// Project statistics (from backend dashboard)
@freezed
class ProjectStats with _$ProjectStats {
  const factory ProjectStats({
    required String projectId,
    required int totalServices,
    required int healthyServices,
    required int unhealthyServices,
    required int openIncidents,
  }) = _ProjectStats;
}

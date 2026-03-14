import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/project/domain/entities/project.dart';
import '../../features/project/domain/entities/api_key.dart';

part 'project_session.freezed.dart';

/// Project Session State
/// Manages the currently selected project (including its API keys) and which key is active
/// This is separate from AuthState because project selection is user-scoped
///
/// Architecture: Stores complete Project entity (which includes API keys list)
/// and tracks which API key is currently active for API calls
@freezed
class ProjectSession with _$ProjectSession {
  const factory ProjectSession({
    // The complete selected project (includes all API keys)
    Project? project,

    // Which API key is currently active for this session
    String? activeApiKeyId,
  }) = _ProjectSession;

  const ProjectSession._();

  /// Check if a project is selected
  bool get hasProject => project != null;

  /// Get the active API key entity
  ApiKey? get activeApiKey {
    if (project == null || activeApiKeyId == null) return null;
    return project!.getApiKeyById(activeApiKeyId!);
  }

  /// Get the active API key value for making API calls
  String? get activeApiKeyValue => activeApiKey?.keyValue;

  /// Check if API key is configured and usable
  bool get hasApiKey => activeApiKey != null && activeApiKey!.isUsable;

  /// Check if session is fully configured (authenticated users need API key)
  bool get isFullyConfigured => hasProject && hasApiKey;

  /// Convenience getters for project info
  int? get projectId => project?.id;
  String? get projectName => project?.name;
  String? get activeApiKeyName => activeApiKey?.name;

  /// Empty session
  factory ProjectSession.empty() => const ProjectSession();

  /// Deprecated: Use activeApiKeyValue instead
  @Deprecated('Use activeApiKeyValue instead')
  String? get apiKey => activeApiKeyValue;
}

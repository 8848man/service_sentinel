import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/project/domain/entities/project.dart';
import 'project_session.dart';
import '../storage/secure_storage.dart';

/// Project Session Notifier
/// Manages the currently selected project and its API key
/// Note: API keys are NOT set globally - each service manages its own API key headers
class ProjectSessionNotifier extends StateNotifier<ProjectSession> {
  final SecureStorage _secureStorage;

  ProjectSessionNotifier({
    required SecureStorage secureStorage,
  })  : _secureStorage = secureStorage,
        super(ProjectSession.empty());

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
        throw Exception(
            'API key $activeApiKeyId not found in project ${project.id}');
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

  /// Load saved active API key for the current project
  Future<void> loadActiveApiKeyForCurrentProject() async {
    if (!state.hasProject) return;

    // Get which API key was previously active
    final savedActiveKeyId =
        await _secureStorage.getActiveApiKeyId(state.projectId!.toString());
    if (savedActiveKeyId == null) return;

    // Check if this key still exists in the project
    final apiKey = state.project!.getApiKeyById(savedActiveKeyId);
    if (apiKey == null || !apiKey.isUsable) return;

    // Update state with the active key
    state = state.copyWith(activeApiKeyId: savedActiveKeyId);

    // Note: API key is NOT set on DioClient
    // Each service will use its own API key when making requests
  }

  /// Switch to a different API key for current project
  Future<void> switchApiKey(String apiKeyId) async {
    if (!state.hasProject) return;

    // Verify the key exists and is usable
    final apiKey = state.project!.getApiKeyById(apiKeyId);
    if (apiKey == null || !apiKey.isUsable) {
      throw Exception('API key $apiKeyId not found or not usable');
    }

    state = state.copyWith(activeApiKeyId: apiKeyId);

    // Note: API key is NOT set on DioClient
    // Services should use the updated activeApiKeyValue from ProjectSession

    // Persist the new active key
    await _secureStorage.saveActiveApiKeyId(state.projectId!, apiKeyId);
  }

  /// Update the project data (e.g., after fetching API keys from backend)
  Future<void> updateProject(Project project) async {
    if (state.projectId != project.id) return;

    state = state.copyWith(project: project);

    // Note: API keys are managed per-service, not globally
  }

  /// Clear current project session
  Future<void> clear() async {
    state = ProjectSession.empty();
    // Note: No need to clear DioClient - API keys are per-service
  }
}

/// Project Session Provider
/// Use StateNotifierProvider pattern:
/// - ref.watch(projectSessionProvider) → returns ProjectSession (state)
/// - ref.read(projectSessionProvider.notifier) → returns ProjectSessionNotifier
final projectSessionProvider =
    StateNotifierProvider<ProjectSessionNotifier, ProjectSession>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  return ProjectSessionNotifier(
    secureStorage: secureStorage,
  );
});

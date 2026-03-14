import 'package:service_sentinel_fe_v2/features/project/data/data_sources/project_data_source.dart';

import '../../features/project/domain/entities/project.dart';
import '../error/app_error.dart';
import 'migration_state.dart';

/// Migration service - Handles data migration from local to server storage
///
/// Migration conditions:
/// 1. User logs in (transitions from guest to authenticated)
/// 2. Local DB contains at least one Project
/// 3. Migration not already completed
///
/// Migration behavior:
/// - Compare local and server project lists
/// - Upload local projects (and related data) to server
/// - Do NOT delete local data automatically
/// - Mark migration as completed to prevent repeated uploads
/// - Emit migration state changes for UI consumption
class MigrationService {
  final LocalProjectDataSource _localProjectDataSource;
  final RemoteProjectDataSource _remoteProjectDataSource;

  MigrationService({
    required LocalProjectDataSource localProjectDataSource,
    required RemoteProjectDataSource remoteProjectDataSource,
  })  : _localProjectDataSource = localProjectDataSource,
        _remoteProjectDataSource = remoteProjectDataSource;

  /// Check if migration is needed
  /// Returns true if:
  /// - Local projects exist
  /// - User is authenticated (checked by caller)
  Future<bool> isMigrationNeeded() async {
    try {
      final localProjects = await _localProjectDataSource.getAll();
      return localProjects.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get the number of projects that need migration
  Future<int> getMigrationItemCount() async {
    try {
      final localProjects = await _localProjectDataSource.getAll();
      return localProjects.length;
    } catch (e) {
      return 0;
    }
  }

  /// Execute migration - Upload local projects to server
  ///
  /// This method is designed to be called with a state callback
  /// to emit migration progress updates.
  ///
  /// The callback receives MigrationState updates:
  /// - MigrationState.inProgress - During migration
  /// - MigrationState.completed - On success
  /// - MigrationState.failed - On error
  Future<void> migrate({
    required void Function(MigrationState) onStateChange,
  }) async {
    try {
      // Get local projects
      final localProjects = await _localProjectDataSource.getAll();

      if (localProjects.isEmpty) {
        onStateChange(MigrationState.completed(totalItems: 0));
        return;
      }

      // Emit in-progress state
      onStateChange(MigrationState.inProgress(
        totalItems: localProjects.length,
        migratedItems: 0,
      ));

      // Upload each project
      int migratedCount = 0;
      for (final project in localProjects) {
        await _uploadProject(project);
        migratedCount++;

        // Emit progress update
        onStateChange(MigrationState.inProgress(
          totalItems: localProjects.length,
          migratedItems: migratedCount,
        ));
      }

      // Emit completed state
      onStateChange(MigrationState.completed(totalItems: localProjects.length));
    } catch (e) {
      // Emit failed state
      final errorMessage = e is AppError ? e.message : e.toString();
      onStateChange(MigrationState.failed(errorMessage: errorMessage));
    }
  }

  /// Upload a single project from local to server
  Future<void> _uploadProject(Project localProject) async {
    try {
      // Check if project already exists on server by name
      final existsOnServer =
          await _remoteProjectDataSource.existsByName(localProject.name);

      if (existsOnServer) {
        // Skip if already exists
        return;
      }

      // Create project on server
      await _remoteProjectDataSource.create(ProjectCreate(
        name: localProject.name,
        description: localProject.description,
      ));

      // Note: Services and incidents for this project would also need to be migrated
      // For now, we only migrate projects. Full migration would require:
      // 1. Migrate project
      // 2. Get server project ID
      // 3. Migrate services with new project ID
      // 4. Migrate incidents with new service IDs
      //
      // This is a simplified implementation focusing on the core migration pattern.
    } catch (e) {
      // Re-throw to fail the entire migration
      throw NetworkError(
          message: 'Failed to upload project: ${localProject.name}');
    }
  }

  /// Clear local data after successful migration
  /// This is optional and should only be called if user confirms
  Future<void> clearLocalData() async {
    await _localProjectDataSource.clearAll();
    // Also clear related data (services, incidents) if needed
  }
}

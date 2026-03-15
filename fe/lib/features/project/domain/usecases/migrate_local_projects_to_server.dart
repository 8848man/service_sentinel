import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case: Migrate Local Projects to Server
/// Called after user logs in to sync local data with server
///
/// Migration Strategy:
/// 1. Get all local projects (isLocalOnly=true)
/// 2. For each local project:
///    a. Check if project with same name exists on server
///    b. If exists: Skip (user can manually resolve conflicts)
///    c. If not exists: Upload to server
/// 3. Return migration result with conflicts and successes
class MigrateLocalProjectsToServer {
  final ProjectRepository _localRepository;
  final ProjectRepository _remoteRepository;

  MigrateLocalProjectsToServer({
    required ProjectRepository localRepository,
    required ProjectRepository remoteRepository,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository;

  Future<Result<MigrationResult>> execute() async {
    try {
      // Get all local projects
      final localProjectsResult = await _localRepository.getAll();
      if (localProjectsResult.isFailure) {
        return Result.failure(localProjectsResult.errorOrNull!);
      }

      final localProjects =
          localProjectsResult.dataOrNull!.where((p) => p.isLocalOnly).toList();

      if (localProjects.isEmpty) {
        return Result.success(
          MigrationResult(
            totalLocal: 0,
            migrated: [],
            conflicts: [],
            failed: [],
          ),
        );
      }

      final List<Project> migrated = [];
      final List<ProjectConflict> conflicts = [];
      final List<ProjectMigrationFailure> failed = [];

      // Attempt to migrate each local project
      for (final localProject in localProjects) {
        try {
          // Check if project name already exists on server
          final existsResult =
              await _remoteRepository.existsOnServer(localProject.name);

          if (existsResult.isSuccess && existsResult.dataOrNull == true) {
            // Conflict: project name already exists
            conflicts.add(
              ProjectConflict(
                localProject: localProject,
                reason: 'Project name already exists on server',
              ),
            );
            continue;
          }

          // Upload to server
          final uploadResult =
              await _remoteRepository.uploadToServer(localProject);

          if (uploadResult.isSuccess) {
            migrated.add(uploadResult.dataOrNull!);
          } else {
            failed.add(
              ProjectMigrationFailure(
                project: localProject,
                error: uploadResult.errorOrNull!.message,
              ),
            );
          }
        } catch (e) {
          failed.add(
            ProjectMigrationFailure(
              project: localProject,
              error: e.toString(),
            ),
          );
        }
      }

      return Result.success(
        MigrationResult(
          totalLocal: localProjects.length,
          migrated: migrated,
          conflicts: conflicts,
          failed: failed,
        ),
      );
    } catch (e) {
      return Result.failure(
        StorageError(message: 'Migration failed: ${e.toString()}'),
      );
    }
  }
}

/// Migration result
class MigrationResult {
  final int totalLocal;
  final List<Project> migrated;
  final List<ProjectConflict> conflicts;
  final List<ProjectMigrationFailure> failed;

  MigrationResult({
    required this.totalLocal,
    required this.migrated,
    required this.conflicts,
    required this.failed,
  });

  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasFailed => failed.isNotEmpty;
  bool get allSuccessful => conflicts.isEmpty && failed.isEmpty;
}

/// Project conflict during migration
class ProjectConflict {
  final Project localProject;
  final String reason;

  ProjectConflict({
    required this.localProject,
    required this.reason,
  });
}

/// Project migration failure
class ProjectMigrationFailure {
  final Project project;
  final String error;

  ProjectMigrationFailure({
    required this.project,
    required this.error,
  });
}

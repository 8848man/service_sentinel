import '../../../../core/error/result.dart';
import '../entities/project.dart';
import '../entities/project_health.dart';

/// Project repository interface
/// Abstracts local and remote data sources
/// Implementation switches based on AuthState.sourceOfTruth
abstract class ProjectRepository {
  /// Get all projects
  /// Guest: Returns projects from Local DB
  /// Authenticated: Returns projects from Server DB
  Future<Result<List<Project>>> getAll();

  /// Get project by ID
  Future<Result<Project>> getById(String id);

  /// Get project with statistics
  Future<Result<ProjectStats>> getStats(String id);

  /// Get project health
  /// Health is ALWAYS server-calculated from services and incidents
  /// Returns aggregated health status, service counts, and active incidents
  Future<Result<ProjectHealth>> getHealth(String id);

  /// Create new project
  /// Guest: Stores in Local DB with isLocalOnly=true
  /// Authenticated: Creates on server
  Future<Result<Project>> create(ProjectCreate data);

  /// Update project
  Future<Result<Project>> update(String id, ProjectUpdate data);

  /// Delete project
  /// Guest: Deletes from Local DB
  /// Authenticated: Deletes from server (cascades to all related data)
  Future<Result<void>> delete(String id);

  /// Upload local project to server (migration)
  /// Only used during login migration
  Future<Result<Project>> uploadToServer(Project localProject);

  /// Check if project exists on server
  /// Used during migration to detect conflicts
  Future<Result<bool>> existsOnServer(String projectName);
}

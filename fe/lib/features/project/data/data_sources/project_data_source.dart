import '../../domain/entities/project.dart';
import '../../domain/entities/project_health.dart';

/// Abstract interface for project data sources
/// Implemented by both LocalProjectDataSource and RemoteProjectDataSource
abstract class ProjectDataSource {
  /// Get all projects
  Future<List<Project>> getAll();

  /// Get project by ID
  Future<Project> getById(String id);

  /// Create new project
  Future<Project> create(ProjectCreate data);

  /// Update project
  Future<Project> update(String id, ProjectUpdate data);

  /// Delete project
  Future<void> delete(String id);

  /// Check if project exists by name
  Future<bool> existsByName(String name);
}

/// Local data source interface (Hive)
/// Guest users store projects locally
abstract class LocalProjectDataSource extends ProjectDataSource {
  /// Mark all local projects with isLocalOnly flag
  Future<void> markAllAsLocalOnly();

  /// Clear all local projects (used during migration)
  Future<void> clearAll();
}

/// Remote data source interface (REST API)
/// Authenticated users interact with server
abstract class RemoteProjectDataSource extends ProjectDataSource {
  /// Get project statistics from server
  Future<ProjectStats> getStats(String id);

  /// Get project health from server
  /// Health is ALWAYS server-calculated, never local
  Future<ProjectHealth> getHealth(String id);
}

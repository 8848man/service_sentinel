import '../../../../core/error/result.dart';
import '../entities/project_health.dart';
import '../repositories/project_repository.dart';

/// Use case: Get Project Health
///
/// Fetches aggregated project health from the server.
/// Health includes:
/// - Overall status (HEALTHY, DEGRADED, UNKNOWN)
/// - Service counts by state (healthy, error, inactive)
/// - Active incident count
///
/// Note: Health is NEVER cached or stored locally - always fetched from server
class GetProjectHealth {
  final ProjectRepository _repository;

  GetProjectHealth(this._repository);

  /// Execute use case
  /// @param projectId The ID of the project to get health for
  /// @return Result containing ProjectHealth or AppError
  Future<Result<ProjectHealth>> execute(String projectId) {
    return _repository.getHealth(projectId);
  }
}

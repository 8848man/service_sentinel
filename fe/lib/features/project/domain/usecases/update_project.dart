import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case: Update Project
/// Updates an existing project in appropriate data source
/// Guest: Local DB, Authenticated: Server
class UpdateProject {
  final ProjectRepository _repository;

  UpdateProject({
    required ProjectRepository repository,
  }) : _repository = repository;

  Future<Result<Project>> execute(String id, ProjectUpdate data) async {
    // Validate input
    if (data.name != null && data.name!.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Project name cannot be empty'),
      );
    }

    if (data.name != null && data.name!.length > 100) {
      return Result.failure(
        ValidationError(message: 'Project name cannot exceed 100 characters'),
      );
    }

    return await _repository.update(id, data);
  }
}

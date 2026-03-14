import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case: Create Project
/// Creates a new project in appropriate data source
/// Guest: Local DB, Authenticated: Server
class CreateProject {
  final ProjectRepository _repository;

  CreateProject({
    required ProjectRepository repository,
  }) : _repository = repository;

  Future<Result<Project>> execute(ProjectCreate data) async {
    // Validate input
    if (data.name.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Project name cannot be empty'),
      );
    }

    if (data.name.length > 100) {
      return Result.failure(
        ValidationError(message: 'Project name cannot exceed 100 characters'),
      );
    }

    return await _repository.create(data);
  }
}

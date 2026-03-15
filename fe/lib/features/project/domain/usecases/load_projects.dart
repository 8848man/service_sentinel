import '../../../../core/error/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case: Load Projects
/// Loads all projects from appropriate data source based on auth state
/// Repository provider handles the switching logic
class LoadProjects {
  final ProjectRepository _repository;

  LoadProjects({
    required ProjectRepository repository,
  }) : _repository = repository;

  Future<Result<List<Project>>> execute() async {
    return await _repository.getAll();
  }

  /// Load projects with filtering
  Future<Result<List<Project>>> executeFiltered({
    bool? isActive,
    bool? isLocalOnly,
  }) async {
    final result = await _repository.getAll();

    if (result.isFailure) {
      return result;
    }

    var projects = result.dataOrNull!;

    if (isActive != null) {
      projects = projects.where((p) => p.isActive == isActive).toList();
    }

    if (isLocalOnly != null) {
      projects = projects.where((p) => p.isLocalOnly == isLocalOnly).toList();
    }

    return Result.success(projects);
  }
}

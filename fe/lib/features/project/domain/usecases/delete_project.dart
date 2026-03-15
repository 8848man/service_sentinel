import '../../../../core/error/result.dart';
import '../repositories/project_repository.dart';

/// Use case: Delete Project
/// Deletes a project from appropriate data source
/// Guest: Local DB, Authenticated: Server (cascades to all related data)
class DeleteProject {
  final ProjectRepository _repository;

  DeleteProject({
    required ProjectRepository repository,
  }) : _repository = repository;

  Future<Result<void>> execute(String id) async {
    return await _repository.delete(id);
  }
}

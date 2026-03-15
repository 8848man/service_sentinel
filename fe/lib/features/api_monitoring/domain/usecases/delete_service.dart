import '../../../../core/error/result.dart';
import '../repositories/service_repository.dart';

/// Use case: Delete Service
/// Deletes a monitored service/API
/// Guest: Local DB, Authenticated: Server
class DeleteService {
  final ServiceRepository _repository;

  DeleteService({
    required ServiceRepository repository,
  }) : _repository = repository;

  Future<Result<void>> execute(int id) async {
    return await _repository.delete(id);
  }
}

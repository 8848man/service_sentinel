import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/health_check.dart';
import '../repositories/service_repository.dart';

/// Use case: Trigger Health Check
/// Manually triggers a health check for a service
/// Only available for authenticated users with server-backed services
class TriggerHealthCheck {
  final ServiceRepository _repository;

  TriggerHealthCheck({
    required ServiceRepository repository,
  }) : _repository = repository;

  Future<Result<HealthCheck>> execute(int serviceId) async {
    if (serviceId == 0) {
      return Result.failure(
        ValidationError(message: 'Service ID is required'),
      );
    }

    return await _repository.checkNow(serviceId);
  }
}

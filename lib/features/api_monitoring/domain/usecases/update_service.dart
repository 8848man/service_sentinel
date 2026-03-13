import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

/// Use case: Update Service
/// Updates an existing monitored service/API
/// Guest: Local DB, Authenticated: Server
class UpdateService {
  final ServiceRepository _repository;

  UpdateService({
    required ServiceRepository repository,
  }) : _repository = repository;

  Future<Result<Service>> execute(int id, ServiceUpdate data) async {
    // Validate input
    if (data.name != null && data.name!.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Service name cannot be empty'),
      );
    }

    if (data.name != null && data.name!.length > 100) {
      return Result.failure(
        ValidationError(message: 'Service name cannot exceed 100 characters'),
      );
    }

    if (data.endpointUrl != null && data.endpointUrl!.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Endpoint URL cannot be empty'),
      );
    }

    if (data.endpointUrl != null) {
      final urlPattern = RegExp(r'^https?://');
      if (!urlPattern.hasMatch(data.endpointUrl!)) {
        return Result.failure(
          ValidationError(
              message: 'Endpoint URL must start with http:// or https://'),
        );
      }
    }

    if (data.timeoutSeconds != null &&
        (data.timeoutSeconds! <= 0 || data.timeoutSeconds! > 300)) {
      return Result.failure(
        ValidationError(message: 'Timeout must be between 1 and 300 seconds'),
      );
    }

    if (data.checkIntervalSeconds != null &&
        (data.checkIntervalSeconds! < 10 ||
            data.checkIntervalSeconds! > 3600)) {
      return Result.failure(
        ValidationError(
            message: 'Check interval must be between 10 and 3600 seconds'),
      );
    }

    if (data.failureThreshold != null &&
        (data.failureThreshold! <= 0 || data.failureThreshold! > 10)) {
      return Result.failure(
        ValidationError(message: 'Failure threshold must be between 1 and 10'),
      );
    }

    return await _repository.update(id, data);
  }
}

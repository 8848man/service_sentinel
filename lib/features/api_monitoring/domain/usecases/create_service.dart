import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

/// Use case: Create Service
/// Creates a new monitored service/API
/// Guest: Local DB, Authenticated: Server
class CreateService {
  final ServiceRepository _repository;

  CreateService({
    required ServiceRepository repository,
  }) : _repository = repository;

  Future<Result<Service>> execute(ServiceCreate data) async {
    // Validate input
    if (data.name.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Service name cannot be empty'),
      );
    }

    if (data.name.length > 100) {
      return Result.failure(
        ValidationError(message: 'Service name cannot exceed 100 characters'),
      );
    }

    if (data.endpointUrl.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Endpoint URL cannot be empty'),
      );
    }

    // Basic URL validation
    final urlPattern = RegExp(r'^https?://');
    if (!urlPattern.hasMatch(data.endpointUrl)) {
      return Result.failure(
        ValidationError(message: 'Endpoint URL must start with http:// or https://'),
      );
    }

    if (data.timeoutSeconds <= 0 || data.timeoutSeconds > 300) {
      return Result.failure(
        ValidationError(message: 'Timeout must be between 1 and 300 seconds'),
      );
    }

    if (data.checkIntervalSeconds < 10 || data.checkIntervalSeconds > 3600) {
      return Result.failure(
        ValidationError(message: 'Check interval must be between 10 and 3600 seconds'),
      );
    }

    if (data.failureThreshold <= 0 || data.failureThreshold > 10) {
      return Result.failure(
        ValidationError(message: 'Failure threshold must be between 1 and 10'),
      );
    }

    return await _repository.create(data);
  }
}

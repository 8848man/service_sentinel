import '../../../../core/error/result.dart';
import '../entities/service.dart';
import '../entities/health_check.dart';

/// Service repository interface
/// Abstracts local and remote data sources for API monitoring
abstract class ServiceRepository {
  /// Get all services for current project
  /// Automatically scoped by auth state
  Future<Result<List<Service>>> getAll({bool? isActive});

  /// Get service by ID
  Future<Result<Service>> getById(int id);

  /// Create new service
  Future<Result<Service>> create(ServiceCreate data);

  /// Update service
  Future<Result<Service>> update(int id, ServiceUpdate data);

  /// Delete service
  Future<Result<void>> delete(int id);

  /// Activate service (enable monitoring)
  Future<Result<void>> activate(int id);

  /// Deactivate service (pause monitoring)
  Future<Result<void>> deactivate(int id);

  /// Trigger manual health check
  /// Returns health check result immediately
  Future<Result<HealthCheck>> checkNow(int id);

  /// Get health check history for service
  Future<Result<List<HealthCheck>>> getHealthChecks(
    int id, {
    int? limit,
    DateTime? since,
  });

  /// Get latest health check for service
  Future<Result<HealthCheck?>> getLatestHealthCheck(int id);

  /// Get service statistics
  Future<Result<ServiceStats>> getStats(int id, String period);
}

/// Service statistics
class ServiceStats {
  final String serviceId;
  final double uptimePercentage;
  final int totalChecks;
  final int successfulChecks;
  final int failedChecks;
  final double averageLatencyMs;

  ServiceStats({
    required this.serviceId,
    required this.uptimePercentage,
    required this.totalChecks,
    required this.successfulChecks,
    required this.failedChecks,
    required this.averageLatencyMs,
  });
}

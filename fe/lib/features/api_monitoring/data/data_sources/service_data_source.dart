import '../../domain/entities/service.dart';
import '../../domain/entities/health_check.dart';
import '../../domain/repositories/service_repository.dart';

/// Abstract interface for service data sources
/// v2 API - All operations are project-scoped
abstract class ServiceDataSource {
  /// Get all services for a project
  Future<List<Service>> getAll({
    required int projectId,
    bool? isActive,
    int skip = 0,
    int limit = 100,
  });

  /// Get service by ID
  Future<Service> getById({
    required int projectId,
    required int serviceId,
  });

  /// Create new service
  Future<Service> create({
    required int projectId,
    required ServiceCreate data,
  });

  /// Update service
  Future<Service> update({
    required int projectId,
    required int serviceId,
    required ServiceUpdate data,
  });

  /// Delete service
  Future<void> delete({
    required int projectId,
    required int serviceId,
  });

  /// Get health check history
  Future<List<HealthCheck>> getHealthChecks({
    required int projectId,
    required int serviceId,
    int skip = 0,
    int limit = 100,
  });

  /// Get latest health check
  Future<HealthCheck?> getLatestHealthCheck({
    required int projectId,
    required int serviceId,
  });
}

/// Local data source interface (Hive)
abstract class LocalServiceDataSource extends ServiceDataSource {
  /// Clear all services for a project
  Future<void> clearAllForProject(int projectId);
}

/// Remote data source interface (REST API)
/// Requires API key authentication via X-API-Key header
/// v2 API - All operations are project-scoped
abstract class RemoteServiceDataSource extends ServiceDataSource {
  /// Activate service (returns updated service)
  Future<Service> activate({
    required int projectId,
    required int serviceId,
  });

  /// Deactivate service (returns updated service)
  Future<Service> deactivate({
    required int projectId,
    required int serviceId,
  });

  /// Trigger manual health check
  Future<HealthCheck> checkNow({
    required int projectId,
    required int serviceId,
  });

  /// Get service statistics
  Future<ServiceStats> getStats({
    required int projectId,
    required int serviceId,
    String period = '24h',
  });
}

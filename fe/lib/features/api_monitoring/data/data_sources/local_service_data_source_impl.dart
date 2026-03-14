import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/health_check.dart';
import 'service_data_source.dart';

/// Local service data source implementation using Hive
/// Stores services and health checks locally for guest users
///
/// Storage format: JSON in Hive boxes
/// Box names: 'services', 'health_checks'
class LocalServiceDataSourceImpl implements LocalServiceDataSource {
  static const String _servicesBoxName = 'services';
  static const String _healthChecksBoxName = 'health_checks';
  final _uuid = const Uuid();

  Future<Box<Map>> _getServicesBox() async {
    if (!Hive.isBoxOpen(_servicesBoxName)) {
      return await Hive.openBox<Map>(_servicesBoxName);
    }
    return Hive.box<Map>(_servicesBoxName);
  }

  Future<Box<Map>> _getHealthChecksBox() async {
    if (!Hive.isBoxOpen(_healthChecksBoxName)) {
      return await Hive.openBox<Map>(_healthChecksBoxName);
    }
    return Hive.box<Map>(_healthChecksBoxName);
  }

  @override
  Future<List<Service>> getAll({
    required int projectId,
    bool? isActive,
    int skip = 0,
    int limit = 100,
  }) async {
    final box = await _getServicesBox();
    final services = <Service>[];

    for (var key in box.keys) {
      final json = Map<String, dynamic>.from(box.get(key) as Map);
      final service = _jsonToDomain(json);

      // Filter by project and active status
      if (service.projectId == projectId &&
          (isActive == null || service.isActive == isActive)) {
        services.add(service);
      }
    }

    services.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (skip >= services.length) {
      return [];
    }
    final end = (skip + limit).clamp(0, services.length);
    return services.sublist(skip, end);
  }

  @override
  Future<Service> getById({
    required int projectId,
    required int serviceId,
  }) async {
    final box = await _getServicesBox();
    final json = box.get(serviceId);

    if (json == null) {
      throw Exception('Service not found: $serviceId');
    }

    final service = _jsonToDomain(Map<String, dynamic>.from(json as Map));

    // Verify project ownership
    if (service.projectId != projectId) {
      throw Exception(
          'Service $serviceId does not belong to project $projectId');
    }

    return service;
  }

  @override
  Future<Service> create({
    required int projectId,
    required ServiceCreate data,
  }) async {
    // final box = await _getServicesBox();
    // final now = DateTime.now();

    // final service = Service(
    //   id: _uuid.v4(),
    //   projectId: projectId,
    //   name: data.name,
    //   description: data.description,
    //   endpointUrl: data.endpointUrl,
    //   httpMethod: data.httpMethod,
    //   serviceType: data.serviceType,
    //   headers: data.headers,
    //   requestBody: data.requestBody,
    //   expectedStatusCodes: data.expectedStatusCodes,
    //   timeoutSeconds: data.timeoutSeconds,
    //   checkIntervalSeconds: data.checkIntervalSeconds,
    //   failureThreshold: data.failureThreshold,
    //   isActive: true,
    //   createdAt: now,
    //   updatedAt: now,
    // );

    // final json = _domainToJson(service);
    // await box.put(service.id, json);

    // return service;
    throw UnimplementedError();
  }

  Future<Service> createByService({
    required Service service,
  }) async {
    final box = await _getServicesBox();

    final json = _domainToJson(service);
    await box.put(service.id, json);

    return service;
  }

  @override
  Future<Service> update({
    required int projectId,
    required int serviceId,
    required ServiceUpdate data,
  }) async {
    final box = await _getServicesBox();
    final existing = await getById(projectId: projectId, serviceId: serviceId);

    final updated = Service(
      id: existing.id,
      projectId: existing.projectId,
      name: data.name ?? existing.name,
      description: data.description ?? existing.description,
      endpointUrl: data.endpointUrl ?? existing.endpointUrl,
      httpMethod: data.httpMethod ?? existing.httpMethod,
      serviceType: data.serviceType ?? existing.serviceType,
      headers: data.headers ?? existing.headers,
      requestBody: data.requestBody ?? existing.requestBody,
      expectedStatusCodes:
          data.expectedStatusCodes ?? existing.expectedStatusCodes,
      timeoutSeconds: data.timeoutSeconds ?? existing.timeoutSeconds,
      checkIntervalSeconds:
          data.checkIntervalSeconds ?? existing.checkIntervalSeconds,
      failureThreshold: data.failureThreshold ?? existing.failureThreshold,
      isActive: data.isActive ?? existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      lastCheckedAt: existing.lastCheckedAt,
    );

    final json = _domainToJson(updated);
    await box.put(serviceId, json);

    return updated;
  }

  @override
  Future<void> delete({
    required int projectId,
    required int serviceId,
  }) async {
    final box = await _getServicesBox();

    // Verify project ownership before deleting
    await getById(projectId: projectId, serviceId: serviceId);

    await box.delete(serviceId);

    // Also delete associated health checks
    final healthBox = await _getHealthChecksBox();
    final keysToDelete = <dynamic>[];
    for (var key in healthBox.keys) {
      final json = Map<String, dynamic>.from(healthBox.get(key) as Map);
      if (json['service_id'] == serviceId) {
        keysToDelete.add(key);
      }
    }
    for (var key in keysToDelete) {
      await healthBox.delete(key);
    }
  }

  @override
  Future<List<HealthCheck>> getHealthChecks({
    required int projectId,
    required int serviceId,
    int skip = 0,
    int limit = 100,
  }) async {
    // Verify service belongs to project
    await getById(projectId: projectId, serviceId: serviceId);

    final box = await _getHealthChecksBox();
    final checks = <HealthCheck>[];

    for (var key in box.keys) {
      final json = Map<String, dynamic>.from(box.get(key) as Map);
      if (json['service_id'] == serviceId) {
        final check = _healthCheckJsonToDomain(json);
        checks.add(check);
      }
    }

    // Sort by checkedAt descending (newest first)
    checks.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));

    // Apply pagination
    if (skip >= checks.length) {
      return [];
    }
    final end = (skip + limit).clamp(0, checks.length);
    return checks.sublist(skip, end);
  }

  @override
  Future<HealthCheck?> getLatestHealthCheck({
    required int projectId,
    required int serviceId,
  }) async {
    final checks = await getHealthChecks(
      projectId: projectId,
      serviceId: serviceId,
      skip: 0,
      limit: 1,
    );
    return checks.isEmpty ? null : checks.first;
  }

  @override
  Future<void> clearAllForProject(int projectId) async {
    final box = await _getServicesBox();
    final keysToDelete = <dynamic>[];

    for (var key in box.keys) {
      final json = Map<String, dynamic>.from(box.get(key) as Map);
      if (json['project_id'] == projectId) {
        keysToDelete.add(key);
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
    }

    // Also clear health checks for these services
    final healthBox = await _getHealthChecksBox();
    final healthKeysToDelete = <dynamic>[];
    for (var key in healthBox.keys) {
      final json = Map<String, dynamic>.from(healthBox.get(key) as Map);
      if (keysToDelete.contains(json['service_id'])) {
        healthKeysToDelete.add(key);
      }
    }
    for (var key in healthKeysToDelete) {
      await healthBox.delete(key);
    }
  }

  Map<String, dynamic> _domainToJson(Service service) {
    return {
      'id': service.id,
      'project_id': service.projectId,
      'name': service.name,
      'description': service.description,
      'endpoint_url': service.endpointUrl,
      'http_method': service.httpMethod.name,
      'service_type': service.serviceType.name,
      'headers': service.headers,
      'request_body': service.requestBody,
      'expected_status_codes': service.expectedStatusCodes,
      'timeout_seconds': service.timeoutSeconds,
      'check_interval_seconds': service.checkIntervalSeconds,
      'failure_threshold': service.failureThreshold,
      'is_active': service.isActive,
      'created_at': service.createdAt.toIso8601String(),
      'updated_at': service.updatedAt.toIso8601String(),
      'last_checked_at': service.lastCheckedAt?.toIso8601String(),
    };
  }

  Service _jsonToDomain(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      endpointUrl: json['endpoint_url'] as String,
      httpMethod: HttpMethod.values.firstWhere(
        (e) => e.name == json['http_method'],
        orElse: () => HttpMethod.get,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['service_type'],
        orElse: () => ServiceType.httpsApi,
      ),
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      requestBody: json['request_body'] as String?,
      expectedStatusCodes: (json['expected_status_codes'] as List).cast<int>(),
      timeoutSeconds: json['timeout_seconds'] as int,
      checkIntervalSeconds: json['check_interval_seconds'] as int,
      failureThreshold: json['failure_threshold'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastCheckedAt: json['last_checked_at'] != null
          ? DateTime.parse(json['last_checked_at'] as String)
          : null,
    );
  }

  HealthCheck _healthCheckJsonToDomain(Map<String, dynamic> json) {
    return HealthCheck(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      isAlive: json['is_alive'] as bool,
      statusCode: json['status_code'] as int?,
      latencyMs: json['latency_ms'] as int?,
      responseBody: json['response_body'] as String?,
      errorMessage: json['error_message'] as String?,
      errorType: json['error_type'] as String?,
      checkedAt: DateTime.parse(json['checked_at'] as String),
      needsAnalysis: json['needs_analysis'] as bool? ?? false,
    );
  }
}

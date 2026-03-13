import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/health_check.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../models/health_check_dto.dart';
import '../models/service_dto.dart';
import '../models/service_stats_dto.dart';
import 'service_data_source.dart';

/// Remote service data source implementation using REST API v3
/// Requires authentication (Firebase JWT or API Key per README_V3.md)
///
/// API Endpoints (v3 - Project-scoped):
/// - POST   /api/v3/projects/{project_id}/services                       - Create service
/// - GET    /api/v3/projects/{project_id}/services                       - List services
/// - GET    /api/v3/projects/{project_id}/services/{service_id}          - Get service details
/// - PATCH  /api/v3/projects/{project_id}/services/{service_id}          - Update service
/// - DELETE /api/v3/projects/{project_id}/services/{service_id}          - Delete service
/// - POST   /api/v3/projects/{project_id}/services/{service_id}/activate   - Activate monitoring
/// - POST   /api/v3/projects/{project_id}/services/{service_id}/deactivate - Pause monitoring
/// - POST   /api/v3/projects/{project_id}/services/{service_id}/check-now  - Trigger immediate check
///
/// Authentication Rules (per README_V3.md):
/// - All endpoints require authentication
/// - Authorization header (Bearer token) takes priority over X-API-Key
/// - Project ownership is validated on every request
class RemoteServiceDataSourceImpl implements RemoteServiceDataSource {
  final Dio _dio;

  RemoteServiceDataSourceImpl(this._dio);

  String _baseUrl(String projectId) =>
      '${AppConfig.apiUrl}/projects/$projectId/services';

  @override
  Future<List<Service>> getAll({
    required int projectId,
    bool? isActive,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _dio.get(
        _baseUrl(projectId.toString()),
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      final retData = data
          .map((json) =>
              ServiceDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();

      return retData;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Service> getById({
    required int projectId,
    required int serviceId,
  }) async {
    try {
      final response =
          await _dio.get('${_baseUrl(projectId.toString())}/$serviceId');
      final dto = ServiceDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Service> create({
    required int projectId,
    required ServiceCreate data,
  }) async {
    try {
      final dto = ServiceCreateDto.fromDomain(data);
      final response = await _dio.post(
        _baseUrl(projectId.toString()),
        data: dto.toJson(),
      );
      final serviceDto =
          ServiceDto.fromJson(response.data as Map<String, dynamic>);
      return serviceDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Service> update({
    required int projectId,
    required int serviceId,
    required ServiceUpdate data,
  }) async {
    try {
      final dto = ServiceUpdateDto.fromDomain(data);
      final response = await _dio.patch(
        // Changed from PUT to PATCH
        '${_baseUrl(projectId.toString())}/$serviceId',
        data: dto.toJson(),
      );
      final serviceDto =
          ServiceDto.fromJson(response.data as Map<String, dynamic>);
      return serviceDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> delete({
    required int projectId,
    required int serviceId,
  }) async {
    try {
      await _dio.delete('${_baseUrl(projectId.toString())}/$serviceId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<HealthCheck>> getHealthChecks({
    required int projectId,
    required int serviceId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };

      final response = await _dio.get(
        '${_baseUrl(projectId.toString())}/$serviceId/health-checks',
        queryParameters: queryParams,
      );

      // Response structure: { service_id, total, items: [...] }
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      final List<dynamic> items = responseData['items'] as List<dynamic>;

      return items
          .map((json) =>
              HealthCheckDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<HealthCheck?> getLatestHealthCheck({
    required int projectId,
    required int serviceId,
  }) async {
    try {
      final response = await _dio.get(
        '${_baseUrl(projectId.toString())}/$serviceId/health-checks/latest',
      );
      final dto =
          HealthCheckDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No health checks found
      }
      throw _handleError(e);
    }
  }

  @override
  Future<Service> activate({
    required int projectId,
    required int serviceId,
  }) async {
    try {
      final response = await _dio
          .post('${_baseUrl(projectId.toString())}/$serviceId/activate');
      final dto = ServiceDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Service> deactivate({
    required int projectId,
    required int serviceId,
  }) async {
    try {
      final response = await _dio
          .post('${_baseUrl(projectId.toString())}/$serviceId/deactivate');
      final dto = ServiceDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<HealthCheck> checkNow({
    required int projectId,
    required int serviceId,
  }) async {
    try {
      final response = await _dio
          .post('${_baseUrl(projectId.toString())}/$serviceId/check-now');
      final dto =
          HealthCheckDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ServiceStats> getStats({
    required int projectId,
    required int serviceId,
    String period = '24h',
  }) async {
    try {
      final response = await _dio.get(
        '${_baseUrl(projectId.toString())}/$serviceId/stats',
        queryParameters: {'period': period},
      );
      final dto =
          ServiceStatsDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppError _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      // v3 API returns errors in "detail" field per README_V3.md
      final message = error.response!.data?['detail'] as String? ??
          error.response!.data?['message'] as String? ??
          error.message;

      switch (statusCode) {
        case 401:
          // Authentication failed (missing/invalid credentials)
          return UnauthorizedError(
            message: message ?? 'Authentication required. Provide Firebase JWT or API key.',
          );
        case 403:
          // Access denied (user doesn't own project or API key is invalid)
          return UnauthorizedError(
            message: message ?? 'Access denied. You do not own this project.',
          );
        case 404:
          return NotFoundError(message: message ?? 'Service not found');
        case 422:
          // Validation error
          return ServerError(
            message: message ?? 'Validation error',
            statusCode: statusCode,
          );
        default:
          return ServerError(
            message: message ?? 'Server error',
            statusCode: statusCode,
          );
      }
    }

    // Network error
    return NetworkError(message: error.message ?? 'Network error');
  }
}

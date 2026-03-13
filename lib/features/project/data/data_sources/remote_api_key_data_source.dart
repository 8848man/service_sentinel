import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/api_key.dart';
import '../models/api_key_dto.dart';

/// Remote API key data source for REST API v3
/// API keys are server-only, no local storage exists
///
/// API Endpoints (v3):
/// - POST   /api/v3/projects/{project_id}/api-keys           - Create API key (Firebase JWT only)
/// - GET    /api/v3/projects/{project_id}/api-keys           - List API keys (Firebase JWT only)
/// - DELETE /api/v3/projects/{project_id}/api-keys/{key_id}  - Delete API key (Firebase JWT only)
/// - POST   /api/v3/projects/{project_id}/api-keys/{key_id}/deactivate - Deactivate key (Firebase JWT only)
///
/// Authentication Rules (per README_V3.md):
/// - All API key management endpoints require Firebase JWT authentication
/// - Guest users with API keys CANNOT manage API keys
/// - Only the project owner (authenticated user) can create/manage API keys
abstract class ApiKeyDataSource {
  Future<List<ApiKey>> getAll(String projectId);
  Future<ApiKey> create(String projectId, ApiKeyCreate data);
  Future<void> delete(String projectId, String keyId);
  Future<void> deactivate(String projectId, String keyId);
  Future<bool> verify(String apiKey);
}

class RemoteApiKeyDataSourceImpl implements ApiKeyDataSource {
  final Dio _dio;

  RemoteApiKeyDataSourceImpl(this._dio);

  String get _baseUrl => AppConfig.apiUrl;

  @override
  Future<List<ApiKey>> getAll(String projectId) async {
    try {
      final response = await _dio.get(
        '/projects/$projectId/api-keys',
      );

      final data = response.data as Map<String, dynamic>;
      final List items = data['items'] as List;

      return items
          .map(
            (e) => ApiKeyDto.fromJson(e as Map<String, dynamic>).toDomain(),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiKey> create(String projectId, ApiKeyCreate data) async {
    try {
      final dto = ApiKeyCreateDto.fromDomain(data);
      final response = await _dio.post(
        '$_baseUrl/projects/$projectId/api-keys',
        data: dto.toJson(),
      );
      final apiKeyDto =
          ApiKeyDto.fromJson(response.data as Map<String, dynamic>);
      return apiKeyDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> delete(String projectId, String keyId) async {
    try {
      await _dio.delete('$_baseUrl/projects/$projectId/api-keys/$keyId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deactivate(String projectId, String keyId) async {
    try {
      await _dio
          .post('$_baseUrl/projects/$projectId/api-keys/$keyId/deactivate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> verify(String apiKey) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/verify-key',
        data: {'api_key': apiKey},
      );
      return response.data['valid'] as bool? ?? false;
    } on DioException catch (e) {
      // If verification fails with 401, key is invalid
      if (e.response?.statusCode == 401) {
        return false;
      }
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
          // Authentication failed - Firebase JWT required for API key management
          return UnauthorizedError(
            message: message ??
                'Authentication required. Only Firebase-authenticated users can manage API keys.',
          );
        case 403:
          // Access denied (user doesn't own project)
          return UnauthorizedError(
            message: message ?? 'Access denied. You do not own this project.',
          );
        case 404:
          return NotFoundError(message: message ?? 'API key not found');
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

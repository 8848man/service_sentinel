import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_health.dart';
import '../models/project_dto.dart';
import '../models/project_health_dto.dart';
import 'project_data_source.dart';

/// Remote project data source implementation using REST API v3
/// Requires authentication (Firebase JWT or API Key per README_V3.md)
///
/// API Endpoints (v3):
/// - POST   /api/v3/projects        - Create project (Firebase JWT only)
/// - GET    /api/v3/projects        - List projects (Firebase JWT only)
/// - GET    /api/v3/projects/{id}   - Get project by ID
/// - PATCH  /api/v3/projects/{id}   - Update project
/// - DELETE /api/v3/projects/{id}   - Delete project
/// - GET    /api/v3/projects/{id}/stats - Get project statistics
///
/// Authentication Rules (per README_V3.md):
/// - All endpoints require authentication
/// - Authorization header (Bearer token) takes priority over X-API-Key
/// - Project creation and listing require Firebase JWT (Guest cannot access)
class RemoteProjectDataSourceImpl implements RemoteProjectDataSource {
  final Dio _dio;

  RemoteProjectDataSourceImpl(this._dio);

  String get _baseUrl => '${AppConfig.apiUrl}/projects';

  @override
  Future<List<Project>> getAll() async {
    try {
      final response = await _dio.get(_baseUrl);
      final List<dynamic> data = response.data as List<dynamic>;

      return data
          .map((json) => ProjectDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Project> getById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');
      final dto = ProjectDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Project> create(ProjectCreate data) async {
    try {
      final dto = ProjectCreateDto.fromDomain(data);
      final response = await _dio.post(
        _baseUrl,
        data: dto.toJson(),
      );
      final projectDto = ProjectDto.fromJson(response.data as Map<String, dynamic>);
      return projectDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Project> update(String id, ProjectUpdate data) async {
    try {
      final dto = ProjectUpdateDto.fromDomain(data);
      // v3 uses PATCH instead of PUT
      final response = await _dio.patch(
        '$_baseUrl/$id',
        data: dto.toJson(),
      );
      final projectDto = ProjectDto.fromJson(response.data as Map<String, dynamic>);
      return projectDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete('$_baseUrl/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> existsByName(String name) async {
    try {
      // Check by querying all projects and looking for name match
      // In production, this should be a dedicated API endpoint
      final projects = await getAll();
      return projects.any((p) => p.name.toLowerCase() == name.toLowerCase());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProjectStats> getStats(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id/stats');
      final dto = ProjectStatsDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProjectHealth> getHealth(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id/health');
      final dto = ProjectHealthDto.fromJson(response.data as Map<String, dynamic>);
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
          // Check if it's a guest project limit error
          if (message?.contains('Guest users are limited to') ?? false) {
            return GuestProjectLimitError(message: message!);
          }
          // Access denied (user doesn't own project or API key is invalid)
          return UnauthorizedError(
            message: message ?? 'Access denied. You do not own this project.',
          );
        case 404:
          return NotFoundError(message: message ?? 'Project not found');
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

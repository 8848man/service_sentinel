import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/ai_analysis.dart';
import '../models/incident_dto.dart';
import '../models/ai_analysis_dto.dart';
import 'incident_data_source.dart';

/// Remote incident data source implementation using REST API v3
/// Requires authentication (Firebase JWT or API Key per README_V3.md)
///
/// API Endpoints (v3 - Project-scoped):
/// - GET    /api/v3/projects/{project_id}/incidents                          - List incidents (with filters)
/// - GET    /api/v3/projects/{project_id}/incidents/{incident_id}            - Get incident details
/// - PATCH  /api/v3/projects/{project_id}/incidents/{incident_id}            - Update incident
/// - POST   /api/v3/projects/{project_id}/incidents/{incident_id}/acknowledge - Acknowledge incident
/// - POST   /api/v3/projects/{project_id}/incidents/{incident_id}/resolve    - Resolve incident
/// - GET    /api/v3/projects/{project_id}/incidents/{incident_id}/analysis   - Get AI analysis
/// - POST   /api/v3/projects/{project_id}/incidents/{incident_id}/analysis   - Request AI analysis
///
/// Authentication Rules (per README_V3.md):
/// - All endpoints require authentication
/// - Authorization header (Bearer token) takes priority over X-API-Key
/// - Project ownership is validated on every request
class RemoteIncidentDataSourceImpl implements RemoteIncidentDataSource {
  final Dio _dio;

  RemoteIncidentDataSourceImpl(this._dio);

  String _baseUrl(String projectId) =>
      '${AppConfig.apiUrl}/projects/$projectId/incidents';

  @override
  Future<List<Incident>> getAll({
    required int projectId,
    IncidentStatus? status,
    IncidentSeverity? severity,
    int? serviceId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status.name;
      if (severity != null) queryParams['severity'] = severity.name;
      if (serviceId != null) queryParams['service_id'] = serviceId;

      final response = await _dio.get(_baseUrl(projectId.toString()),
          queryParameters: queryParams);

      // Response structure: { total, items: [...] }
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      final List<dynamic> items = responseData['items'] as List<dynamic>;
      return items
          .map((json) =>
              IncidentDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Incident> getById({
    required int projectId,
    required int incidentId,
  }) async {
    try {
      final response =
          await _dio.get('${_baseUrl(projectId.toString())}/$incidentId');
      final dto = IncidentDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Incident> update({
    required int projectId,
    required int incidentId,
    required IncidentUpdate data,
  }) async {
    try {
      final dto = IncidentUpdateDto.fromDomain(data);
      final response = await _dio.patch(
        // Changed from PUT to PATCH
        '${_baseUrl(projectId.toString())}/$incidentId',
        data: dto.toJson(),
      );
      final incidentDto =
          IncidentDto.fromJson(response.data as Map<String, dynamic>);
      return incidentDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<Incident>> getByService({
    required int projectId,
    required int serviceId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      // Use getAll with serviceId filter
      return await getAll(
        projectId: projectId,
        serviceId: serviceId,
        skip: skip,
        limit: limit,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Incident> acknowledge({
    required int projectId,
    required int incidentId,
  }) async {
    try {
      final response = await _dio
          .post('${_baseUrl(projectId.toString())}/$incidentId/acknowledge');
      final dto = IncidentDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Incident> resolve({
    required int projectId,
    required int incidentId,
  }) async {
    try {
      final response = await _dio
          .post('${_baseUrl(projectId.toString())}/$incidentId/resolve');
      final dto = IncidentDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AiAnalysis?> getAnalysis({
    required int projectId,
    required int incidentId,
  }) async {
    try {
      final response = await _dio
          .get('${_baseUrl(projectId.toString())}/$incidentId/analysis');
      // If no analysis exists, backend returns 404 or null
      if (response.data == null) {
        return null;
      }

      final dto = AiAnalysisDto.fromJson(response.data as Map<String, dynamic>);
      return dto.toDomain();
    } on DioException catch (e) {
      // 404 means no analysis exists yet
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  @override
  Future<AiAnalysis> requestAnalysis({
    required int projectId,
    required int incidentId,
    bool forceReanalyze = false,
  }) async {
    try {
      final response = await _dio.post(
        '${_baseUrl(projectId.toString())}/$incidentId/analysis',
        data: {'force_reanalyze': forceReanalyze},
      );
      final dto = AiAnalysisDto.fromJson(response.data as Map<String, dynamic>);
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
            message: message ??
                'Authentication required. Provide Firebase JWT or API key.',
          );
        case 403:
          // Access denied (user doesn't own project or API key is invalid)
          return UnauthorizedError(
            message: message ?? 'Access denied. You do not own this project.',
          );
        case 404:
          return NotFoundError(message: message ?? 'Incident not found');
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

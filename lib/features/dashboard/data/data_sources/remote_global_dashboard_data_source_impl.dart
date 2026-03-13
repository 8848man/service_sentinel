import 'package:dio/dio.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/infrastructure/models/dashboard_metrics_dto.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/infrastructure/models/dashboard_overview_dto.dart';
import '../../domain/entities/global_dashboard_metrics.dart';
import '../models/global_dashboard_metrics_dto.dart';
import 'global_dashboard_data_source.dart';

/// Remote implementation of global dashboard data source using REST API v3
///
/// Endpoint: GET /api/v3/dashboard/global
/// Authentication: Not required (per README_v1.1.md)
///
/// This endpoint provides system-wide metrics:
/// - Total projects and services
/// - Service health breakdown (healthy, error, inactive)
/// - Active incident count
/// - Count of degraded projects
class RemoteGlobalDashboardDataSourceImpl implements DashboardDataSource {
  final Dio _dio;
  static const String _baseUrl = '/dashboard';
  static const String _prefix = '/projects';

  RemoteGlobalDashboardDataSourceImpl(this._dio);

  @override
  Future<GlobalDashboardMetrics> getGlobalMetrics() async {
    try {
      final response = await _dio.get('$_baseUrl/global');
      final dto = GlobalDashboardMetricsDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return dto.toDomain();
    } on DioException catch (e) {
      // Rethrow as-is, let repository handle error conversion
      rethrow;
    } catch (e) {
      // Unexpected error
      rethrow;
    }
  }

  @override
  Future<DashboardMetrics> getMetrics(
      {required int projectId, String period = '24h'}) async {
    try {
      final response = await _dio
          .get('$_prefix/$projectId/dashboard/metrics', queryParameters: {
        'project_id': projectId,
        'period': period,
      });
      final dto = DashboardMetricsDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return dto.toDomain();
    } on DioException catch (e) {
      // Rethrow as-is, let repository handle error conversion
      rethrow;
    } catch (e) {
      // Unexpected error
      rethrow;
    }
  }

  @override
  Future<DashboardOverview> getOverview({required int projectId}) async {
    try {
      final response = await _dio
          .get('$_prefix/$projectId/dashboard/overview', queryParameters: {
        'project_id': projectId,
      });
      final dto = DashboardOverviewDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return dto.toDomain();
    } on DioException catch (e) {
      // Rethrow as-is, let repository handle error conversion
      rethrow;
    } catch (e) {
      // Unexpected error
      rethrow;
    }
  }
}

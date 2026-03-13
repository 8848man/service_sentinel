import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/global_dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../data_sources/global_dashboard_data_source.dart';

/// Dashboard repository implementation
///
/// Delegates to GlobalDashboardDataSource for fetching metrics
/// Handles error conversion and Result wrapping
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;

  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<Result<GlobalDashboardMetrics>> getGlobalMetrics() async {
    try {
      final metrics = await _dataSource.getGlobalMetrics();
      return Result.success(metrics);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  AppError _handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is Exception) {
      return UndefinedError(message: error.toString());
    }

    return UndefinedError(message: 'Unknown error occurred');
  }

  @override
  Future<Result<DashboardOverview>> getOverview(
      {required int projectId}) async {
    try {
      final metrics = await _dataSource.getOverview(projectId: projectId);
      return Result.success(metrics);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<DashboardMetrics>> getMetrics({
    required int projectId,
    String period = '24h',
  }) async {
    try {
      final metrics =
          await _dataSource.getMetrics(projectId: projectId, period: period);
      return Result.success(metrics);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }
}

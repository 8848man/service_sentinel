import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';

import '../../../../core/error/result.dart';
import '../entities/global_dashboard_metrics.dart';

/// Dashboard repository interface
/// Provides global system-wide metrics across all projects
abstract class DashboardRepository {
  /// Get global dashboard metrics
  /// Returns system-wide statistics including:
  /// - Total projects and services
  /// - Service health breakdown
  /// - Active incidents
  /// - Degraded projects count
  Future<Result<GlobalDashboardMetrics>> getGlobalMetrics();

  Future<Result<DashboardOverview>> getOverview({required int projectId});

  /// Get dashboard metrics for a time period
  Future<Result<DashboardMetrics>> getMetrics({
    required int projectId,
    String period = '24h',
  });
}

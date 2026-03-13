import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';

import '../../domain/entities/global_dashboard_metrics.dart';

/// Abstract interface for global dashboard data source
/// Global dashboard provides system-wide metrics across all projects
abstract class DashboardDataSource {
  /// Get system-wide dashboard metrics
  /// Endpoint: GET /api/v3/dashboard/global
  /// Note: Per README_v1.1.md, this endpoint does not require authentication
  Future<GlobalDashboardMetrics> getGlobalMetrics();

  Future<DashboardOverview> getOverview({required int projectId});
  Future<DashboardMetrics> getMetrics({
    required int projectId,
    String period = '24h',
  });
}

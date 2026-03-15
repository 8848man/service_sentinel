import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_dashboard_metrics.freezed.dart';

/// System-wide dashboard metrics across all projects
///
/// Provides aggregated statistics for the entire system:
/// - Total count of projects and services
/// - Service health breakdown (healthy, error, inactive)
/// - Active incident count
/// - Count of projects with issues (degraded status)
@freezed
class GlobalDashboardMetrics with _$GlobalDashboardMetrics {
  const factory GlobalDashboardMetrics({
    required int totalProjects,
    required int totalServices,
    required int healthyServices,
    required int errorServices,
    required int inactiveServices,
    required int activeIncidents,
    required int degradedProjects,
  }) = _GlobalDashboardMetrics;
}

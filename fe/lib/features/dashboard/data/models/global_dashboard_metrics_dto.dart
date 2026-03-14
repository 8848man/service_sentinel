import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/global_dashboard_metrics.dart';

part 'global_dashboard_metrics_dto.freezed.dart';
part 'global_dashboard_metrics_dto.g.dart';

/// Global Dashboard Metrics Data Transfer Object
///
/// Maps backend JSON response to GlobalDashboardMetrics domain entity.
/// Backend endpoint: GET /api/v3/dashboard/global
@freezed
class GlobalDashboardMetricsDto with _$GlobalDashboardMetricsDto {
  const factory GlobalDashboardMetricsDto({
    @JsonKey(name: 'total_projects') required int totalProjects,
    @JsonKey(name: 'total_services') required int totalServices,
    @JsonKey(name: 'healthy_services') required int healthyServices,
    @JsonKey(name: 'error_services') required int errorServices,
    @JsonKey(name: 'inactive_services') required int inactiveServices,
    @JsonKey(name: 'active_incidents') required int activeIncidents,
    @JsonKey(name: 'degraded_projects') required int degradedProjects,
  }) = _GlobalDashboardMetricsDto;

  factory GlobalDashboardMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$GlobalDashboardMetricsDtoFromJson(json);

  const GlobalDashboardMetricsDto._();

  /// Convert DTO to domain entity
  GlobalDashboardMetrics toDomain() {
    return GlobalDashboardMetrics(
      totalProjects: totalProjects,
      totalServices: totalServices,
      healthyServices: healthyServices,
      errorServices: errorServices,
      inactiveServices: inactiveServices,
      activeIncidents: activeIncidents,
      degradedProjects: degradedProjects,
    );
  }
}

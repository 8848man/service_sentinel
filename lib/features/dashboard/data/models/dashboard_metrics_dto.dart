import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';

part 'dashboard_metrics_dto.freezed.dart';
part 'dashboard_metrics_dto.g.dart';

@freezed
class DashboardMetricsDto with _$DashboardMetricsDto {
  const factory DashboardMetricsDto({
    required int totalServicesMonitored,
    required int successfulChecksLastHour,
    required int failedChecksLastHour,
    required double avgCheckDurationMs,
    required int aiAnalysesPerformed,
    required double totalAiCostUsd,
    required int incidentsOpen,
    required int incidentsResolvedToday,
  }) = _DashboardMetricsDto;

  factory DashboardMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsDtoFromJson(json);

  const DashboardMetricsDto._();
  DashboardMetrics toDomain() {
    return DashboardMetrics(
      period: 'last_hour',
      totalHealthChecks: totalServicesMonitored,
      failedHealthChecks: failedChecksLastHour,
      uptimePercentage: totalServicesMonitored == 0
          ? 100.0
          : ((successfulChecksLastHour / totalServicesMonitored) * 100),
      averageLatencyMs: avgCheckDurationMs,
      totalIncidents: incidentsOpen + incidentsResolvedToday,
      openIncidents: incidentsOpen,
      aiAnalysesCount: aiAnalysesPerformed,
      aiTotalCostUsd: totalAiCostUsd,
    );
  }
}

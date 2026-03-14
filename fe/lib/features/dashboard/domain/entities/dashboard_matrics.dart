import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_matrics.freezed.dart';

@freezed
class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    required String period,
    required int totalHealthChecks,
    required int failedHealthChecks,
    required double uptimePercentage,
    required double averageLatencyMs,
    required int totalIncidents,
    required int openIncidents,
    required int aiAnalysesCount,
    required double aiTotalCostUsd,
  }) = _DashboardMetrics;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/service_health_summary.dart';

part 'dashboard_overview.freezed.dart';

@freezed
class DashboardOverview with _$DashboardOverview {
  const factory DashboardOverview({
    required int totalServices,
    required int healthyServices,
    required int unhealthyServices,
    required int totalOpenIncidents,
    required List<ServiceHealthSummary> services,
    required DateTime lastUpdated,
  }) = _DashboardOverview;
}

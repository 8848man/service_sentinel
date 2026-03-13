import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/infrastructure/models/service_health_summary_dto.dart';

part 'dashboard_overview_dto.freezed.dart';
part 'dashboard_overview_dto.g.dart';

@freezed
class DashboardOverviewDto with _$DashboardOverviewDto {
  const factory DashboardOverviewDto({
    @JsonKey(name: 'total_services') required int totalServices,
    @JsonKey(name: 'active_services') required int activeServices,
    @JsonKey(name: 'services_healthy') required int servicesHealthy,
    @JsonKey(name: 'services_warning') required int servicesWarning,
    @JsonKey(name: 'services_down') required int servicesDown,
    @JsonKey(name: 'services_unknown') required int servicesUnknown,
    @JsonKey(name: 'open_incidents') required int openIncidents,
    @JsonKey(name: 'critical_incidents') required int criticalIncidents,
    @JsonKey(name: 'error_services') required int errorServices,
    @JsonKey(name: 'inactive_services') required int inactiveServices,
    required List<ServiceHealthSummaryDto> services,
  }) = _DashboardOverviewDto;

  factory DashboardOverviewDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardOverviewDtoFromJson(json);

  const DashboardOverviewDto._();

  DashboardOverview toDomain() {
    return DashboardOverview(
      totalServices: totalServices,
      healthyServices: servicesHealthy,
      services: services.map((dto) => dto.toDomain()).toList(),
      unhealthyServices: totalServices - servicesHealthy,
      totalOpenIncidents: openIncidents,
      lastUpdated: DateTime.now(),
    );
  }
}

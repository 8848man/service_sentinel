import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/service_health_summary.dart';

part 'service_health_summary_dto.freezed.dart';
part 'service_health_summary_dto.g.dart';

@freezed
class ServiceHealthSummaryDto with _$ServiceHealthSummaryDto {
  const factory ServiceHealthSummaryDto({
    required int id,
    required String name,
    required String status,
    @JsonKey(name: 'last_check_is_alive') bool? lastCheckIsAlive,
    @JsonKey(name: 'last_check_latency_ms') int? lastCheckLatencyMs,
    @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
    @JsonKey(name: 'active_incident_id') int? activeIncidentId,
    @JsonKey(name: 'active_incident_severity')
    String? activeIncidentSeverity, // ✅ nullable
  }) = _ServiceHealthSummaryDto;

  factory ServiceHealthSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceHealthSummaryDtoFromJson(json);

  const ServiceHealthSummaryDto._();
  ServiceHealthSummary toDomain() {
    return ServiceHealthSummary(
      id: id,
      name: name,
      status: status,
      lastCheckIsAlive: lastCheckIsAlive ?? false,
      lastCheckLatencyMs: lastCheckLatencyMs ?? 0,
      lastCheckedAt: lastCheckedAt,
      activeIncidentId: activeIncidentId,
      activeIncidentSeverity: _parseSeverity(activeIncidentSeverity),
    );
  }
}

IncidentSeverity? _parseSeverity(String? raw) {
  if (raw == null || raw.isEmpty) return null;

  return IncidentSeverity.values.cast<IncidentSeverity?>().firstWhere(
        (e) => e!.name == raw,
        orElse: () => null,
      );
}

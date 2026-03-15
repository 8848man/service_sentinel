import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';

part 'service_health_summary.freezed.dart';

@freezed
class ServiceHealthSummary with _$ServiceHealthSummary {
  const factory ServiceHealthSummary({
    required int id,
    required String name,

    /// healthy | warning | down | unknown
    required String status,
    bool? lastCheckIsAlive,
    int? lastCheckLatencyMs,
    DateTime? lastCheckedAt,
    int? activeIncidentId,
    IncidentSeverity? activeIncidentSeverity,
  }) = _ServiceHealthSummary;
}

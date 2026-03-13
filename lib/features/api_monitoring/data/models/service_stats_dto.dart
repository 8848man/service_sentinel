import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/repositories/service_repository.dart';

part 'service_stats_dto.freezed.dart';
part 'service_stats_dto.g.dart';

/// Service Statistics Data Transfer Object
@freezed
class ServiceStatsDto with _$ServiceStatsDto {
  const factory ServiceStatsDto({
    @JsonKey(name: 'service_id') required String serviceId,
    @JsonKey(name: 'uptime_percentage') required double uptimePercentage,
    @JsonKey(name: 'total_checks') required int totalChecks,
    @JsonKey(name: 'successful_checks') required int successfulChecks,
    @JsonKey(name: 'failed_checks') required int failedChecks,
    @JsonKey(name: 'average_latency_ms') required double averageLatencyMs,
  }) = _ServiceStatsDto;

  const ServiceStatsDto._();

  factory ServiceStatsDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceStatsDtoFromJson(json);

  /// Convert DTO to domain entity
  ServiceStats toDomain() {
    return ServiceStats(
      serviceId: serviceId,
      uptimePercentage: uptimePercentage,
      totalChecks: totalChecks,
      successfulChecks: successfulChecks,
      failedChecks: failedChecks,
      averageLatencyMs: averageLatencyMs,
    );
  }
}

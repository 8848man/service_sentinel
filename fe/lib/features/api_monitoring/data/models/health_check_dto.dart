import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/health_check.dart';

part 'health_check_dto.freezed.dart';
part 'health_check_dto.g.dart';

/// Health Check Data Transfer Object
@freezed
class HealthCheckDto with _$HealthCheckDto {
  const factory HealthCheckDto({
    required String id,
    @JsonKey(name: 'service_id') required String serviceId,
    @JsonKey(name: 'is_alive') required bool isAlive,
    @JsonKey(name: 'status_code') int? statusCode,
    @JsonKey(name: 'latency_ms') int? latencyMs,
    @JsonKey(name: 'response_body') String? responseBody,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'error_type') String? errorType,
    @JsonKey(name: 'checked_at') required String checkedAt,
    @JsonKey(name: 'needs_analysis') required bool needsAnalysis,
  }) = _HealthCheckDto;

  const HealthCheckDto._();

  factory HealthCheckDto.fromJson(Map<String, dynamic> json) =>
      _$HealthCheckDtoFromJson(json);

  /// Convert DTO to domain entity
  HealthCheck toDomain() {
    return HealthCheck(
      id: id,
      serviceId: serviceId,
      isAlive: isAlive,
      statusCode: statusCode,
      latencyMs: latencyMs,
      responseBody: responseBody,
      errorMessage: errorMessage,
      errorType: errorType,
      checkedAt: DateTime.parse(checkedAt),
      needsAnalysis: needsAnalysis,
    );
  }
}

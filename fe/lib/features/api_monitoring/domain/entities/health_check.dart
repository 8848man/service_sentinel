import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_check.freezed.dart';

/// Health Check domain entity
/// Records the result of a service health check
@freezed
class HealthCheck with _$HealthCheck {
  const factory HealthCheck({
    required String id,
    required String serviceId,
    required bool isAlive,
    int? statusCode,
    int? latencyMs,
    String? responseBody,
    String? errorMessage,
    String? errorType,
    required DateTime checkedAt,
    required bool needsAnalysis,
  }) = _HealthCheck;

  const HealthCheck._();

  /// Check if this is a failure
  bool get isFailed => !isAlive;

  /// Check if this is a success
  bool get isSuccess => isAlive;
}

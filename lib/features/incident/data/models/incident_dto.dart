import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/incident.dart';

part 'incident_dto.freezed.dart';
part 'incident_dto.g.dart';

/// Incident Data Transfer Object
@freezed
class IncidentDto with _$IncidentDto {
  const factory IncidentDto({
    required int id, // 🔥 String → int
    @JsonKey(name: 'service_id') required int serviceId, // 🔥
    @JsonKey(name: 'trigger_check_id') int? triggerCheckId, // 🔥
    required String title,
    String? description,
    required String status,
    required String severity,
    @JsonKey(name: 'consecutive_failures') required int consecutiveFailures,
    @JsonKey(name: 'total_affected_checks') required int totalAffectedChecks,
    @JsonKey(name: 'detected_at') required String detectedAt,
    @JsonKey(name: 'resolved_at') String? resolvedAt,
    @JsonKey(name: 'acknowledged_at') String? acknowledgedAt,
    @JsonKey(name: 'ai_analysis_requested') required bool aiAnalysisRequested,
    @JsonKey(name: 'ai_analysis_completed') required bool aiAnalysisCompleted,
  }) = _IncidentDto;

  const IncidentDto._();

  factory IncidentDto.fromJson(Map<String, dynamic> json) =>
      _$IncidentDtoFromJson(json);

  /// Convert DTO to domain entity
  Incident toDomain() {
    return Incident(
      id: id,
      serviceId: serviceId,
      triggerCheckId: triggerCheckId,
      title: title,
      description: description,
      status: _parseStatus(status),
      severity: _parseSeverity(severity),
      consecutiveFailures: consecutiveFailures,
      totalAffectedChecks: totalAffectedChecks,
      detectedAt: DateTime.parse(detectedAt),
      resolvedAt: resolvedAt != null ? DateTime.parse(resolvedAt!) : null,
      acknowledgedAt:
          acknowledgedAt != null ? DateTime.parse(acknowledgedAt!) : null,
      aiAnalysisRequested: aiAnalysisRequested,
      aiAnalysisCompleted: aiAnalysisCompleted,
    );
  }

  IncidentStatus _parseStatus(String value) {
    return IncidentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IncidentStatus.open,
    );
  }

  IncidentSeverity _parseSeverity(String value) {
    return IncidentSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IncidentSeverity.medium,
    );
  }
}

/// Incident update DTO
@freezed
class IncidentUpdateDto with _$IncidentUpdateDto {
  const factory IncidentUpdateDto({
    String? title,
    String? description,
    String? status,
    String? severity,
  }) = _IncidentUpdateDto;

  factory IncidentUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$IncidentUpdateDtoFromJson(json);

  static IncidentUpdateDto fromDomain(IncidentUpdate data) {
    return IncidentUpdateDto(
      title: data.title,
      description: data.description,
      status: data.status?.name,
      severity: data.severity?.name,
    );
  }
}

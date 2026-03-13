import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/project_health.dart';
import '../../../../core/constants/enums.dart';

part 'project_health_dto.freezed.dart';
part 'project_health_dto.g.dart';

/// Project Health Data Transfer Object
///
/// Maps backend JSON response to ProjectHealth domain entity.
/// Backend endpoint: GET /api/v3/projects/{project_id}/health
@freezed
class ProjectHealthDto with _$ProjectHealthDto {
  const factory ProjectHealthDto({
    required String status,
    @JsonKey(name: 'total_services') required int totalServices,
    @JsonKey(name: 'healthy_services') required int healthyServices,
    @JsonKey(name: 'error_services') required int errorServices,
    @JsonKey(name: 'inactive_services') required int inactiveServices,
    @JsonKey(name: 'active_incidents') required int activeIncidents,
  }) = _ProjectHealthDto;

  factory ProjectHealthDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectHealthDtoFromJson(json);

  const ProjectHealthDto._();

  /// Convert DTO to domain entity
  ProjectHealth toDomain() {
    return ProjectHealth(
      status: _parseStatus(status),
      totalServices: totalServices,
      healthyServices: healthyServices,
      errorServices: errorServices,
      inactiveServices: inactiveServices,
      activeIncidents: activeIncidents,
    );
  }

  ProjectHealthStatus _parseStatus(String value) {
    switch (value.toUpperCase()) {
      case 'HEALTHY':
        return ProjectHealthStatus.healthy;
      case 'DEGRADED':
        return ProjectHealthStatus.degraded;
      case 'UNKNOWN':
        return ProjectHealthStatus.unknown;
      default:
        return ProjectHealthStatus.unknown; // Default fallback
    }
  }
}

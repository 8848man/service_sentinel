import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:service_sentinel_fe_v2/features/project/infrastructure/models/project_health_dto.dart';
import '../../domain/entities/project.dart';

part 'project_dto.freezed.dart';
part 'project_dto.g.dart';

/// Project Data Transfer Object
/// Maps to backend API response/request format
@freezed
class ProjectDto with _$ProjectDto {
  const factory ProjectDto({
    required int id,
    required String name,
    String? description,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'health') ProjectHealthDto? health,
  }) = _ProjectDto;

  const ProjectDto._();

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  /// Convert DTO to domain entity
  Project toDomain() {
    return Project(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isLocalOnly: false, // Server projects are never local-only
      health: health?.toDomain(),
    );
  }

  /// Convert domain entity to DTO
  static ProjectDto fromDomain(Project project) {
    return ProjectDto(
      id: project.id,
      name: project.name,
      description: project.description,
      isActive: project.isActive,
      createdAt: project.createdAt.toIso8601String(),
      updatedAt: project.updatedAt.toIso8601String(),
    );
  }
}

/// Project creation DTO
@freezed
class ProjectCreateDto with _$ProjectCreateDto {
  const factory ProjectCreateDto({
    required String name,
    String? description,
  }) = _ProjectCreateDto;

  factory ProjectCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectCreateDtoFromJson(json);

  static ProjectCreateDto fromDomain(ProjectCreate data) {
    return ProjectCreateDto(
      name: data.name,
      description: data.description,
    );
  }
}

/// Project update DTO
@freezed
class ProjectUpdateDto with _$ProjectUpdateDto {
  const factory ProjectUpdateDto({
    String? name,
    String? description,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _ProjectUpdateDto;

  factory ProjectUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectUpdateDtoFromJson(json);

  static ProjectUpdateDto fromDomain(ProjectUpdate data) {
    return ProjectUpdateDto(
      name: data.name,
      description: data.description,
      isActive: data.isActive,
    );
  }
}

/// Project statistics DTO
@freezed
class ProjectStatsDto with _$ProjectStatsDto {
  const factory ProjectStatsDto({
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'total_services') required int totalServices,
    @JsonKey(name: 'healthy_services') required int healthyServices,
    @JsonKey(name: 'unhealthy_services') required int unhealthyServices,
    @JsonKey(name: 'open_incidents') required int openIncidents,
  }) = _ProjectStatsDto;

  const ProjectStatsDto._();

  factory ProjectStatsDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectStatsDtoFromJson(json);

  ProjectStats toDomain() {
    return ProjectStats(
      projectId: projectId,
      totalServices: totalServices,
      healthyServices: healthyServices,
      unhealthyServices: unhealthyServices,
      openIncidents: openIncidents,
    );
  }
}

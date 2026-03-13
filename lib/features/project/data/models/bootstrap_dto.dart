import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/bootstrap.dart';
import 'project_dto.dart';

part 'bootstrap_dto.freezed.dart';
part 'bootstrap_dto.g.dart';

/// Bootstrap response DTO
/// Maps to backend API response format for POST /v3/projects/bootstrap
@freezed
class BootstrapResponseDto with _$BootstrapResponseDto {
  const factory BootstrapResponseDto({
    required ProjectDto project,
    @JsonKey(name: 'api_key') required String apiKey, // Snake case from backend
    String? message,
  }) = _BootstrapResponseDto;

  const BootstrapResponseDto._();

  factory BootstrapResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BootstrapResponseDtoFromJson(json);

  /// Convert DTO to domain entity
  BootstrapResponse toDomain() {
    return BootstrapResponse(
      project: project.toDomain(),
      apiKey: apiKey,
      message: message,
    );
  }
}

/// Bootstrap request DTO
@freezed
class BootstrapRequestDto with _$BootstrapRequestDto {
  const factory BootstrapRequestDto({
    required String name,
    String? description,
  }) = _BootstrapRequestDto;

  const BootstrapRequestDto._();

  factory BootstrapRequestDto.fromJson(Map<String, dynamic> json) =>
      _$BootstrapRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
      };

  /// Convert domain entity to DTO
  static BootstrapRequestDto fromDomain(BootstrapRequest data) {
    return BootstrapRequestDto(
      name: data.name,
      description: data.description,
    );
  }
}

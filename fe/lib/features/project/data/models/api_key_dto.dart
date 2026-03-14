import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/api_key.dart';

part 'api_key_dto.freezed.dart';
part 'api_key_dto.g.dart';

/// API Key Data Transfer Object
@freezed
class ApiKeyDto with _$ApiKeyDto {
  const factory ApiKeyDto({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    required String name,
    String? description,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'last_used_at') String? lastUsedAt,
    @JsonKey(name: 'usage_count') required int usageCount,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
    // Key value only present at creation
    @JsonKey(name: 'key_value') String? keyValue,
  }) = _ApiKeyDto;

  const ApiKeyDto._();

  factory ApiKeyDto.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyDtoFromJson(json);

  /// Convert DTO to domain entity
  ApiKey toDomain() {
    return ApiKey(
      id: id,
      projectId: projectId,
      name: name,
      description: description,
      isActive: isActive,
      lastUsedAt: lastUsedAt != null ? DateTime.parse(lastUsedAt!) : null,
      usageCount: usageCount,
      createdAt: DateTime.parse(createdAt),
      expiresAt: expiresAt != null ? DateTime.parse(expiresAt!) : null,
      keyValue: keyValue ?? '',
    );
  }
}

/// API Key creation DTO
@freezed
class ApiKeyCreateDto with _$ApiKeyCreateDto {
  const factory ApiKeyCreateDto({
    required String name,
    String? description,
    @JsonKey(name: 'expires_at') String? expiresAt,
  }) = _ApiKeyCreateDto;

  factory ApiKeyCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyCreateDtoFromJson(json);

  static ApiKeyCreateDto fromDomain(ApiKeyCreate data) {
    return ApiKeyCreateDto(
      name: data.name,
      description: data.description,
      expiresAt: data.expiresAt?.toIso8601String(),
    );
  }
}

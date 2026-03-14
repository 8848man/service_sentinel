import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/service.dart';

part 'service_dto.freezed.dart';
part 'service_dto.g.dart';

/// Service Data Transfer Object
@freezed
class ServiceDto with _$ServiceDto {
  const factory ServiceDto({
    required int id, // 🔥 String → int
    @JsonKey(name: 'project_id') int? projectId, // 🔥 nullable
    required String name,
    String? description,
    @JsonKey(name: 'endpoint_url') required String endpointUrl,
    @JsonKey(name: 'http_method') required String httpMethod,
    @JsonKey(name: 'service_type') required String serviceType,
    Map<String, String>? headers, // 🔥 안전하게
    @JsonKey(name: 'request_body') String? requestBody,
    @JsonKey(name: 'expected_status_codes')
    required List<int> expectedStatusCodes,
    @JsonKey(name: 'timeout_seconds') required int timeoutSeconds,
    @JsonKey(name: 'check_interval_seconds') required int checkIntervalSeconds,
    @JsonKey(name: 'failure_threshold') required int failureThreshold,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'service_state') String? serviceState,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'last_checked_at') String? lastCheckedAt,
  }) = _ServiceDto;

  const ServiceDto._();

  factory ServiceDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceDtoFromJson(json);

  /// Convert DTO to domain entity
  Service toDomain() {
    return Service(
      id: id, // 🔥 int 그대로
      projectId: projectId ?? 0, // 🔥 nullable 처리
      name: name,
      description: description,
      endpointUrl: endpointUrl,
      httpMethod: _parseHttpMethod(httpMethod),
      serviceType: _parseServiceType(serviceType),
      headers: headers,
      requestBody: requestBody,
      expectedStatusCodes: expectedStatusCodes,
      timeoutSeconds: timeoutSeconds,
      checkIntervalSeconds: checkIntervalSeconds,
      failureThreshold: failureThreshold,
      isActive: isActive,
      serviceState: serviceState != null ? _parseServiceState(serviceState!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      lastCheckedAt:
          lastCheckedAt != null ? DateTime.parse(lastCheckedAt!) : null,
    );
  }

  HttpMethod _parseHttpMethod(String value) {
    return HttpMethod.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => HttpMethod.get,
    );
  }

  ServiceType _parseServiceType(String value) {
    switch (value) {
      case 'http_api':
        return ServiceType.httpApi;
      case 'https_api':
        return ServiceType.httpsApi;
      case 'gcp_endpoint':
        return ServiceType.gcpEndpoint;
      case 'firebase':
        return ServiceType.firebase;
      case 'websocket':
        return ServiceType.websocket;
      case 'grpc':
        return ServiceType.grpc;
      default:
        return ServiceType.httpsApi;
    }
  }

  ServiceState _parseServiceState(String value) {
    switch (value.toLowerCase()) {
      case 'healthy':
        return ServiceState.healthy;
      case 'error':
        return ServiceState.error;
      case 'inactive':
        return ServiceState.inactive;
      default:
        return ServiceState.healthy; // Default fallback
    }
  }
}

/// Service creation DTO
@freezed
class ServiceCreateDto with _$ServiceCreateDto {
  const factory ServiceCreateDto({
    required String name,
    String? description,
    @JsonKey(name: 'endpoint_url') required String endpointUrl,
    @JsonKey(name: 'http_method') required String httpMethod,
    @JsonKey(name: 'service_type') required String serviceType,
    Map<String, String>? headers,
    @JsonKey(name: 'request_body') String? requestBody,
    @JsonKey(name: 'expected_status_codes')
    required List<int> expectedStatusCodes,
    @JsonKey(name: 'timeout_seconds') required int timeoutSeconds,
    @JsonKey(name: 'check_interval_seconds') required int checkIntervalSeconds,
    @JsonKey(name: 'failure_threshold') required int failureThreshold,
  }) = _ServiceCreateDto;

  factory ServiceCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceCreateDtoFromJson(json);

  static ServiceCreateDto fromDomain(ServiceCreate data) {
    return ServiceCreateDto(
      name: data.name,
      description: data.description,
      endpointUrl: data.endpointUrl,
      httpMethod: data.httpMethod.value,
      serviceType: data.serviceType.serverValue,
      headers: data.headers,
      requestBody: data.requestBody,
      expectedStatusCodes: data.expectedStatusCodes,
      timeoutSeconds: data.timeoutSeconds,
      checkIntervalSeconds: data.checkIntervalSeconds,
      failureThreshold: data.failureThreshold,
    );
  }
}

/// Service update DTO
@freezed
class ServiceUpdateDto with _$ServiceUpdateDto {
  const factory ServiceUpdateDto({
    String? name,
    String? description,
    @JsonKey(name: 'endpoint_url') String? endpointUrl,
    @JsonKey(name: 'http_method') String? httpMethod,
    @JsonKey(name: 'service_type') String? serviceType,
    Map<String, String>? headers,
    @JsonKey(name: 'request_body') String? requestBody,
    @JsonKey(name: 'expected_status_codes') List<int>? expectedStatusCodes,
    @JsonKey(name: 'timeout_seconds') int? timeoutSeconds,
    @JsonKey(name: 'check_interval_seconds') int? checkIntervalSeconds,
    @JsonKey(name: 'failure_threshold') int? failureThreshold,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _ServiceUpdateDto;

  factory ServiceUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceUpdateDtoFromJson(json);

  static ServiceUpdateDto fromDomain(ServiceUpdate data) {
    return ServiceUpdateDto(
      name: data.name,
      description: data.description,
      endpointUrl: data.endpointUrl,
      httpMethod: data.httpMethod?.value,
      serviceType: data.serviceType?.serverValue,
      headers: data.headers,
      requestBody: data.requestBody,
      expectedStatusCodes: data.expectedStatusCodes,
      timeoutSeconds: data.timeoutSeconds,
      checkIntervalSeconds: data.checkIntervalSeconds,
      failureThreshold: data.failureThreshold,
      isActive: data.isActive,
    );
  }
}

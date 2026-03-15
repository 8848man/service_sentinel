import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/enums.dart';

part 'service.freezed.dart';

/// Service (API) domain entity
/// Represents a monitored API endpoint
@freezed
class Service with _$Service {
  const factory Service({
    required int id,
    required int projectId,
    required String name,
    String? description,
    required String endpointUrl,
    required HttpMethod httpMethod,
    required ServiceType serviceType,
    Map<String, String>? headers,
    String? requestBody,
    required List<int> expectedStatusCodes,
    required int timeoutSeconds,
    required int checkIntervalSeconds,
    required int failureThreshold,
    required bool isActive,
    ServiceState? serviceState,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastCheckedAt,
  }) = _Service;

  const Service._();

  /// Get health status display color
  /// This is derived from latest health check (handled in UI/Application layer)
}

/// Service creation input
@freezed
class ServiceCreate with _$ServiceCreate {
  const factory ServiceCreate({
    required String name,
    String? description,
    required String endpointUrl,
    required HttpMethod httpMethod,
    required ServiceType serviceType,
    Map<String, String>? headers,
    String? requestBody,
    @Default([200]) List<int> expectedStatusCodes,
    @Default(10) int timeoutSeconds,
    @Default(60) int checkIntervalSeconds,
    @Default(3) int failureThreshold,
  }) = _ServiceCreate;
}

/// Service update input
@freezed
class ServiceUpdate with _$ServiceUpdate {
  const factory ServiceUpdate({
    String? name,
    String? description,
    String? endpointUrl,
    HttpMethod? httpMethod,
    ServiceType? serviceType,
    Map<String, String>? headers,
    String? requestBody,
    List<int>? expectedStatusCodes,
    int? timeoutSeconds,
    int? checkIntervalSeconds,
    int? failureThreshold,
    bool? isActive,
  }) = _ServiceUpdate;
}

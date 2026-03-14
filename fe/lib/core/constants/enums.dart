import 'package:flutter/material.dart';
import 'package:service_sentinel_fe_v2/core/extensions/context_extensions.dart';

/// Source of truth for data
enum SourceOfTruth {
  local, // Guest mode - Local DB
  server, // Authenticated mode - Server DB
}

/// Service types
enum ServiceType {
  httpApi,
  httpsApi,
  gcpEndpoint,
  firebase,
  websocket,
  grpc,
}

/// HTTP methods
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}

/// Incident status
enum IncidentStatus {
  open,
  investigating,
  resolved,
  acknowledged,
}

/// Incident severity
enum IncidentSeverity {
  critical,
  high,
  medium,
  low,
}

/// Service health state
/// Reflects the current operational status of a service
enum ServiceState {
  healthy,
  error,
  inactive,
}

/// Project health status
/// Aggregated health status calculated from all services and incidents
enum ProjectHealthStatus {
  healthy,
  degraded,
  unknown,
}

extension ServiceTypeExtension on ServiceType {
  String displayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case ServiceType.httpApi:
        return l10n.service_type_http_api;
      case ServiceType.httpsApi:
        return l10n.service_type_https_api;
      case ServiceType.gcpEndpoint:
        return l10n.service_type_gcp_endpoint;
      case ServiceType.firebase:
        return l10n.service_type_firebase;
      case ServiceType.websocket:
        return l10n.service_type_websocket;
      case ServiceType.grpc:
        return l10n.service_type_grpc;
    }
  }

  String get serverValue {
    switch (this) {
      case ServiceType.httpApi:
        return 'http_api';
      case ServiceType.httpsApi:
        return 'https_api';
      case ServiceType.gcpEndpoint:
        return 'gcp_endpoint';
      case ServiceType.firebase:
        return 'firebase';
      case ServiceType.websocket:
        return 'websocket';
      case ServiceType.grpc:
        return 'grpc';
    }
  }
}

extension HttpMethodExtension on HttpMethod {
  String displayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case HttpMethod.get:
        return l10n.http_method_get;
      case HttpMethod.post:
        return l10n.http_method_post;
      case HttpMethod.put:
        return l10n.http_method_put;
      case HttpMethod.delete:
        return l10n.http_method_delete;
      case HttpMethod.patch:
        return l10n.http_method_patch;
      case HttpMethod.head:
        return l10n.http_method_head;
    }
  }

  String get value {
    return name.toUpperCase();
  }
}

extension IncidentStatusExtension on IncidentStatus {
  String displayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case IncidentStatus.open:
        return l10n.incident_status_open;
      case IncidentStatus.investigating:
        return l10n.incident_status_investigating;
      case IncidentStatus.resolved:
        return l10n.incident_status_resolved;
      case IncidentStatus.acknowledged:
        return l10n.incident_status_acknowledged;
    }
  }
}

extension IncidentSeverityExtension on IncidentSeverity {
  String displayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case IncidentSeverity.critical:
        return l10n.incident_severity_critical;
      case IncidentSeverity.high:
        return l10n.incident_severity_high;
      case IncidentSeverity.medium:
        return l10n.incident_severity_medium;
      case IncidentSeverity.low:
        return l10n.incident_severity_low;
    }
  }
}

extension ServiceStateExtension on ServiceState {
  String displayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case ServiceState.healthy:
        return l10n.service_state_healthy;
      case ServiceState.error:
        return l10n.service_state_error;
      case ServiceState.inactive:
        return l10n.service_state_inactive;
    }
  }

  String get serverValue {
    return name; // healthy, error, inactive
  }
}

extension ProjectHealthStatusExtension on ProjectHealthStatus {
  String displayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case ProjectHealthStatus.healthy:
        return l10n.project_health_healthy;
      case ProjectHealthStatus.degraded:
        return l10n.project_health_degraded;
      case ProjectHealthStatus.unknown:
        return l10n.project_health_unknown;
    }
  }

  String get serverValue {
    return name.toUpperCase(); // HEALTHY, DEGRADED, UNKNOWN
  }
}

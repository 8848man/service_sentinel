import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/enums.dart';

part 'incident.freezed.dart';

/// Incident domain entity
/// Represents a service failure event
@freezed
class Incident with _$Incident {
  const factory Incident({
    required int id,
    required int serviceId,
    int? triggerCheckId,
    required String title,
    String? description,
    required IncidentStatus status,
    required IncidentSeverity severity,
    required int consecutiveFailures,
    required int totalAffectedChecks,
    required DateTime detectedAt,
    DateTime? resolvedAt,
    DateTime? acknowledgedAt,
    required bool aiAnalysisRequested,
    required bool aiAnalysisCompleted,
  }) = _Incident;

  const Incident._();

  /// Check if incident is open
  bool get isOpen => status == IncidentStatus.open;

  /// Check if incident is resolved
  bool get isResolved => status == IncidentStatus.resolved;

  /// Check if incident has AI analysis
  bool get hasAnalysis => aiAnalysisCompleted;
}

/// Incident update input
@freezed
class IncidentUpdate with _$IncidentUpdate {
  const factory IncidentUpdate({
    String? title,
    String? description,
    IncidentStatus? status,
    IncidentSeverity? severity,
  }) = _IncidentUpdate;
}

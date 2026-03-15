import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/incident.dart';
import 'incident_data_source.dart';

/// Local incident data source implementation using Hive
/// Stores incidents locally for guest users
///
/// Storage format: JSON in Hive box
/// Box name: 'incidents'
///
/// Note: In local mode, incidents are typically created by the health monitoring
/// background service, not directly by users. This implementation provides basic
/// storage for viewing incidents.
class LocalIncidentDataSourceImpl implements LocalIncidentDataSource {
  static const String _boxName = 'incidents';
  final _uuid = const Uuid();

  Future<Box<Map>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Map>(_boxName);
    }
    return Hive.box<Map>(_boxName);
  }

  @override
  Future<List<Incident>> getAll({
    required int projectId,
    IncidentStatus? status,
    IncidentSeverity? severity,
    int? serviceId,
    int skip = 0,
    int limit = 100,
  }) async {
    final box = await _getBox();
    final incidents = <Incident>[];

    // Note: Local storage doesn't directly track projectId on incidents
    // In practice, we rely on services being project-scoped
    for (var key in box.keys) {
      final json = Map<String, dynamic>.from(box.get(key) as Map);
      final incident = _jsonToDomain(json);

      // Apply filters
      if (status != null && incident.status != status) continue;
      if (severity != null && incident.severity != severity) continue;
      if (serviceId != null && incident.serviceId != serviceId) continue;

      incidents.add(incident);
    }

    // Sort by detectedAt descending (newest first)
    incidents.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

    // Apply pagination
    if (skip >= incidents.length) {
      return [];
    }
    final end = (skip + limit).clamp(0, incidents.length);
    return incidents.sublist(skip, end);
  }

  @override
  Future<Incident> getById({
    required int projectId,
    required int incidentId,
  }) async {
    final box = await _getBox();
    final json = box.get(incidentId);

    if (json == null) {
      throw Exception('Incident not found: $incidentId');
    }

    // Note: We don't verify projectId in local storage
    return _jsonToDomain(Map<String, dynamic>.from(json as Map));
  }

  @override
  Future<Incident> update({
    required int projectId,
    required int incidentId,
    required IncidentUpdate data,
  }) async {
    final box = await _getBox();
    final existing =
        await getById(projectId: projectId, incidentId: incidentId);

    final updated = Incident(
      id: existing.id,
      serviceId: existing.serviceId,
      triggerCheckId: existing.triggerCheckId,
      title: data.title ?? existing.title,
      description: data.description ?? existing.description,
      status: data.status ?? existing.status,
      severity: data.severity ?? existing.severity,
      consecutiveFailures: existing.consecutiveFailures,
      totalAffectedChecks: existing.totalAffectedChecks,
      detectedAt: existing.detectedAt,
      resolvedAt: data.status == IncidentStatus.resolved
          ? DateTime.now()
          : existing.resolvedAt,
      acknowledgedAt: data.status == IncidentStatus.acknowledged
          ? DateTime.now()
          : existing.acknowledgedAt,
      aiAnalysisRequested: existing.aiAnalysisRequested,
      aiAnalysisCompleted: existing.aiAnalysisCompleted,
    );

    final json = _domainToJson(updated);
    await box.put(incidentId, json);

    return updated;
  }

  @override
  Future<List<Incident>> getByService({
    required int projectId,
    required int serviceId,
    int skip = 0,
    int limit = 100,
  }) async {
    return await getAll(
      projectId: projectId,
      serviceId: serviceId,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<void> clearAllForProject(String projectId) async {
    // For local storage, we don't have direct project ID on incidents
    // In a real scenario, we'd need to look up services first
    // For now, clear all incidents (simple approach for local storage)
    final box = await _getBox();
    await box.clear();
  }

  /// Helper method to create an incident (used by background monitoring)
  Future<Incident> create({
    required String serviceId,
    required String title,
    String? description,
    required IncidentSeverity severity,
    required int consecutiveFailures,
    String? triggerCheckId,
  }) async {
    // final box = await _getBox();
    // final now = DateTime.now();

    // final incident = Incident(
    //   id: _uuid.v4(),
    //   serviceId: serviceId,
    //   triggerCheckId: triggerCheckId,
    //   title: title,
    //   description: description,
    //   status: IncidentStatus.open,
    //   severity: severity,
    //   consecutiveFailures: consecutiveFailures,
    //   totalAffectedChecks: consecutiveFailures,
    //   detectedAt: now,
    //   aiAnalysisRequested: false,
    //   aiAnalysisCompleted: false,
    // );

    // final json = _domainToJson(incident);
    // await box.put(incident.id, json);

    // return incident;
    throw UnimplementedError();
  }

  Map<String, dynamic> _domainToJson(Incident incident) {
    return {
      'id': incident.id,
      'service_id': incident.serviceId,
      'trigger_check_id': incident.triggerCheckId,
      'title': incident.title,
      'description': incident.description,
      'status': incident.status.name,
      'severity': incident.severity.name,
      'consecutive_failures': incident.consecutiveFailures,
      'total_affected_checks': incident.totalAffectedChecks,
      'detected_at': incident.detectedAt.toIso8601String(),
      'resolved_at': incident.resolvedAt?.toIso8601String(),
      'acknowledged_at': incident.acknowledgedAt?.toIso8601String(),
      'ai_analysis_requested': incident.aiAnalysisRequested,
      'ai_analysis_completed': incident.aiAnalysisCompleted,
    };
  }

  Incident _jsonToDomain(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      serviceId: json['service_id'],
      triggerCheckId: json['trigger_check_id'],
      title: json['title'] as String,
      description: json['description'] as String?,
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IncidentStatus.open,
      ),
      severity: IncidentSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => IncidentSeverity.medium,
      ),
      consecutiveFailures: json['consecutive_failures'] as int,
      totalAffectedChecks: json['total_affected_checks'] as int,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      aiAnalysisRequested: json['ai_analysis_requested'] as bool? ?? false,
      aiAnalysisCompleted: json['ai_analysis_completed'] as bool? ?? false,
    );
  }
}

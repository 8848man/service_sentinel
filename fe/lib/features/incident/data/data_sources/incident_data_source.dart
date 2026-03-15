import '../../../../core/constants/enums.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/ai_analysis.dart';

/// Abstract interface for incident data sources
/// v2 API - All operations are project-scoped
abstract class IncidentDataSource {
  /// Get all incidents with optional filters
  Future<List<Incident>> getAll({
    required int projectId,
    IncidentStatus? status,
    IncidentSeverity? severity,
    int? serviceId,
    int skip = 0,
    int limit = 100,
  });

  /// Get incident by ID
  Future<Incident> getById({
    required int projectId,
    required int incidentId,
  });

  /// Update incident
  Future<Incident> update({
    required int projectId,
    required int incidentId,
    required IncidentUpdate data,
  });

  /// Get incidents for specific service
  Future<List<Incident>> getByService({
    required int projectId,
    required int serviceId,
    int skip = 0,
    int limit = 100,
  });
}

/// Local data source interface (Hive)
abstract class LocalIncidentDataSource extends IncidentDataSource {
  /// Clear all incidents for a project
  Future<void> clearAllForProject(String projectId);
}

/// Remote data source interface (REST API)
/// Requires API key authentication via X-API-Key header
/// v2 API - All operations are project-scoped
abstract class RemoteIncidentDataSource extends IncidentDataSource {
  /// Acknowledge incident (returns updated incident)
  Future<Incident> acknowledge({
    required int projectId,
    required int incidentId,
  });

  /// Resolve incident (returns updated incident)
  Future<Incident> resolve({
    required int projectId,
    required int incidentId,
  });

  /// Get AI analysis for incident
  Future<AiAnalysis?> getAnalysis({
    required int projectId,
    required int incidentId,
  });

  /// Request AI analysis (returns analysis)
  Future<AiAnalysis> requestAnalysis({
    required int projectId,
    required int incidentId,
    bool forceReanalyze = false,
  });
}

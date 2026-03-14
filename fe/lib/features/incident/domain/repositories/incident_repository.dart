import '../../../../core/error/result.dart';
import '../../../../core/constants/enums.dart';
import '../entities/incident.dart';
import '../entities/ai_analysis.dart';

/// Incident repository interface
/// Abstracts incident management operations
abstract class IncidentRepository {
  /// Get all incidents for current project
  /// Supports filtering by status, severity, and service
  Future<Result<List<Incident>>> getAll({
    IncidentStatus? status,
    IncidentSeverity? severity,
    int? serviceId,
  });

  /// Get incident by ID
  Future<Result<Incident>> getById(int id);

  /// Update incident
  Future<Result<Incident>> update(int id, IncidentUpdate data);

  /// Acknowledge incident
  Future<Result<Incident>> acknowledge(int id);

  /// Resolve incident
  Future<Result<Incident>> resolve(int id);

  /// Get AI analysis for incident
  Future<Result<AiAnalysis?>> getAnalysis(int id);

  /// Request AI analysis for incident
  /// Backend will process asynchronously
  Future<Result<void>> requestAnalysis(int id);

  /// Get incidents for specific service
  Future<Result<List<Incident>>> getByService(int serviceId);
}

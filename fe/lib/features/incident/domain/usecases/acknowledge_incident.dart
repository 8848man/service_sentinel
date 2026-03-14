import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/incident.dart';
import '../repositories/incident_repository.dart';

/// Use case: Acknowledge Incident
/// Acknowledges an incident to indicate it has been seen and is being investigated
class AcknowledgeIncident {
  final IncidentRepository _repository;

  AcknowledgeIncident({
    required IncidentRepository repository,
  }) : _repository = repository;

  /// Acknowledge incident by ID
  Future<Result<Incident>> execute(int incidentId) async {
    // Validate input
    if (incidentId <= 0) {
      return Result.failure(
        ValidationError(message: 'Incident ID is required'),
      );
    }

    // Acknowledge via repository
    return await _repository.acknowledge(incidentId);
  }
}

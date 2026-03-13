import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/incident.dart';
import '../repositories/incident_repository.dart';

/// Use case: Resolve Incident
/// Marks an incident as resolved
class ResolveIncident {
  final IncidentRepository _repository;

  ResolveIncident({
    required IncidentRepository repository,
  }) : _repository = repository;

  /// Resolve incident by ID
  Future<Result<Incident>> execute(int incidentId) async {
    // Validate input
    if (incidentId <= 0) {
      return Result.failure(
        ValidationError(message: 'Incident ID is required'),
      );
    }

    // Resolve via repository
    return await _repository.resolve(incidentId);
  }
}

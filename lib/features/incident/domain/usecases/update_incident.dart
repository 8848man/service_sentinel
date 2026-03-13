import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../entities/incident.dart';
import '../repositories/incident_repository.dart';

/// Use case: Update Incident
/// Updates incident details (title, description, severity, status)
class UpdateIncident {
  final IncidentRepository _repository;

  UpdateIncident({
    required IncidentRepository repository,
  }) : _repository = repository;

  /// Update incident by ID
  Future<Result<Incident>> execute(
    int incidentId,
    IncidentUpdate data,
  ) async {
    // Validate incident ID
    if (incidentId <= 0) {
      return Result.failure(
        ValidationError(message: 'Incident ID is required'),
      );
    }

    // Validate that at least one field is provided
    if (data.title == null &&
        data.description == null &&
        data.severity == null &&
        data.status == null) {
      return Result.failure(
        ValidationError(
          message: 'At least one field must be provided for update',
        ),
      );
    }

    // Validate title if provided
    if (data.title != null && data.title!.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Title cannot be empty'),
      );
    }

    // Validate title length
    if (data.title != null && data.title!.length > 200) {
      return Result.failure(
        ValidationError(
          message: 'Title cannot exceed 200 characters',
        ),
      );
    }

    // Update via repository
    return await _repository.update(incidentId, data);
  }
}

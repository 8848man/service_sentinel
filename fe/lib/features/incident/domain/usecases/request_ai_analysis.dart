import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../repositories/incident_repository.dart';

/// Use case: Request AI Analysis
/// Requests AI analysis for an incident
/// Backend processes asynchronously
class RequestAiAnalysis {
  final IncidentRepository _repository;

  RequestAiAnalysis({
    required IncidentRepository repository,
  }) : _repository = repository;

  Future<Result<void>> execute(int incidentId) async {
    if (incidentId <= 0) {
      return Result.failure(
        ValidationError(message: 'Incident ID is required'),
      );
    }

    return await _repository.requestAnalysis(incidentId);
  }
}

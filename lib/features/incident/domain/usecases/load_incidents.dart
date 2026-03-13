import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/constants/enums.dart';
import '../entities/incident.dart';
import '../repositories/incident_repository.dart';

/// Use case: Load Incidents
/// Loads incidents with optional filtering
class LoadIncidents {
  final IncidentRepository _repository;

  LoadIncidents({
    required IncidentRepository repository,
  }) : _repository = repository;

  /// Load all incidents
  Future<Result<List<Incident>>> execute() async {
    return await _repository.getAll();
  }

  /// Load incidents with filters
  Future<Result<List<Incident>>> executeFiltered({
    IncidentStatus? status,
    IncidentSeverity? severity,
    int? serviceId,
  }) async {
    return await _repository.getAll(
      status: status,
      severity: severity,
      serviceId: serviceId,
    );
  }

  /// Load only open incidents
  Future<Result<List<Incident>>> executeOpen() async {
    return await _repository.getAll(status: IncidentStatus.open);
  }

  /// Load only critical incidents
  Future<Result<List<Incident>>> executeCritical() async {
    return await _repository.getAll(severity: IncidentSeverity.critical);
  }

  /// Load incidents for specific service
  Future<Result<List<Incident>>> executeForService(int serviceId) async {
    if (serviceId <= 0) {
      return Result.failure(
        ValidationError(message: 'Service ID is required'),
      );
    }

    return await _repository.getByService(serviceId);
  }
}

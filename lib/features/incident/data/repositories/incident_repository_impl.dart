import '../../../../core/data/data_source_mode.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/repositories/incident_repository.dart';
import '../data_sources/incident_data_source.dart';

/// Incident repository implementation - Auth-aware facade
///
/// Delegates to appropriate data source based on authentication state:
/// - Guest/unauthenticated → LocalIncidentDataSource (Hive)
/// - Authenticated → RemoteIncidentDataSource (REST API)
///
/// This repository is UI-agnostic and observes DataSourceMode instead of
/// directly checking authentication state.
class IncidentRepositoryImpl implements IncidentRepository {
  final LocalIncidentDataSource _localDataSource;
  final RemoteIncidentDataSource _remoteDataSource;
  final DataSourceMode Function() _getDataSourceMode;
  final int projectId;

  IncidentRepositoryImpl({
    required LocalIncidentDataSource localDataSource,
    required RemoteIncidentDataSource remoteDataSource,
    required DataSourceMode Function() getDataSourceMode,
    required this.projectId,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _getDataSourceMode = getDataSourceMode;

  IncidentDataSource get _currentDataSource {
    return _remoteDataSource;
    // final mode = _getDataSourceMode();
    // return mode.isLocal ? _localDataSource : _remoteDataSource;
  }

  @override
  Future<Result<List<Incident>>> getAll({
    IncidentStatus? status,
    IncidentSeverity? severity,
    int? serviceId,
  }) async {
    try {
      final incidents = await _currentDataSource.getAll(
        projectId: projectId,
        status: status,
        severity: severity,
        serviceId: serviceId,
      );

      return Result.success(incidents);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Incident>> getById(int id) async {
    try {
      final incident = await _currentDataSource.getById(
          projectId: projectId, incidentId: id);
      return Result.success(incident);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Incident>> update(int id, IncidentUpdate data) async {
    try {
      final incident = await _currentDataSource.update(
          projectId: projectId, incidentId: id, data: data);
      return Result.success(incident);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Incident>> acknowledge(int id) async {
    try {
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        // For local, update status to acknowledged
        final incident = await _localDataSource.update(
          projectId: projectId,
          incidentId: id,
          data: const IncidentUpdate(status: IncidentStatus.acknowledged),
        );
        return Result.success(incident);
      }

      final incident = await _remoteDataSource.acknowledge(
          projectId: projectId, incidentId: id);
      return Result.success(incident);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Incident>> resolve(int id) async {
    try {
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        // For local, update status to resolved
        final incident = await _localDataSource.update(
          projectId: projectId,
          incidentId: id,
          data: const IncidentUpdate(status: IncidentStatus.resolved),
        );
        return Result.success(incident);
      }

      final incident =
          await _remoteDataSource.resolve(projectId: projectId, incidentId: id);
      return Result.success(incident);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<List<Incident>>> getByService(int serviceId) async {
    try {
      final incidents = await _currentDataSource.getByService(
          projectId: projectId, serviceId: serviceId);
      return Result.success(incidents);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<AiAnalysis?>> getAnalysis(int incidentId) async {
    try {
      final analysis = await _remoteDataSource.getAnalysis(
          projectId: projectId, incidentId: incidentId);
      return Result.success(analysis);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> requestAnalysis(int incidentId) async {
    try {
      await _remoteDataSource.requestAnalysis(
          projectId: projectId, incidentId: incidentId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  AppError _handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is Exception) {
      return UndefinedError(message: error.toString());
    }

    return UndefinedError(message: 'Unknown error occurred');
  }
}

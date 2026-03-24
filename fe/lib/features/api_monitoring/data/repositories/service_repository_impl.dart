import 'package:service_sentinel_fe_v2/features/api_monitoring/data/data_sources/local_service_data_source_impl.dart';

import '../../../../core/data/data_source_mode.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/health_check.dart';
import '../../domain/entities/latency_series.dart';
import '../../domain/repositories/service_repository.dart';
import '../data_sources/service_data_source.dart';

/// Service repository implementation - Auth-aware facade
///
/// Delegates to appropriate data source based on authentication state:
/// - Guest/unauthenticated → LocalServiceDataSource (Hive)
/// - Authenticated → RemoteServiceDataSource (REST API)
///
/// This repository is UI-agnostic and observes DataSourceMode instead of
/// directly checking authentication state.
class ServiceRepositoryImpl implements ServiceRepository {
  final LocalServiceDataSource _localDataSource;
  final RemoteServiceDataSource _remoteDataSource;
  final DataSourceMode Function() _getDataSourceMode;
  final int projectId;

  ServiceRepositoryImpl({
    required LocalServiceDataSource localDataSource,
    required RemoteServiceDataSource remoteDataSource,
    required DataSourceMode Function() getDataSourceMode,
    required this.projectId,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _getDataSourceMode = getDataSourceMode;

  ServiceDataSource get _currentDataSource {
    return _remoteDataSource;
    //
    // final mode = _getDataSourceMode();
    // return mode.isLocal ? _localDataSource : _remoteDataSource;
  }

  @override
  Future<Result<List<Service>>> getAll({bool? isActive}) async {
    try {
      final services = await _currentDataSource.getAll(
          projectId: projectId, isActive: isActive);

      return Result.success(services);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Service>> getById(int id) async {
    try {
      final service =
          await _currentDataSource.getById(projectId: projectId, serviceId: id);
      return Result.success(service);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Service>> create(ServiceCreate data) async {
    try {
      final mode = _getDataSourceMode();
      // 로컬 모드일 경우 실행
      if (mode.isLocal) {
        // For local, set default isActive if not provided
        final service =
            await _remoteDataSource.create(projectId: projectId, data: data);
        await LocalServiceDataSourceImpl().createByService(
          service: service,
        );

        return Result.success(service);
      }
      final service =
          await _remoteDataSource.create(projectId: projectId, data: data);
      return Result.success(service);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Service>> update(int id, ServiceUpdate data) async {
    try {
      final service = await _currentDataSource.update(
          projectId: projectId, serviceId: id, data: data);
      return Result.success(service);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _currentDataSource.delete(projectId: projectId, serviceId: id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> activate(int id) async {
    try {
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        // For local, update isActive flag
        await _localDataSource.update(
            projectId: projectId,
            serviceId: id,
            data: ServiceUpdate(isActive: true));
      } else {
        await _remoteDataSource.activate(projectId: projectId, serviceId: id);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> deactivate(int id) async {
    try {
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        // For local, update isActive flag
        await _localDataSource.update(
            projectId: projectId,
            serviceId: id,
            data: ServiceUpdate(isActive: false));
      } else {
        await _remoteDataSource.deactivate(projectId: projectId, serviceId: id);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<HealthCheck>> checkNow(int id) async {
    try {
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        return Result.failure(UndefinedError(
          message: 'Manual health checks not available in local mode',
        ));
      }

      final check =
          await _remoteDataSource.checkNow(projectId: projectId, serviceId: id);
      return Result.success(check);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<List<HealthCheck>>> getHealthChecks(
    int serviceId, {
    int? limit,
    DateTime? since,
  }) async {
    try {
      final checks = await _currentDataSource.getHealthChecks(
        projectId: projectId,
        serviceId: serviceId,
        limit: limit ?? 0,
        // since: since,
      );
      return Result.success(checks);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<HealthCheck?>> getLatestHealthCheck(int serviceId) async {
    try {
      final check = await _currentDataSource.getLatestHealthCheck(
          projectId: projectId, serviceId: serviceId);
      return Result.success(check);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<ServiceStats>> getStats(int id, String period) async {
    try {
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        // Return default stats for local services
        return Result.success(ServiceStats(
          serviceId: id.toString(),
          // period: period,
          totalChecks: 0,
          successfulChecks: 0,
          failedChecks: 0,
          averageLatencyMs: 0,
          uptimePercentage: 100.0,
        ));
      }

      final stats = await _remoteDataSource.getStats(
        projectId: projectId,
        serviceId: id,
        period: period,
      );
      return Result.success(stats);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<LatencySeries>> getLatencySeries(
      int id, String period) async {
    try {
      final series = await _remoteDataSource.getLatencySeries(
        projectId: projectId,
        serviceId: id,
        period: period,
      );
      return Result.success(series);
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

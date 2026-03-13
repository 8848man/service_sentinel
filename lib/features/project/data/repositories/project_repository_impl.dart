import 'package:service_sentinel_fe_v2/features/project/domain/entities/project_health.dart';
import 'package:service_sentinel_fe_v2/features/project/infrastructure/data_sources/local_project_data_source_impl.dart';

import '../../../../core/data/data_source_mode.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../data_sources/project_data_source.dart';

/// Project repository implementation - Auth-aware facade
///
/// Delegates to appropriate data source based on authentication state:
/// - Guest/unauthenticated → LocalProjectDataSource (Hive)
/// - Authenticated → RemoteProjectDataSource (REST API)
///
/// This repository is UI-agnostic and observes DataSourceMode instead of
/// directly checking authentication state.
class ProjectRepositoryImpl implements ProjectRepository {
  final LocalProjectDataSource _localDataSource;
  final RemoteProjectDataSource _remoteDataSource;
  final DataSourceMode Function() _getDataSourceMode;

  ProjectRepositoryImpl({
    required LocalProjectDataSource localDataSource,
    required RemoteProjectDataSource remoteDataSource,
    required DataSourceMode Function() getDataSourceMode,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _getDataSourceMode = getDataSourceMode;

  ProjectDataSource get _currentDataSource {
    // final mode = _getDataSourceMode();
    // return mode.isLocal ? _localDataSource : _remoteDataSource;

    return _remoteDataSource;
  }

  @override
  Future<Result<List<Project>>> getAll() async {
    try {
      final projects = await _currentDataSource.getAll();
      return Result.success(projects);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Project>> getById(String id) async {
    try {
      final project = await _currentDataSource.getById(id);
      return Result.success(project);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<ProjectStats>> getStats(String id) async {
    try {
      // Stats are only available for remote data source
      final mode = _getDataSourceMode();
      if (mode.isLocal) {
        // Return default stats for local projects
        return Result.success(ProjectStats(
          projectId: id,
          totalServices: 0,
          healthyServices: 0,
          unhealthyServices: 0,
          openIncidents: 0,
        ));
      }

      final stats = await _remoteDataSource.getStats(id);
      return Result.success(stats);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<ProjectHealth>> getHealth(String id) async {
    try {
      // Health is ALWAYS server-only (never local)
      // Backend calculates health on-demand from service states and incidents
      final health = await _remoteDataSource.getHealth(id);
      return Result.success(health);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Project>> create(ProjectCreate data) async {
    try {
      // Stats are only available for remote data source
      // final mode = _getDataSourceMode();
      final project = await _remoteDataSource.create(data);
      // if (mode.isLocal) {
      //   await LocalProjectDataSourceImpl().createByProject(project);
      // }
      return Result.success(project);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Project>> update(String id, ProjectUpdate data) async {
    try {
      final project = await _currentDataSource.update(id, data);
      return Result.success(project);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _currentDataSource.delete(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<Project>> uploadToServer(Project project) async {
    try {
      // Create on server
      final createData = ProjectCreate(
        name: project.name,
        description: project.description,
      );

      final result = await _remoteDataSource.create(createData);
      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<bool>> existsOnServer(String projectName) async {
    try {
      final exists = await _remoteDataSource.existsByName(projectName);
      return Result.success(exists);
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

import '../../../../core/error/result.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/api_key.dart';
import '../../domain/repositories/api_key_repository.dart';
import '../data_sources/remote_api_key_data_source.dart';

/// API Key repository implementation
///
/// NOTE: API keys are server-only, no local storage exists
/// Guest users cannot access this repository
///
/// This repository does not need auth-awareness since API keys
/// only exist for authenticated users on the server.
class ApiKeyRepositoryImpl implements ApiKeyRepository {
  final ApiKeyDataSource _dataSource;

  ApiKeyRepositoryImpl({
    required ApiKeyDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<ApiKey>>> getAll(String projectId) async {
    try {
      final keys = await _dataSource.getAll(projectId);
      return Result.success(keys);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<ApiKey>> create(String projectId, ApiKeyCreate data) async {
    try {
      final apiKey = await _dataSource.create(projectId, data);
      return Result.success(apiKey);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> delete(String projectId, String keyId) async {
    try {
      await _dataSource.delete(projectId, keyId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> deactivate(String projectId, String keyId) async {
    try {
      await _dataSource.deactivate(projectId, keyId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<bool>> verify(String apiKey) async {
    try {
      final isValid = await _dataSource.verify(apiKey);
      return Result.success(isValid);
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

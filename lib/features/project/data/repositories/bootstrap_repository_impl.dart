import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/bootstrap.dart';
import '../../domain/repositories/bootstrap_repository.dart';
import '../data_sources/bootstrap_data_source.dart';

/// Bootstrap repository implementation
class BootstrapRepositoryImpl implements BootstrapRepository {
  final BootstrapDataSource _dataSource;

  BootstrapRepositoryImpl({
    required BootstrapDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<BootstrapResponse>> bootstrap(BootstrapRequest request) async {
    try {
      final response = await _dataSource.bootstrap(request);
      return Result.success(response);
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

    return UndefinedError(message: 'Unknown error during bootstrap');
  }
}

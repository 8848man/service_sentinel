import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../dto/subscription_dto.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepositoryImpl(this._dio);

  String get _baseUrl => '${AppConfig.apiUrl}/subscription';

  @override
  Future<Result<Subscription>> getSubscription() async {
    try {
      final response = await _dio.get(_baseUrl);
      final dto = SubscriptionDto.fromJson(response.data as Map<String, dynamic>);
      return Result.success(dto.toDomain());
    } on DioException catch (e) {
      return Result.failure(_handleError(e));
    } catch (e) {
      return Result.failure(UndefinedError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> reactivateMonitoring() async {
    try {
      await _dio.post('$_baseUrl/reactivate');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(_handleError(e));
    } catch (e) {
      return Result.failure(UndefinedError(message: e.toString()));
    }
  }

  AppError _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['detail']?.toString() ?? e.message ?? 'Unknown error';

    if (statusCode == 401 || statusCode == 403) {
      return AuthError(message: message);
    } else if (statusCode == 404) {
      return NotFoundError(message: message);
    } else if (statusCode != null) {
      return ServerError(message: message, statusCode: statusCode);
    } else {
      return NetworkError(message: message);
    }
  }
}

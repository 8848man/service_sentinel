import 'package:dio/dio.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/bootstrap.dart';
import '../models/bootstrap_dto.dart';
import 'bootstrap_data_source.dart';

/// Remote bootstrap data source implementation
/// Uses unauthenticated Dio client (no interceptors)
///
/// IMPORTANT: This data source MUST use the unauthenticated Dio provider
/// to bypass authentication interceptors (no Firebase token, no X-API-KEY)
class RemoteBootstrapDataSourceImpl implements BootstrapDataSource {
  final Dio _dio; // This MUST be unauthenticated Dio instance

  RemoteBootstrapDataSourceImpl(this._dio);

  @override
  Future<BootstrapResponse> bootstrap(BootstrapRequest request) async {
    try {
      final dto = BootstrapRequestDto.fromDomain(request);
      final response = await _dio.post(
        '/projects/bootstrap',
        data: dto.toJson(),
      );

      final responseDto = BootstrapResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return responseDto.toDomain();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppError _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['detail'] as String? ??
          error.response!.data?['message'] as String? ??
          error.message;

      switch (statusCode) {
        case 422:
          // Validation error (e.g., project name too long)
          return ValidationError(
            message: message ?? 'Validation error',
          );
        case 500:
          return ServerError(
            message: message ?? 'Server error during bootstrap',
            statusCode: statusCode,
          );
        default:
          return ServerError(
            message: message ?? 'Bootstrap request failed',
            statusCode: statusCode,
          );
      }
    }

    // Network error
    return NetworkError(message: error.message ?? 'Network error during bootstrap');
  }
}

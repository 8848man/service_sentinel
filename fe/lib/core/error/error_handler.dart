import 'package:dio/dio.dart';
import 'app_error.dart';

/// Global error handler for converting exceptions to AppError
class ErrorHandler {
  ErrorHandler._();

  /// Convert exception to AppError
  static AppError handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    return ServerError(
      message: 'An unexpected error occurred',
      originalError: error,
    );
  }

  /// Handle Dio-specific errors
  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError(
          message: 'Connection timeout. Please check your network.',
          code: 'TIMEOUT',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return NetworkError(
          message: 'Network error. Please check your connection.',
          code: 'CONNECTION_ERROR',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return NetworkError(
          message: 'Request was cancelled',
          code: 'CANCELLED',
          originalError: error,
        );

      default:
        return NetworkError(
          message: 'Network error occurred',
          code: 'UNKNOWN',
          originalError: error,
        );
    }
  }

  /// Handle HTTP response errors
  static AppError _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'An error occurred';
    if (responseData is Map && responseData.containsKey('detail')) {
      message = responseData['detail'].toString();
    }

    switch (statusCode) {
      case 400:
        return ValidationError(
          message: message,
          code: 'BAD_REQUEST',
          // statusCode: statusCode,
          originalError: error,
        );

      case 401:
        return UnauthorizedError(
          message:
              message.isEmpty ? 'Unauthorized. Please login again.' : message,
          code: 'UNAUTHORIZED',
          originalError: error,
        );

      case 403:
        return AuthError(
          message: message.isEmpty ? 'Access forbidden' : message,
          code: 'FORBIDDEN',
          originalError: error,
        );

      case 404:
        return NotFoundError(
          message: message.isEmpty ? 'Resource not found' : message,
          code: 'NOT_FOUND',
          originalError: error,
        );

      case 500:
      case 502:
      case 503:
        return ServerError(
          message: 'Server error. Please try again later.',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          originalError: error,
        );

      default:
        return ServerError(
          message: message,
          code: 'HTTP_ERROR',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }
}

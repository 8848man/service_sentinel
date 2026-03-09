import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../infrastructure/guest_api_key_service.dart';
import 'authentication_interceptor.dart';

/// Dio HTTP client configuration
///
/// Integrates authentication and Guest API Key management via interceptors.
/// Does NOT directly manage auth logic - delegates to AuthenticationInterceptor.
///
/// Architecture:
/// - Firebase Auth for authenticated users (Authorization header)
/// - Guest API Key for unauthenticated users (X-API-KEY header)
/// - Interceptor handles header injection based on auth state
/// - Logging interceptor for debugging
class DioClient {
  late final Dio _dio;
  final Logger _logger = Logger();
  final fb.FirebaseAuth _firebaseAuth;
  final GuestApiKeyService _guestApiKeyService;

  DioClient(
    this._firebaseAuth,
    this._guestApiKeyService,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout:
            const Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Get configured Dio instance
  Dio get dio => _dio;

  /// Set up interceptors for authentication and logging
  void _setupInterceptors() {
    // Add authentication interceptor first (injects auth headers and handles 401)
    _dio.interceptors.add(
      AuthenticationInterceptor(_firebaseAuth, _guestApiKeyService),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AppConfig.enableDebugLogging) {
            _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
            // _logger.d('Headers: ${options.headers}');
            if (options.data != null) {
              _logger.d('Data: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableDebugLogging) {
            _logger.d(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            _logger.d('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (AppConfig.enableDebugLogging) {
            _logger.e(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            );
            _logger.e('Message: ${error.message}');
            if (error.response?.data != null) {
              _logger.e('Data: ${error.response?.data}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}

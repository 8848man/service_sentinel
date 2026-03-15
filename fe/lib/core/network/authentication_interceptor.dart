import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:logger/logger.dart';
import 'package:service_sentinel_fe_v2/core/config/app_config.dart';
import '../infrastructure/guest_api_key_service.dart';

/// Authentication Interceptor
///
/// Handles authentication and guest identification for v3 API requests.
/// Implements strict separation between Firebase Auth and Guest API Keys.
///
/// Request Header Rules (STRICTLY ENFORCED):
/// - If Firebase user is authenticated:
///   → Send ONLY: Authorization: Bearer <firebase_id_token>
///   → Do NOT send X-API-KEY
///
/// - If Firebase user is NOT authenticated (guest):
///   → Send ONLY: X-API-KEY: <guest_key> (if key exists)
///   → Do NOT send Authorization header
///   → If no guest key: Send NO headers (request will be unauthenticated)
///
/// - NEVER send both headers simultaneously
///
/// Guest Key Lifecycle:
/// - Guest key is obtained from bootstrap endpoint when user creates first project
/// - Until bootstrap is called, guest has no key (requests will be unauthenticated)
///
/// Error Handling:
/// - 401 Unauthorized: Attempt Firebase token refresh and retry
/// - 403 Forbidden: Log for debugging (access denied)
class AuthenticationInterceptor extends Interceptor {
  final fb.FirebaseAuth _firebaseAuth;
  final GuestApiKeyService _guestApiKeyService;
  final Logger _logger = Logger();

  AuthenticationInterceptor(
    this._firebaseAuth,
    this._guestApiKeyService,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if Firebase user is authenticated
    final firebaseUser = _firebaseAuth.currentUser;
    final isFirebaseAuthenticated =
        firebaseUser != null && !firebaseUser.isAnonymous;

    if (isFirebaseAuthenticated) {
      // Firebase authenticated: Add Authorization header ONLY
      try {
        final token = await firebaseUser.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          _logger.d('Added Firebase Auth token to request: ${options.path}');
        } else {
          _logger.w('Firebase user exists but token is null: ${options.path}');
        }
      } catch (e) {
        _logger.e('Failed to get Firebase token: $e');
      }
    } else {
      // Guest user: Add X-API-KEY header ONLY (if key exists)
      final guestKey = _guestApiKeyService.getGuestKey();

      if (guestKey != null) {
        options.headers['X-API-KEY'] = guestKey;
        _logger.d('Added guest API key to request: ${options.path}');
      } else {
        // No guest key yet - this is expected before bootstrap is called
        _logger.d(
            'No guest API key available (user has not bootstrapped): ${options.path}');
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - attempt token refresh and retry
    if (err.response?.statusCode == 401) {
      final firebaseUser = _firebaseAuth.currentUser;
      final isFirebaseAuthenticated =
          firebaseUser != null && !firebaseUser.isAnonymous;

      if (isFirebaseAuthenticated) {
        _logger.i(
            'Received 401 Unauthorized, attempting Firebase token refresh...');

        try {
          // Force refresh Firebase token
          final newToken = await firebaseUser.getIdToken(true);

          if (newToken != null) {
            _logger.i(
                'Firebase token refreshed successfully, retrying request...');

            // Clone the failed request
            final options = err.requestOptions;

            // Update Authorization header with new token
            options.headers['Authorization'] = 'Bearer $newToken';

            // Retry the request
            try {
              final response = await Dio(
                BaseOptions(
                  baseUrl: AppConfig.apiUrl,
                  connectTimeout:
                      const Duration(milliseconds: AppConfig.connectionTimeout),
                  receiveTimeout:
                      const Duration(milliseconds: AppConfig.receiveTimeout),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                ),
              ).fetch(options);
              return handler.resolve(response);
            } catch (e) {
              // Retry failed, continue with original error
              _logger.e('Retry after token refresh failed: $e');
            }
          } else {
            _logger.w(
                'Token refresh returned null, user may need to re-authenticate');
          }
        } catch (e) {
          _logger.e('Error during token refresh: $e');
        }
      } else {
        // Guest user received 401 - guest key may be invalid or not yet obtained
        _logger.w(
            'Guest user received 401 Unauthorized. Guest API key may be invalid or not yet obtained.');
      }
    }

    // Handle 403 Forbidden - log for debugging
    if (err.response?.statusCode == 403) {
      _logger.w(
        '403 Forbidden: Access denied. User may not have permission to access this resource.',
      );
    }

    // Continue with error
    return handler.next(err);
  }
}

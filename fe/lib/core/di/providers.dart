import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../infrastructure/guest_api_key_service.dart';

// /// Firebase Auth instance provider
// final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
//   return fb.FirebaseAuth.instance;
// });

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

/// SharedPreferences provider
/// Required for GuestIdentificationService persistence
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

/// Guest API Key Service provider
/// Manages server-issued Guest API Keys for unauthenticated users
/// Keys are obtained from bootstrap endpoint, not generated client-side
final guestApiKeyServiceProvider = Provider<GuestApiKeyService>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final service = GuestApiKeyService(prefsAsync)
    // Pre-load guest key on initialization (safe - only reads from storage)
    ..preloadGuestKey();
  return service;
});

/// Global DioClient provider
/// Configured with Firebase Auth and Guest API Key for automatic header injection
final dioClientProvider = Provider<DioClient>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final guestApiKeyService = ref.watch(guestApiKeyServiceProvider);

  return DioClient(firebaseAuth, guestApiKeyService);
});

/// Unauthenticated DioClient provider
/// For bootstrap endpoint - does NOT include AuthenticationInterceptor
/// Only includes logging interceptor for debugging
final unauthenticatedDioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor only (no authentication)
  if (AppConfig.enableDebugLogging) {
    final logger = Logger();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger
              .d('UNAUTH REQUEST[${options.method}] => PATH: ${options.path}');
          // logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            logger.d('Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.d(
            'UNAUTH RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          logger.d('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          logger.e(
            'UNAUTH ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          logger.e('Message: ${error.message}');
          if (error.response?.data != null) {
            logger.e('Data: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  return dio;
});

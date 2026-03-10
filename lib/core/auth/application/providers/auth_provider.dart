import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:service_sentinel_fe_v2/core/services/device_registration_service.dart';
import 'package:service_sentinel_fe_v2/core/auth/application/utils/resolve_platform.dart';
import 'package:service_sentinel_fe_v2/core/auth/data/repositories/device_token_repository.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/usecases/register_device_token.dart';
import 'package:service_sentinel_fe_v2/core/di/providers.dart';
import 'package:service_sentinel_fe_v2/core/router/app_router.dart';
import '../../../storage/secure_storage.dart';
import '../../../di/repository_providers.dart';
import '../../../state/project_session_notifier.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';

part 'auth_provider.g.dart';

/// Global authentication state provider
/// This is the single source of truth for auth state
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  Future<AuthState> build() async {
    // Initialize auth state
    // Check if user is authenticated via Firebase
    final authRepo = ref.read(authRepositoryProvider);
    try {
      final isAuth = await authRepo.isAuthenticated();

      if (isAuth) {
        final userResult = await authRepo.getCurrentUser();
        final user = userResult.dataOrNull ?? GuestUser.instance;

        // Load stored project ID (if any)
        final secureStorage = ref.read(secureStorageProvider);
        final projectId = await secureStorage.getCurrentProjectId();

        return AuthState.authenticated(
          user: user,
          currentProjectId: projectId,
        );
      }
    } catch (e) {
      debugPrint("Error checking auth state: $e");
      return AuthState.guest();
    }

    return AuthState.guest();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);

      final result = await authRepo.signInWithGoogle();
      if (!result.isSuccess) {
        throw result.errorOrNull!;
      }

      ref.read(goRouterProvider).go(AppRoutes.projectSelection);

      unawaited(DeviceRegistrationService(ref).registerIfNeeded());
      final secureStorage = ref.read(secureStorageProvider);
      final projectId = await secureStorage.getCurrentProjectId();

      return AuthState.authenticated(
        user: result.dataOrNull!,
        currentProjectId: projectId,
      );
    });
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final result = await authRepo.signInWithEmail(email, password);
        if (result.isSuccess) {
          // 성공시 프로젝트 선택 페이지로 이동
          ref.read(goRouterProvider).go(AppRoutes.projectSelection);
          // Load stored project ID if any
          final secureStorage = ref.read(secureStorageProvider);
          final projectId = await secureStorage.getCurrentProjectId();

          return AuthState.authenticated(
            user: result.dataOrNull!,
            currentProjectId: projectId,
          );
        } else {
          throw result.errorOrNull!;
        }
      } catch (e) {
        rethrow;
      }
    });
  }

  /// Sign up with email and password
  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.signUpWithEmail(email, password);

      if (result.isSuccess) {
        return AuthState.authenticated(
          user: result.dataOrNull!,
        );
      } else {
        throw result.errorOrNull!;
      }
    });
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();

      // 모바일 signout처리
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
      // Clear project session (includes API keys)
      await ref.read(projectSessionProvider.notifier).clear();

      // Clear stored project ID
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.deleteCurrentProjectId();

      return AuthState.guest();
    });
  }

  /// delete Account
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.deleteAccount();

      // Clear project session (includes API keys)
      await ref.read(projectSessionProvider.notifier).clear();

      // Clear stored project ID
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.deleteCurrentProjectId();

      return AuthState.guest();
    });
  }

  /// Set current project context
  /// Called after user selects a project
  /// Note: API key management is now handled by ProjectSession
  Future<void> setProjectContext(String projectId) async {
    final currentState = state.value;
    if (currentState == null || !currentState.isAuthenticated) {
      return;
    }

    // Update state with selected project
    state = AsyncValue.data(
      currentState.copyWith(
        currentProjectId: projectId,
      ),
    );
  }

  /// Clear project context
  Future<void> clearProjectContext() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        currentProjectId: null,
      ),
    );
  }
}

/// Helper provider to check if user is authenticated
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.value?.isAuthenticated ?? false;
}

/// Helper provider to get current user
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.value?.user;
}

/// Helper provider to check if user has project context
@riverpod
bool hasProjectContext(HasProjectContextRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.value?.hasProjectContext ?? false;
}

/// Helper provider to get current project ID
@riverpod
String? currentProjectId(CurrentProjectIdRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.value?.currentProjectId;
}

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return DeviceTokenRepository(dio.dio);
});

final registerDeviceTokenUseCaseProvider =
    Provider<RegisterDeviceTokenUseCase>((ref) {
  final authRepo = ref.read(deviceTokenRepositoryProvider);
  return RegisterDeviceTokenUseCase(authRepo);
});

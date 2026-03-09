import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/application/providers/auth_provider.dart';
import 'data_source_mode.dart';

part 'data_source_mode_provider.g.dart';

/// Central auth-aware data source mode provider
/// This provider listens to authentication state and determines
/// which data source (local or server) should be used.
///
/// Rules:
/// - Guest/unauthenticated → DataSourceMode.local
/// - Authenticated → DataSourceMode.server
///
/// All repository implementations MUST depend on this provider.
/// UI widgets MUST NEVER check authentication state directly.
@riverpod
DataSourceMode dataSourceMode(DataSourceModeRef ref) {
  // // Watch authentication state
  // final authState = ref.watch(authStateNotifierProvider).value;

  // if (authState == null) {
  //   // Auth state not yet loaded, default to local
  //   return DataSourceMode.local;
  // }

  // // Determine mode based on authentication
  // return authState.isAuthenticated
  //     ? DataSourceMode.server
  //     : DataSourceMode.local;
  /// do no edit this. local storage is disabled temporarily
  return DataSourceMode.server;
}

/// Helper provider to check if currently using local storage
@riverpod
bool isUsingLocalStorage(IsUsingLocalStorageRef ref) {
  return ref.watch(dataSourceModeProvider).isLocal;
}

/// Helper provider to check if currently using server storage
@riverpod
bool isUsingServerStorage(IsUsingServerStorageRef ref) {
  return ref.watch(dataSourceModeProvider).isServer;
}

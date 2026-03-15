import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:service_sentinel_fe_v2/features/project/data/data_sources/local_project_data_source_impl.dart';
import 'package:service_sentinel_fe_v2/features/project/data/data_sources/remote_project_data_source_impl.dart';
import '../di/providers.dart';
import 'migration_service.dart';
import 'migration_state.dart';

part 'migration_provider.g.dart';

/// Migration service provider
@riverpod
MigrationService migrationService(MigrationServiceRef ref) {
  final dio = ref.watch(dioClientProvider).dio;

  return MigrationService(
    localProjectDataSource: LocalProjectDataSourceImpl(),
    remoteProjectDataSource: RemoteProjectDataSourceImpl(dio),
  );
}

/// Migration state notifier - Manages migration state and execution
///
/// This StateNotifier exposes migration state as an application-layer signal
/// that UI can observe. It does NOT directly render UI.
///
/// UI components can:
/// - Watch migration state changes
/// - Trigger migration via executeMigration()
/// - Skip migration via skipMigration()
/// - Check if migration is needed via checkMigrationNeeded()
@riverpod
class MigrationStateNotifier extends _$MigrationStateNotifier {
  @override
  MigrationState build() {
    return MigrationState.idle();
  }

  /// Check if migration is needed
  /// Call this after user logs in
  Future<void> checkMigrationNeeded() async {
    final service = ref.read(migrationServiceProvider);

    final isNeeded = await service.isMigrationNeeded();
    if (isNeeded) {
      final itemCount = await service.getMigrationItemCount();
      state = MigrationState.required(totalItems: itemCount);
    } else {
      state = MigrationState.idle();
    }
  }

  /// Execute migration - Upload local data to server
  Future<void> executeMigration() async {
    final service = ref.read(migrationServiceProvider);

    await service.migrate(
      onStateChange: (migrationState) {
        state = migrationState;
      },
    );
  }

  /// Skip migration - User chooses not to migrate now
  void skipMigration() {
    state = MigrationState.skipped();
  }

  /// Reset migration state to idle
  void reset() {
    state = MigrationState.idle();
  }
}

/// Helper provider to check if migration is currently needed
@riverpod
bool isMigrationRequired(IsMigrationRequiredRef ref) {
  final migrationState = ref.watch(migrationStateNotifierProvider);
  return migrationState.isRequired;
}

/// Helper provider to check if migration is in progress
@riverpod
bool isMigrationInProgress(IsMigrationInProgressRef ref) {
  final migrationState = ref.watch(migrationStateNotifierProvider);
  return migrationState.isInProgress;
}

/// Helper provider to check if migration is completed
@riverpod
bool isMigrationCompleted(IsMigrationCompletedRef ref) {
  final migrationState = ref.watch(migrationStateNotifierProvider);
  return migrationState.isCompleted;
}

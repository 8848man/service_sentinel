import 'package:freezed_annotation/freezed_annotation.dart';

part 'migration_state.freezed.dart';

/// Migration state - represents the current state of data migration
/// from local to server storage
///
/// This is an application-layer signal that UI can observe.
/// UI decides how to present these states (dialog, snackbar, etc.)
@freezed
class MigrationState with _$MigrationState {
  const factory MigrationState({
    required MigrationStatus status,
    String? errorMessage,
    int? totalItems,
    int? migratedItems,
  }) = _MigrationState;

  const MigrationState._();

  /// Initial state - no migration needed or not checked yet
  factory MigrationState.idle() => const MigrationState(
        status: MigrationStatus.idle,
      );

  /// Migration is required (local data exists, user authenticated)
  factory MigrationState.required({int? totalItems}) => MigrationState(
        status: MigrationStatus.required,
        totalItems: totalItems,
      );

  /// Migration is in progress
  factory MigrationState.inProgress({
    required int totalItems,
    required int migratedItems,
  }) =>
      MigrationState(
        status: MigrationStatus.inProgress,
        totalItems: totalItems,
        migratedItems: migratedItems,
      );

  /// Migration completed successfully
  factory MigrationState.completed({required int totalItems}) => MigrationState(
        status: MigrationStatus.completed,
        totalItems: totalItems,
        migratedItems: totalItems,
      );

  /// Migration failed
  factory MigrationState.failed({required String errorMessage}) =>
      MigrationState(
        status: MigrationStatus.failed,
        errorMessage: errorMessage,
      );

  /// Migration was skipped by user
  factory MigrationState.skipped() => const MigrationState(
        status: MigrationStatus.skipped,
      );

  bool get isIdle => status == MigrationStatus.idle;
  bool get isRequired => status == MigrationStatus.required;
  bool get isInProgress => status == MigrationStatus.inProgress;
  bool get isCompleted => status == MigrationStatus.completed;
  bool get isFailed => status == MigrationStatus.failed;
  bool get isSkipped => status == MigrationStatus.skipped;

  double? get progress {
    if (totalItems == null || totalItems == 0) return null;
    if (migratedItems == null) return null;
    return migratedItems! / totalItems!;
  }
}

/// Migration status enumeration
enum MigrationStatus {
  /// No migration needed or not checked yet
  idle,

  /// Migration is required (user authenticated, local data exists)
  required,

  /// Migration is currently in progress
  inProgress,

  /// Migration completed successfully
  completed,

  /// Migration failed with error
  failed,

  /// User chose to skip migration
  skipped,
}

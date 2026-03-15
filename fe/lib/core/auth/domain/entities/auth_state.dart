import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../constants/enums.dart';
import 'user.dart';

part 'auth_state.freezed.dart';

/// Application authentication state
/// Determines source of truth for data (Local DB vs Server DB)
/// NOTE: API keys are managed separately per project, not stored here
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required User user,
    required bool isAuthenticated,
    required SourceOfTruth sourceOfTruth,
    String? currentProjectId,
  }) = _AuthState;

  const AuthState._();

  /// Guest state (unauthenticated)
  factory AuthState.guest() => const AuthState(
        user: GuestUser.instance,
        isAuthenticated: false,
        sourceOfTruth: SourceOfTruth.local,
      );

  /// Authenticated state
  factory AuthState.authenticated({
    required User user,
    String? currentProjectId,
  }) =>
      AuthState(
        user: user,
        isAuthenticated: true,
        sourceOfTruth: SourceOfTruth.server,
        currentProjectId: currentProjectId,
      );

  /// Check if user has selected a project
  bool get hasProjectContext => currentProjectId != null;
}

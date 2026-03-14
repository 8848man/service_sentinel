import '../../../error/result.dart';
import '../entities/user.dart';

/// Authentication repository interface
/// Abstracts Firebase Auth implementation
abstract class IAuthRepository {
  /// Get current authenticated user
  /// Returns GuestUser if not authenticated
  Future<Result<User>> getCurrentUser();

  /// Sign in with email and password
  Future<Result<User>> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<Result<User>> signUpWithEmail(String email, String password);

  /// Sign out
  Future<Result<void>> signOut();

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Stream of auth state changes
  Stream<User> authStateChanges();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get Firebase ID token for authenticated user
  /// Returns null if user is not authenticated
  /// forceRefresh: Forces token refresh if true
  Future<String?> getIdToken({bool forceRefresh = false});

  Future<Result<User>> signInWithGoogle();

  Future<void> deleteAccount();
}

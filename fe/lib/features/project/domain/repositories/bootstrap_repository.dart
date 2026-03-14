import '../../../../core/error/result.dart';
import '../entities/bootstrap.dart';

/// Bootstrap repository interface
/// Handles guest user initialization via bootstrap endpoint
abstract class BootstrapRepository {
  /// Bootstrap a guest user with initial project
  /// Returns BootstrapResponse containing Project and Guest API Key
  Future<Result<BootstrapResponse>> bootstrap(BootstrapRequest request);
}

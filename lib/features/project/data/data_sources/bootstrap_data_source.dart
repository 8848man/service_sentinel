import '../../domain/entities/bootstrap.dart';

/// Abstract interface for bootstrap data source
/// Handles guest user initialization via bootstrap endpoint
abstract class BootstrapDataSource {
  /// Call bootstrap endpoint to initialize guest user
  /// Returns BootstrapResponse containing Project and Guest API Key
  /// This endpoint is UNAUTHENTICATED (no Firebase token, no X-API-KEY)
  Future<BootstrapResponse> bootstrap(BootstrapRequest request);
}

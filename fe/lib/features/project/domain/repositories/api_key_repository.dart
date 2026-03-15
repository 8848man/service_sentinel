import '../../../../core/error/result.dart';
import '../entities/api_key.dart';

/// API Key repository interface
/// NOTE: API keys are server-only, no local storage
/// Guest users cannot create or use API keys
abstract class ApiKeyRepository {
  /// Get all API keys for a project
  /// Returns list without key values (security)
  Future<Result<List<ApiKey>>> getAll(String projectId);

  /// Create new API key
  /// Returns ApiKey with keyValue ONLY at creation time
  /// Frontend MUST store keyValue securely immediately
  Future<Result<ApiKey>> create(String projectId, ApiKeyCreate data);

  /// Delete API key
  Future<Result<void>> delete(String projectId, String keyId);

  /// Deactivate API key (soft delete)
  Future<Result<void>> deactivate(String projectId, String keyId);

  /// Verify if API key is valid
  /// Used to check stored key before making API calls
  Future<Result<bool>> verify(String apiKey);
}

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/infrastructure/guest_api_key_service.dart';
import '../entities/bootstrap.dart';
import '../repositories/bootstrap_repository.dart';

/// Use case: Bootstrap Guest User
///
/// Initializes a guest user by:
/// 1. Calling bootstrap endpoint (unauthenticated)
/// 2. Storing the returned Guest API Key
/// 3. Returning the created project
///
/// This use case should ONLY be called when:
/// - User is in guest mode (not authenticated)
/// - User clicks "Create Project" for the first time
/// - No Guest API Key exists yet
class BootstrapGuestUser {
  final BootstrapRepository _bootstrapRepository;
  final GuestApiKeyService _guestApiKeyService;

  BootstrapGuestUser({
    required BootstrapRepository bootstrapRepository,
    required GuestApiKeyService guestApiKeyService,
  })  : _bootstrapRepository = bootstrapRepository,
        _guestApiKeyService = guestApiKeyService;

  /// Execute bootstrap flow
  /// Returns the created project on success
  Future<Result<BootstrapResponse>> execute(BootstrapRequest request) async {
    // Validate input
    if (request.name.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'Project name cannot be empty'),
      );
    }

    if (request.name.length > 100) {
      return Result.failure(
        ValidationError(message: 'Project name cannot exceed 100 characters'),
      );
    }

    // Call bootstrap endpoint
    final result = await _bootstrapRepository.bootstrap(request);

    if (result.isSuccess) {
      // Store the Guest API Key
      final response = result.dataOrNull!;
      await _guestApiKeyService.storeGuestKey(response.apiKey);

      return Result.success(response);
    }

    return result;
  }
}

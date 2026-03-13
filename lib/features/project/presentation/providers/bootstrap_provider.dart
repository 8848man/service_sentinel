import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/di/repository_providers.dart';
import '../../domain/usecases/bootstrap_guest_user.dart';

part 'bootstrap_provider.g.dart';

/// Provider for BootstrapGuestUser use case
/// Handles guest user initialization via bootstrap endpoint
@riverpod
BootstrapGuestUser bootstrapGuestUser(BootstrapGuestUserRef ref) {
  return BootstrapGuestUser(
    bootstrapRepository: ref.watch(bootstrapRepositoryProvider),
    guestApiKeyService: ref.watch(guestApiKeyServiceProvider),
  );
}

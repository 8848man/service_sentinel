import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/auth/data/repositories/auth_repository.dart';

import '../domain/repositories/auth_repository.dart';
import '../../di/providers.dart';

// ============================================================================
// AUTH REPOSITORY
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final dio = ref.watch(dioClientProvider).dio;
  return AuthRepository(firebaseAuth, dio);
});

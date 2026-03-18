import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../domain/repositories/subscription_repository.dart';
import '../domain/usecases/get_subscription_usecase.dart';
import '../domain/usecases/reactivate_monitoring_usecase.dart';
import '../data/repositories/subscription_repository_impl.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SubscriptionRepositoryImpl(dio.dio);
});

final getSubscriptionUseCaseProvider = Provider<GetSubscriptionUseCase>((ref) {
  return GetSubscriptionUseCase(
    repository: ref.watch(subscriptionRepositoryProvider),
  );
});

final reactivateMonitoringUseCaseProvider = Provider<ReactivateMonitoringUseCase>((ref) {
  return ReactivateMonitoringUseCase(
    repository: ref.watch(subscriptionRepositoryProvider),
  );
});

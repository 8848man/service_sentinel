import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../di/repository_providers.dart';
import '../../domain/entities/subscription.dart';
import '../../../../core/constants/plan_limits.dart';

part 'subscription_view_model.g.dart';

class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;
  final bool isReactivating;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
    this.isReactivating = false,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
    bool? isReactivating,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isReactivating: isReactivating ?? this.isReactivating,
    );
  }

  String get currentPlan => subscription?.plan ?? fallbackPlan;
  int get maxProjects => getLimitsForPlan(currentPlan)['maxProjects']!;
  int get maxServices => getLimitsForPlan(currentPlan)['maxServices']!;
  bool get isSuspended => subscription?.isSuspended ?? false;
}

@riverpod
class SubscriptionViewModel extends _$SubscriptionViewModel {
  @override
  SubscriptionState build() {
    _loadSubscription();
    return const SubscriptionState(isLoading: true);
  }

  Future<void> _loadSubscription() async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = ref.read(getSubscriptionUseCaseProvider);
    final result = await useCase.execute();
    result.when(
      success: (sub) => state = state.copyWith(subscription: sub, isLoading: false),
      failure: (err) => state = state.copyWith(error: err.message, isLoading: false),
    );
  }

  Future<void> refresh() => _loadSubscription();

  Future<bool> reactivateMonitoring() async {
    state = state.copyWith(isReactivating: true, error: null);
    final useCase = ref.read(reactivateMonitoringUseCaseProvider);
    final result = await useCase.execute();
    bool success = false;
    result.when(
      success: (_) {
        success = true;
        state = state.copyWith(isReactivating: false);
      },
      failure: (err) => state = state.copyWith(
        isReactivating: false,
        error: err.message,
      ),
    );
    if (success) await _loadSubscription();
    return success;
  }
}

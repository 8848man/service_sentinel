import '../../../../core/error/result.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionUseCase({required SubscriptionRepository repository})
      : _repository = repository;

  Future<Result<Subscription>> execute() => _repository.getSubscription();
}

import '../../../../core/error/result.dart';
import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<Result<Subscription>> getSubscription();
  Future<Result<void>> reactivateMonitoring();
}

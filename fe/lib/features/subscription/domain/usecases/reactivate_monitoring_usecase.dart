import '../../../../core/error/result.dart';
import '../repositories/subscription_repository.dart';

class ReactivateMonitoringUseCase {
  final SubscriptionRepository _repository;

  ReactivateMonitoringUseCase({required SubscriptionRepository repository})
      : _repository = repository;

  Future<Result<void>> execute() => _repository.reactivateMonitoring();
}

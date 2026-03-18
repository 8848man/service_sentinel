import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/subscription.dart';

part 'subscription_dto.freezed.dart';
part 'subscription_dto.g.dart';

@freezed
class SubscriptionDto with _$SubscriptionDto {
  const factory SubscriptionDto({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    required String plan,
    required String status,
    @JsonKey(name: 'started_at') required String startedAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
    @JsonKey(name: 'previous_plan') String? previousPlan,
    @JsonKey(name: 'plan_changed_at') String? planChangedAt,
    @JsonKey(name: 'monitoring_suspended_at') String? monitoringSuspendedAt,
  }) = _SubscriptionDto;

  const SubscriptionDto._();

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDtoFromJson(json);

  Subscription toDomain() {
    return Subscription(
      id: id,
      userId: userId,
      plan: plan,
      status: status,
      startedAt: DateTime.parse(startedAt),
      expiresAt: expiresAt != null ? DateTime.parse(expiresAt!) : null,
      previousPlan: previousPlan,
      planChangedAt: planChangedAt != null ? DateTime.parse(planChangedAt!) : null,
      monitoringSuspendedAt: monitoringSuspendedAt != null
          ? DateTime.parse(monitoringSuspendedAt!)
          : null,
    );
  }
}

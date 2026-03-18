import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required int id,
    required int userId,
    required String plan,
    required String status,
    required DateTime startedAt,
    DateTime? expiresAt,
    String? previousPlan,
    DateTime? planChangedAt,
    DateTime? monitoringSuspendedAt,
  }) = _Subscription;

  const Subscription._();

  bool get isSuspended => monitoringSuspendedAt != null;
  bool get isActive => status == 'active';
}

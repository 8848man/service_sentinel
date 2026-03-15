import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/enums.dart';

part 'project_health.freezed.dart';

/// Project health aggregated from services and incidents
///
/// This is NEVER stored in database - always calculated on-demand by backend.
/// Backend computes health status based on:
/// 1. Service states (counting services in each state)
/// 2. Active incidents (OPEN or INVESTIGATING status)
@freezed
class ProjectHealth with _$ProjectHealth {
  const factory ProjectHealth({
    required ProjectHealthStatus status,
    required int totalServices,
    required int healthyServices,
    required int errorServices,
    required int inactiveServices,
    required int activeIncidents,
  }) = _ProjectHealth;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:service_sentinel_fe_v2/core/state/project_session_notifier.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_matrix.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_overview.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import '../../domain/usecases/get_global_dashboard.dart';
import '../../domain/entities/global_dashboard_metrics.dart';
import '../../../../core/di/repository_providers.dart';

part 'dashboard_provider.g.dart';

/// Use case provider for getting global dashboard metrics
@riverpod
GetGlobalDashboard getGlobalDashboard(GetGlobalDashboardRef ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetGlobalDashboard(repository);
}

@riverpod
Future<GlobalDashboardMetrics> globalDashboard(
  GlobalDashboardRef ref,
) async {
  final useCase = ref.watch(getGlobalDashboardProvider);
  final result = await useCase.execute();
  return result.getOrThrow();
}

/// Use case provider for getting global dashboard metrics
@riverpod
GetDashboardMatrix getDashboardMatrix(Ref ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final projectSession = ref.watch(projectSessionProvider);
  return GetDashboardMatrix(repository, projectSession.projectId ?? 0);
}

@riverpod
Future<DashboardMetrics> dashboardMatrix(
  Ref ref,
) async {
  final useCase = ref.watch(getDashboardMatrixProvider);
  final result = await useCase.execute();
  return result.getOrThrow();
}

@riverpod
GetDashboardOverview getDashboardOverview(Ref ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final projectSession = ref.watch(projectSessionProvider);
  return GetDashboardOverview(repository, projectSession.projectId ?? 0);
}

@riverpod
Future<DashboardOverview> dashboardOverview(
  Ref ref,
) async {
  final useCase = ref.watch(getDashboardOverviewProvider);
  final result = await useCase.execute();
  return result.getOrThrow();
}

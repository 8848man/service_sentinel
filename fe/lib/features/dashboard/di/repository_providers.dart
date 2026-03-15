import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../data/data_sources/global_dashboard_data_source.dart';
import '../data/data_sources/remote_global_dashboard_data_source_impl.dart';
import '../data/repositories/dashboard_repository_impl.dart';

/// Global dashboard data source provider
/// Provides system-wide metrics via REST API
final remoteDashboardDataSourceProvider = Provider<DashboardDataSource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return RemoteGlobalDashboardDataSourceImpl(dio);
});

/// Global dashboard repository provider
/// Provides system-wide dashboard metrics across all projects
/// Note: This endpoint does not require authentication per README_v1.1.md
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(remoteDashboardDataSourceProvider);
  return DashboardRepositoryImpl(dataSource);
});

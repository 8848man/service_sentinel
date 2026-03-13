import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/state/project_session_notifier.dart';
import 'package:service_sentinel_fe_v2/core/auth/data/repositories/auth_repository.dart';

import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as global;
import '../../features/dashboard/data/data_sources/global_dashboard_data_source.dart';
import '../../features/dashboard/data/data_sources/remote_global_dashboard_data_source_impl.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as global;
import '../auth/domain/repositories/auth_repository.dart';
import '../../features/incident/domain/repositories/incident_repository.dart';
import '../../features/incident/data/data_sources/local_incident_data_source_impl.dart';
import '../../features/incident/data/data_sources/remote_incident_data_source_impl.dart';
import '../../features/incident/data/repositories/incident_repository_impl.dart';
import '../../features/project/domain/repositories/api_key_repository.dart';
import '../../features/project/domain/repositories/bootstrap_repository.dart';
import '../../features/project/domain/repositories/project_repository.dart';
import '../../features/project/data/data_sources/local_project_data_source_impl.dart';
import '../../features/project/data/data_sources/remote_api_key_data_source.dart';
import '../../features/project/data/data_sources/remote_bootstrap_data_source_impl.dart';
import '../../features/project/data/data_sources/remote_project_data_source_impl.dart';
import '../../features/project/data/repositories/api_key_repository_impl.dart';
import '../../features/project/data/repositories/bootstrap_repository_impl.dart';
import '../../features/project/data/repositories/project_repository_impl.dart';
import '../data/data_source_mode_provider.dart';
import 'providers.dart';

/// Repository provider pattern:
/// All repositories now use auth-aware facades that automatically
/// switch between Local and Remote implementations based on DataSourceMode.
///
/// DataSourceMode is determined by authentication state:
/// - Guest (unauthenticated) → DataSourceMode.local (Hive)
/// - Authenticated → DataSourceMode.server (REST API)
///
/// Repositories observe DataSourceMode and delegate to the appropriate data source.

// ============================================================================
// AUTH REPOSITORY
// ============================================================================

/// Auth repository provider
/// Always uses Firebase Auth (remote only)
/// TODO: Implement FirebaseAuthRepositoryImpl
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   final fb.FirebaseAuth firebasAuth = fb.FirebaseAuth.instance;
//   return FirebaseAuthRepository(firebasAuth);
// });

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final dio = ref.watch(dioClientProvider).dio;
  return AuthRepository(firebaseAuth, dio);
});
// ============================================================================
// BOOTSTRAP REPOSITORY
// ============================================================================

/// Bootstrap repository provider
/// Uses unauthenticated Dio client (no Firebase token, no X-API-KEY)
/// This is the ONLY v3 endpoint accessible without authentication
final bootstrapRepositoryProvider = Provider<BootstrapRepository>((ref) {
  final unauthenticatedDio = ref.watch(unauthenticatedDioClientProvider);

  return BootstrapRepositoryImpl(
    dataSource: RemoteBootstrapDataSourceImpl(unauthenticatedDio),
  );
});

// ============================================================================
// PROJECT REPOSITORY
// ============================================================================

/// Project repository provider - Auth-aware facade
/// Automatically switches between local and remote based on DataSourceMode
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final dataSourceMode = ref.read(dataSourceModeProvider);

  return ProjectRepositoryImpl(
    localDataSource: LocalProjectDataSourceImpl(),
    remoteDataSource: RemoteProjectDataSourceImpl(dio.dio),
    getDataSourceMode: () => dataSourceMode,
  );
});

// ============================================================================
// API KEY REPOSITORY
// ============================================================================

/// API Key repository provider
/// Server-only, no local implementation exists
/// Throws error if called in guest mode
final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  final dio = ref.watch(dioClientProvider);

  return ApiKeyRepositoryImpl(
    dataSource: RemoteApiKeyDataSourceImpl(dio.dio),
  );
});

// ============================================================================
// INCIDENT REPOSITORY
// ============================================================================

/// Incident repository provider - Auth-aware facade
/// Automatically switches between local and remote based on DataSourceMode
final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final projectSession = ref.watch(projectSessionProvider);

  return IncidentRepositoryImpl(
    localDataSource: LocalIncidentDataSourceImpl(),
    remoteDataSource: RemoteIncidentDataSourceImpl(dio.dio),
    getDataSourceMode: () => ref.read(dataSourceModeProvider),
    projectId: projectSession.projectId ?? 0,
  );
});

// ============================================================================
// DASHBOARD REPOSITORY (Project-specific)
// ============================================================================

/// Dashboard repository provider
/// TODO: Implement auth-aware dashboard repository
// final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
//   throw UnimplementedError('DashboardRepository not implemented yet');
// });

// ============================================================================
// GLOBAL DASHBOARD REPOSITORY
// ============================================================================

/// Global dashboard data source provider
/// Provides system-wide metrics via REST API
final remoteDashboardDataSourceProvider = Provider<DashboardDataSource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return RemoteGlobalDashboardDataSourceImpl(dio);
});

/// Global dashboard repository provider
/// Provides system-wide dashboard metrics across all projects
/// Note: This endpoint does not require authentication per README_v1.1.md
final dashboardRepositoryProvider = Provider<global.DashboardRepository>((ref) {
  final dataSource = ref.watch(remoteDashboardDataSourceProvider);
  return global.DashboardRepositoryImpl(dataSource);
});

/// NOTE: All repositories except Auth and Dashboard are now fully wired
/// with auth-aware implementations that automatically switch data sources
/// based on authentication state.
///
/// The DataSourceMode provider observes authStateNotifierProvider and
/// determines which data source to use:
/// - DataSourceMode.local → Hive (guest users)
/// - DataSourceMode.server → REST API (authenticated users)
///
/// This ensures:
/// 1. UI never checks authentication state directly
/// 2. Data source switching is handled at the repository level
/// 3. All business logic remains in the Application layer
/// 4. Infrastructure layer is fully decoupled from presentation
// final remoteDashboardDataSourceProvider = Provider<DashboardDataSource>((ref) {
//   final dio = ref.watch(dioClientProvider).dio;
//   return RemoteGlobalDashboardDataSourceImpl(dio);
// });

// /// Global dashboard repository provider
// /// Provides system-wide dashboard metrics across all projects
// /// Note: This endpoint does not require authentication per README_v1.1.md
// final globalDashboardRepositoryProvider =
//     Provider<global.DashboardRepository>((ref) {
//   final dataSource = ref.watch(remoteGlobalDashboardDataSourceProvider);
//   return global.DashboardRepositoryImpl(dataSource);
// });

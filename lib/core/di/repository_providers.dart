import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/state/project_session_notifier.dart';
import 'package:service_sentinel_fe_v2/core/auth/data/repositories/auth_repository.dart';

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

// ============================================================================
// AUTH REPOSITORY
// ============================================================================

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

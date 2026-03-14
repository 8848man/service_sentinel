import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/data/data_source_mode_provider.dart';
import '../domain/repositories/api_key_repository.dart';
import '../domain/repositories/bootstrap_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../data/data_sources/local_project_data_source_impl.dart';
import '../data/data_sources/remote_api_key_data_source.dart';
import '../data/data_sources/remote_bootstrap_data_source_impl.dart';
import '../data/data_sources/remote_project_data_source_impl.dart';
import '../data/repositories/api_key_repository_impl.dart';
import '../data/repositories/bootstrap_repository_impl.dart';
import '../data/repositories/project_repository_impl.dart';

/// Bootstrap repository provider
/// Uses unauthenticated Dio client (no Firebase token, no X-API-KEY)
/// This is the ONLY v3 endpoint accessible without authentication
final bootstrapRepositoryProvider = Provider<BootstrapRepository>((ref) {
  final unauthenticatedDio = ref.watch(unauthenticatedDioClientProvider);

  return BootstrapRepositoryImpl(
    dataSource: RemoteBootstrapDataSourceImpl(unauthenticatedDio),
  );
});

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

/// API Key repository provider
/// Server-only, no local implementation exists
/// Throws error if called in guest mode
final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  final dio = ref.watch(dioClientProvider);

  return ApiKeyRepositoryImpl(
    dataSource: RemoteApiKeyDataSourceImpl(dio.dio),
  );
});

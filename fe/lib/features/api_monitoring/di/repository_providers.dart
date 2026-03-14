import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/data/data_source_mode_provider.dart';
import '../../../core/state/project_session_notifier.dart';
import '../domain/repositories/service_repository.dart';
import '../data/data_sources/local_service_data_source_impl.dart';
import '../data/data_sources/remote_service_data_source_impl.dart';
import '../data/repositories/service_repository_impl.dart';

/// Service repository provider - Auth-aware facade
/// Automatically switches between local and remote based on DataSourceMode
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final dio = ref.watch(dioClientProvider);

  final projectSession = ref.watch(projectSessionProvider);

  return ServiceRepositoryImpl(
    localDataSource: LocalServiceDataSourceImpl(),
    remoteDataSource: RemoteServiceDataSourceImpl(dio.dio),
    getDataSourceMode: () => ref.watch(dataSourceModeProvider),
    projectId: projectSession.projectId ?? 0,
  );
});

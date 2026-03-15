import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/data/data_source_mode_provider.dart';
import '../../../core/state/project_session_notifier.dart';
import '../domain/repositories/incident_repository.dart';
import '../data/data_sources/local_incident_data_source_impl.dart';
import '../data/data_sources/remote_incident_data_source_impl.dart';
import '../data/repositories/incident_repository_impl.dart';

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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../di/repository_providers.dart';
import '../../../../core/error/result.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/incident.dart';
import '../../domain/usecases/load_incidents.dart';
import '../../domain/usecases/acknowledge_incident.dart';
import '../../domain/usecases/resolve_incident.dart';
import '../../domain/usecases/update_incident.dart';
import '../../domain/usecases/request_ai_analysis.dart';

part 'incident_provider.g.dart';

// === Use Case Providers ===

/// Provider for LoadIncidents use case
@riverpod
LoadIncidents loadIncidents(LoadIncidentsRef ref) {
  return LoadIncidents(
    repository: ref.watch(incidentRepositoryProvider),
  );
}

/// Provider for AcknowledgeIncident use case
@riverpod
AcknowledgeIncident acknowledgeIncident(AcknowledgeIncidentRef ref) {
  return AcknowledgeIncident(
    repository: ref.watch(incidentRepositoryProvider),
  );
}

/// Provider for ResolveIncident use case
@riverpod
ResolveIncident resolveIncident(ResolveIncidentRef ref) {
  return ResolveIncident(
    repository: ref.watch(incidentRepositoryProvider),
  );
}

/// Provider for UpdateIncident use case
@riverpod
UpdateIncident updateIncident(UpdateIncidentRef ref) {
  return UpdateIncident(
    repository: ref.watch(incidentRepositoryProvider),
  );
}

/// Provider for RequestAiAnalysis use case
@riverpod
RequestAiAnalysis requestAiAnalysis(RequestAiAnalysisRef ref) {
  return RequestAiAnalysis(
    repository: ref.watch(incidentRepositoryProvider),
  );
}

// === Data Providers ===

/// Provider to fetch all incidents
@riverpod
Future<List<Incident>> incidents(IncidentsRef ref) async {
  final useCase = ref.watch(loadIncidentsProvider);
  final result = await useCase.execute();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider to fetch open incidents only
@riverpod
Future<List<Incident>> openIncidents(OpenIncidentsRef ref) async {
  final useCase = ref.watch(loadIncidentsProvider);
  final result = await useCase.executeOpen();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider to fetch critical incidents only
@riverpod
Future<List<Incident>> criticalIncidents(CriticalIncidentsRef ref) async {
  final useCase = ref.watch(loadIncidentsProvider);
  final result = await useCase.executeCritical();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider to fetch incident by ID
@riverpod
Future<Incident?> incidentById(IncidentByIdRef ref, String id) async {
  final allIncidents = await ref.watch(incidentsProvider.future);
  try {
    return allIncidents.firstWhere((incident) => incident.id == id);
  } catch (e) {
    return null;
  }
}

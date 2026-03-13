import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/get_project_health.dart';
import '../../domain/entities/project_health.dart';
import '../../../../core/di/repository_providers.dart';

part 'project_health_provider.g.dart';

/// Use case provider for getting project health
@riverpod
GetProjectHealth getProjectHealth(GetProjectHealthRef ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return GetProjectHealth(repository);
}

/// Provider for fetching project health by ID
///
/// Returns ProjectHealth containing:
/// - Overall status (HEALTHY, DEGRADED, UNKNOWN)
/// - Service counts by state (healthy, error, inactive)
/// - Active incident count
///
/// This is a FutureProvider that fetches health from the server on-demand.
/// Health is NEVER cached or stored locally.
@riverpod
Future<ProjectHealth> projectHealth(
  ProjectHealthRef ref,
  String projectId,
) async {
  final useCase = ref.watch(getProjectHealthProvider);
  final result = await useCase.execute(projectId);
  return result.getOrThrow();
}

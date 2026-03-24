import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../incident/di/repository_providers.dart';

/// Summary counts for the Analysis Overview screen.
class AnalysisSummary {
  final int total;
  final int pending;
  final int completed;
  final int failed;

  const AnalysisSummary({
    required this.total,
    required this.pending,
    required this.completed,
    required this.failed,
  });
}

/// FutureProvider that derives analysis counts from the incident list.
///
/// - total     = incidents with ai_analysis_requested == true
/// - completed = incidents with ai_analysis_completed == true
/// - pending   = requested but not yet completed
/// - failed    = not yet determinable from current data (reported as 0)
final analysisSummaryProvider = FutureProvider<AnalysisSummary>((ref) async {
  final repository = ref.watch(incidentRepositoryProvider);
  final result = await repository.getAll();

  if (!result.isSuccess) {
    throw result.errorOrNull ?? Exception('Failed to load incidents');
  }

  final incidents = result.dataOrNull ?? [];

  final requested =
      incidents.where((i) => i.aiAnalysisRequested).toList();
  final completed =
      incidents.where((i) => i.aiAnalysisCompleted).toList();
  final pending = requested
      .where((i) => !i.aiAnalysisCompleted)
      .toList();

  return AnalysisSummary(
    total: requested.length,
    pending: pending.length,
    completed: completed.length,
    failed: 0,
  );
});

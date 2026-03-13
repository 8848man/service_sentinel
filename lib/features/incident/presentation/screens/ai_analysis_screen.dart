import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../di/repository_providers.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../widgets/ai_analysis_view.dart';

part 'ai_analysis_screen.g.dart';

/// AI Analysis Detail Screen
///
/// Displays AI-generated root cause analysis for an incident.
/// Fetches and displays the analysis data from the repository.
///
/// Route: /incident/:id/analysis
/// Parameters: incidentId (String)
class AiAnalysisScreen extends ConsumerWidget {
  const AiAnalysisScreen({
    required this.incidentId,
    super.key,
  });
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.incidents_ai_root_cause),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.analysis_refresh,
            onPressed: () {
              // Refresh by invalidating the provider
              ref.invalidate(aiAnalysisProvider(incidentId));
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final analysisAsync = ref.watch(aiAnalysisProvider(incidentId));

          return analysisAsync.when(
            data: (analysis) => AiAnalysisView(analysis: analysis),
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.analysis_loading),
                ],
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.incidents_failed_to_load_analysis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(aiAnalysisProvider(incidentId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.common_retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Provider to fetch AI analysis for an incident
/// Fetches from repository and caches the result
@riverpod
Future<dynamic> aiAnalysis(AiAnalysisRef ref, String incidentId) async {
  final repository = ref.watch(incidentRepositoryProvider);
  final result = await repository.getAnalysis(int.parse(incidentId));

  if (result.isSuccess) {
    return result.dataOrNull;
  } else {
    throw result.errorOrNull ?? Exception('Unknown error');
  }
}

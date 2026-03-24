import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../di/repository_providers.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/error/app_error.dart';
import '../widgets/ai_analysis_view.dart';
import '../widgets/resolution_checklist.dart';

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
            data: (analysis) {
              final typedAnalysis =
                  analysis is AiAnalysis ? analysis : null;

              // No analysis yet — show empty state with a working request button.
              if (typedAnalysis == null) {
                return AiAnalysisView(
                  analysis: null,
                  onRequestAnalysis: () async {
                    final repo = ref.read(incidentRepositoryProvider);
                    final result = await repo.requestAnalysis(
                        int.parse(incidentId));
                    if (result.isSuccess) {
                      ref.invalidate(aiAnalysisProvider(incidentId));
                    } else {
                      final err = result.errorOrNull;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err is AppError
                                ? err.message
                                : l10n.incidents_failed_to_load_analysis),
                          ),
                        );
                      }
                    }
                  },
                );
              }

              final steps = typedAnalysis.debugChecklist ?? <String>[];
              // AiAnalysisView already contains a SingleChildScrollView.
              // When a checklist is present we need both to scroll together.
              // Achieve this by making AiAnalysisView non-scrollable via
              // an outer ScrollView; we pass NeverScrollableScrollPhysics
              // indirectly by using a CustomScrollView with slivers.
              if (steps.isEmpty) {
                return AiAnalysisView(analysis: typedAnalysis);
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: AiAnalysisView(
                      analysis: typedAnalysis,
                      scrollPhysics:
                          const NeverScrollableScrollPhysics(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: ResolutionChecklist(steps: steps),
                    ),
                  ),
                ],
              );
            },
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

import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../widgets/analysis_overview_body.dart';

/// Analysis Overview Screen
///
/// Displays an overview of AI analysis results across all incidents.
/// This screen is layout-only; all provider consumption happens in child widgets.
///
/// Route: /analysis or /main/analysis
class AnalysisOverviewScreen extends StatelessWidget {
  const AnalysisOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysis_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.analysis_refresh,
            onPressed: () {
              // TODO: Refresh analysis data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.analysis_refresh_coming_soon)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.analysis_filter,
            onPressed: () {
              // TODO: Show filter dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.analysis_filter_coming_soon)),
              );
            },
          ),
        ],
      ),
      body: const AnalysisOverviewBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Request bulk AI analysis
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.analysis_bulk_request_coming_soon)),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: Text(l10n.analysis_request_analysis),
      ),
    );
  }
}

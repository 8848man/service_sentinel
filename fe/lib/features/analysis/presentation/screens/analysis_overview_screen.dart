import 'package:flutter/material.dart';
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
    return const Scaffold(
      body: AnalysisOverviewBody(),
    );
  }
}

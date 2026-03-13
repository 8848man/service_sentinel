import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../presentation/providers/incident_provider.dart';
import '../widgets/incident_detail_body.dart';

/// Incident Detail Screen
///
/// Displays detailed information about a specific incident.
/// Provides actions to acknowledge, resolve, and request AI analysis.
///
/// Route: /incident/:id
/// Parameters: incidentId (String)
class IncidentDetailScreen extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailScreen({
    super.key,
    required this.incidentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.incidents_incident_details),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: l10n.incidents_request_ai_analysis,
            onPressed: () => _handleRequestAnalysis(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'acknowledge') {
                _handleAcknowledge(context, ref);
              } else if (value == 'resolve') {
                _handleResolve(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'acknowledge',
                child: Row(
                  children: [
                    const Icon(Icons.check),
                    const SizedBox(width: 8),
                    Text(l10n.incidents_acknowledge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'resolve',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(l10n.incidents_resolve),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IncidentDetailBody(incidentId: incidentId),
    );
  }

  /// Handle acknowledge incident action
  Future<void> _handleAcknowledge(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Acknowledge incident
    final useCase = ref.read(acknowledgeIncidentProvider);
    final result = await useCase.execute(int.parse(incidentId));

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (result.isSuccess) {
      // Invalidate incidents list to refresh
      ref.invalidate(incidentsProvider);
      ref.invalidate(incidentByIdProvider(incidentId));

      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.incidents_acknowledged_success)),
      );
    } else {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.incidents_failed_to_acknowledge(
                result.errorOrNull?.message ?? ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle resolve incident action
  Future<void> _handleResolve(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.incidents_resolve_incident),
        content: Text(l10n.incidents_resolve_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.incidents_resolve),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Resolve incident
    final useCase = ref.read(resolveIncidentProvider);
    final result = await useCase.execute(int.parse(incidentId));

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (result.isSuccess) {
      // Invalidate incidents list to refresh
      ref.invalidate(incidentsProvider);
      ref.invalidate(incidentByIdProvider(incidentId));

      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.incidents_resolved_success),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n
              .incidents_failed_to_resolve(result.errorOrNull?.message ?? '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle request AI analysis action
  Future<void> _handleRequestAnalysis(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.incidents_request_analysis_dialog_title),
        content: Text(l10n.incidents_request_analysis_dialog_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.incidents_request_analysis),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Request AI analysis
    final useCase = ref.read(requestAiAnalysisProvider);
    final result = await useCase.execute(int.parse(incidentId));

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (result.isSuccess) {
      // Invalidate incidents list to refresh
      ref.invalidate(incidentsProvider);
      ref.invalidate(incidentByIdProvider(incidentId));

      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.incidents_ai_analysis_requested),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.incidents_failed_to_request_analysis(
                result.errorOrNull?.message ?? ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

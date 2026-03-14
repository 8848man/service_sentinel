import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/router/app_router.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/incident.dart';

/// Incident detail dialog - Shows detailed information about an incident
///
/// Features:
/// - Full incident details
/// - Status visualization
/// - Severity information
/// - Timeline (detected, acknowledged, resolved)
/// - AI analysis button (if available)
class IncidentDetailDialog extends ConsumerWidget {
  final Incident incident;

  const IncidentDetailDialog({
    super.key,
    required this.incident,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.incidents_incident_details,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Status and Severity badges
                Row(
                  children: [
                    _buildStatusBadge(context, incident.status, theme),
                    const SizedBox(width: 8),
                    _buildSeverityBadge(context, incident.severity, theme),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  incident.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (incident.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    incident.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],

                const SizedBox(height: 24),

                // Statistics
                _buildStatisticsSection(context, theme),

                const SizedBox(height: 24),

                // Timeline
                _buildTimelineSection(context, theme),

                const SizedBox(height: 24),

                // AI Analysis
                if (incident.hasAnalysis) ...[
                  _buildAiAnalysisButton(context, theme),
                  const SizedBox(height: 16),
                ] else if (incident.aiAnalysisRequested) ...[
                  _buildAiAnalysisPending(context, theme),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildRequestAiAnalysisButton(
                    context,
                    theme,
                    incident.id,
                    ref,
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.common_close),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.incidents_statistics,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            theme,
            Icons.repeat,
            l10n.incidents_consecutive_failures,
            '${incident.consecutiveFailures}',
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            theme,
            Icons.error_outline,
            l10n.incidents_total_affected_checks,
            '${incident.totalAffectedChecks}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.incidents_timeline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTimelineItem(
            theme,
            Icons.error,
            l10n.incidents_timeline_detected,
            _formatFullDateTime(incident.detectedAt),
            true,
          ),
          if (incident.acknowledgedAt != null) ...[
            const SizedBox(height: 8),
            _buildTimelineItem(
              theme,
              Icons.visibility,
              l10n.incidents_timeline_acknowledged,
              _formatFullDateTime(incident.acknowledgedAt!),
              true,
            ),
          ],
          if (incident.resolvedAt != null) ...[
            const SizedBox(height: 8),
            _buildTimelineItem(
              theme,
              Icons.check_circle,
              l10n.incidents_timeline_resolved,
              _formatFullDateTime(incident.resolvedAt!),
              true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    ThemeData theme,
    IconData icon,
    String label,
    String timestamp,
    bool completed,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: completed
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: completed
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiAnalysisButton(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.incidents_ai_analysis_available,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.incidents_root_cause_analysis_completed,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to AI analysis view
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.incidents_ai_analysis_view_coming_soon),
                ),
              );
            },
            child: Text(l10n.incidents_view_analysis),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisPending(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.incidents_ai_analysis_in_progress,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.incidents_root_cause_analysis_generating,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestAiAnalysisButton(
      BuildContext context, ThemeData theme, int incidentId, WidgetRef ref) {
    final l10n = context.l10n;
    return OutlinedButton.icon(
      onPressed: () {
        // // TODO: Call RequestAiAnalysis use case
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(l10n.incidents_ai_analysis_request_sent),
        //   ),
        // );
        ref.read(goRouterProvider).go('/incident/$incidentId/analysis');
      },
      icon: const Icon(Icons.psychology),
      label: Text(l10n.incidents_request_ai_analysis),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, IncidentStatus status, ThemeData theme) {
    Color color;
    IconData icon;

    switch (status) {
      case IncidentStatus.open:
        color = theme.colorScheme.error;
        icon = Icons.radio_button_checked;
        break;
      case IncidentStatus.investigating:
        color = Colors.orange;
        icon = Icons.search;
        break;
      case IncidentStatus.resolved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case IncidentStatus.acknowledged:
        color = Colors.blue;
        icon = Icons.visibility;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.displayName(context),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(
      BuildContext context, IncidentSeverity severity, ThemeData theme) {
    Color color;
    IconData icon;

    switch (severity) {
      case IncidentSeverity.critical:
        color = Colors.red;
        icon = Icons.error;
        break;
      case IncidentSeverity.high:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case IncidentSeverity.medium:
        color = Colors.yellow;
        icon = Icons.info;
        break;
      case IncidentSeverity.low:
        color = Colors.blue;
        icon = Icons.notifications;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            severity.displayName(context),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

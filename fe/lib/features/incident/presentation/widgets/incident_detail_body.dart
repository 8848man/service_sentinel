import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/incident_provider.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';

/// Incident Detail Body Widget
///
/// Consumes incident data provider.
/// Handles loading, error, and data states inline.
/// This widget rebuilds on provider changes, but the parent screen does not.
class IncidentDetailBody extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailBody({
    super.key,
    required this.incidentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // Watch incident data
    final incidentAsync = ref.watch(incidentByIdProvider(incidentId));

    return incidentAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.incidents_error_loading,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (incident) {
        if (incident == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l10n.incidents_incident_not_found,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getSeverityIcon(incident.severity),
                            size: 32,
                            color: _getSeverityColor(incident.severity),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incident.title,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                if (incident.description != null &&
                                    incident.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      incident.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status and Severity Badges
                      Row(
                        children: [
                          _buildBadge(
                            context,
                            incident.status.displayName(context),
                            _getStatusColor(incident.status),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            context,
                            incident.severity.displayName(context),
                            _getSeverityColor(incident.severity),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      // Incident Details
                      _buildDetailRow(
                        context,
                        l10n.incidents_service_id,
                        incident.serviceId.toString(),
                        Icons.cloud,
                      ),
                      _buildDetailRow(
                        context,
                        l10n.incidents_detected_at,
                        _formatDateTime(incident.detectedAt),
                        Icons.access_time,
                      ),
                      if (incident.acknowledgedAt != null)
                        _buildDetailRow(
                          context,
                          l10n.incidents_acknowledged_at,
                          _formatDateTime(incident.acknowledgedAt!),
                          Icons.check,
                        ),
                      if (incident.resolvedAt != null)
                        _buildDetailRow(
                          context,
                          l10n.incidents_resolved_at,
                          _formatDateTime(incident.resolvedAt!),
                          Icons.done_all,
                        ),
                      _buildDetailRow(
                        context,
                        l10n.incidents_consecutive_failures,
                        '${incident.consecutiveFailures}',
                        Icons.warning,
                      ),
                      _buildDetailRow(
                        context,
                        l10n.incidents_total_affected_checks,
                        '${incident.totalAffectedChecks}',
                        Icons.analytics,
                      ),
                      if (incident.aiAnalysisRequested) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              incident.aiAnalysisCompleted
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 16,
                              color: incident.aiAnalysisCompleted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              incident.aiAnalysisCompleted
                                  ? l10n.incidents_ai_analysis_complete
                                  : l10n.incidents_ai_analysis_pending,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: incident.aiAnalysisCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Analysis Section
              if (incident.aiAnalysisCompleted) ...[
                Text(
                  l10n.incidents_ai_root_cause,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: InkWell(
                    onTap: () {
                      // Navigate to AI analysis detail screen
                      context.go('/incident/${incident.id}/analysis');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.psychology,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.incidents_ai_root_cause_available,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.incidents_view_ai_insights,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Related Health Checks
              Text(
                l10n.incidents_related_health_checks,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      l10n.incidents_related_health_checks_placeholder,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return Icons.error;
      case IncidentSeverity.high:
        return Icons.warning;
      case IncidentSeverity.medium:
        return Icons.info;
      case IncidentSeverity.low:
        return Icons.info_outline;
    }
  }

  Color _getSeverityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return Colors.red.shade700;
      case IncidentSeverity.high:
        return Colors.orange.shade700;
      case IncidentSeverity.medium:
        return Colors.yellow.shade700;
      case IncidentSeverity.low:
        return Colors.blue.shade700;
    }
  }

  Color _getStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return Colors.red;
      case IncidentStatus.acknowledged:
        return Colors.orange;
      case IncidentStatus.resolved:
        return Colors.green;
      case IncidentStatus.investigating:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

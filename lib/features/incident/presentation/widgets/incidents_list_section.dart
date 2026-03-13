import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../presentation/providers/incident_provider.dart';
import '../../domain/entities/incident.dart';
import 'incident_detail_dialog.dart';

/// Incidents list section - Displays all incidents
/// Consumes: incidentsProvider
///
/// Features:
/// - Loading state within section
/// - Error state within section
/// - Incident list with status visualization
/// - Severity badges
/// - Filter by status (TODO: add filter UI)
class IncidentsListSection extends ConsumerWidget {
  const IncidentsListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Observe incidents from incidentsProvider (calls LoadIncidents use case)
    final incidentsAsync = ref.watch(incidentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.incidents_title,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.incidents_desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Loading/Error/Success states within section
        incidentsAsync.when(
          data: (incidents) {
            if (incidents.isEmpty) {
              return _buildEmptyState(context, theme);
            }

            // Group incidents by status
            final openIncidents = incidents.where((i) => i.isOpen).toList();
            final resolvedIncidents =
                incidents.where((i) => i.isResolved).toList();

            return Column(
              children: [
                // Summary cards
                _buildSummaryCards(
                    context, theme, openIncidents, resolvedIncidents),

                const SizedBox(height: 24),

                // Open incidents
                if (openIncidents.isNotEmpty) ...[
                  _buildSectionHeader(context, l10n.incidents_open_incidents,
                      openIncidents.length),
                  const SizedBox(height: 12),
                  ...openIncidents.map((incident) =>
                      _buildIncidentCard(context, ref, incident, theme)),
                  const SizedBox(height: 24),
                ],

                // Resolved incidents
                if (resolvedIncidents.isNotEmpty) ...[
                  _buildSectionHeader(
                      context,
                      l10n.incidents_resolved_incidents,
                      resolvedIncidents.length),
                  const SizedBox(height: 12),
                  ...resolvedIncidents.map((incident) =>
                      _buildIncidentCard(context, ref, incident, theme)),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.incidents_failed_to_load,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(incidentsProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.common_retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.incidents_no_incidents,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.incidents_all_services_running,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ThemeData theme,
    List<Incident> open,
    List<Incident> resolved,
  ) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Card(
            color: open.isEmpty
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${open.length}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.incidents_open_incidents,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: open.isEmpty
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: theme.colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${resolved.length}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.incidents_resolved_incidents,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentCard(
    BuildContext context,
    WidgetRef ref,
    Incident incident,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showIncidentDetail(context, ref, incident),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Severity badge
                  _buildSeverityBadge(context, incident.severity, theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      incident.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(context, incident.status, theme),
                ],
              ),
              if (incident.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  incident.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.incidents_detected(
                        _formatDateTime(context, incident.detectedAt)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.repeat,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n
                        .incidents_failures_count(incident.consecutiveFailures),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (incident.hasAnalysis) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.incidents_ai_analysis_available,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            severity.displayName(context),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName(context),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.services_just_now;
    } else if (difference.inHours < 1) {
      return l10n.services_minutes_ago(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.services_hours_ago(difference.inHours);
    } else {
      return l10n.services_days_ago(difference.inDays);
    }
  }

  Future<void> _showIncidentDetail(
    BuildContext context,
    WidgetRef ref,
    Incident incident,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => IncidentDetailDialog(incident: incident),
    );
  }
}

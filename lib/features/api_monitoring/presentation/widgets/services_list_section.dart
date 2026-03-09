import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/features/api_monitoring/presentation/widgets/create_service_set_dialog.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/providers/service_provider.dart';
import '../../domain/entities/service.dart';
import 'create_service_dialog.dart';

/// Services list section - Displays all services for current project
/// Consumes: servicesProvider
///
/// Features:
/// - Loading state within section
/// - Error state within section
/// - Service list with health status
/// - Create new service
class ServicesListSection extends ConsumerWidget {
  const ServicesListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Observe services from servicesProvider (calls LoadServices use case)
    final servicesAsync = ref.watch(servicesProvider);

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
                  l10n.services_monitored_services,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.services_monitored_services_desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreateServiceDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.services_add_service),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 36), // width만 0, height는 원하는 값 설정
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Loading/Error/Success states within section
        servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return _buildEmptyState(context, theme, ref);
            }

            return Column(
              children: services
                  .map((service) => _buildServiceCard(context, service, theme))
                  .toList(),
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
                    l10n.services_failed_to_load,
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
                    onPressed: () => ref.refresh(servicesProvider),
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

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.api,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.services_no_services_yet,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.services_no_services_message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showCreateGuideServiceDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.services_no_services_recommended_service),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(200, 36), // width만 0, height는 원하는 값 설정
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    Service service,
    ThemeData theme,
  ) {
    return Card(
      // color: _getServiceCardColor(
      //     service.serviceState ?? ServiceState.healthy, theme),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service type icon
                _buildServiceTypeIcon(service.serviceType, theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (service.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                _buildHealthStatus(service.serviceState ?? ServiceState.healthy,
                    theme, context),
                const SizedBox(width: 8),
                // Active/Inactive badge
                _buildStatusBadge(service.isActive, theme, context),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                // HTTP Method
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getHttpMethodColor(service.httpMethod, theme),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    service.httpMethod.displayName(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Endpoint URL
                Expanded(
                  child: Text(
                    service.endpointUrl,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Additional info
            Row(
              children: [
                Icon(Icons.timer,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  context.l10n
                      .services_check_interval(service.checkIntervalSeconds),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.warning,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  context.l10n.services_failure_threshold_value(
                      service.failureThreshold),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (service.lastCheckedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.services_last_checked(
                    _formatDateTime(context, service.lastCheckedAt!)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeIcon(ServiceType type, ThemeData theme) {
    IconData icon;
    switch (type) {
      case ServiceType.httpApi:
      case ServiceType.httpsApi:
        icon = Icons.api;
        break;
      case ServiceType.gcpEndpoint:
        icon = Icons.cloud;
        break;
      case ServiceType.firebase:
        icon = Icons.local_fire_department;
        break;
      case ServiceType.websocket:
        icon = Icons.sync_alt;
        break;
      case ServiceType.grpc:
        icon = Icons.settings_ethernet;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.onPrimaryContainer,
        size: 24,
      ),
    );
  }

  Widget _buildHealthStatus(
      ServiceState state, ThemeData theme, BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: state == ServiceState.healthy
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state == ServiceState.healthy ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: state == ServiceState.healthy
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            state.displayName(context),
            style: theme.textTheme.labelSmall?.copyWith(
              color: state == ServiceState.healthy
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
      bool isActive, ThemeData theme, BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? l10n.services_active : l10n.services_inactive,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHttpMethodColor(HttpMethod method, ThemeData theme) {
    switch (method) {
      case HttpMethod.get:
        return Colors.green;
      case HttpMethod.post:
        return Colors.blue;
      case HttpMethod.put:
        return Colors.orange;
      case HttpMethod.delete:
        return Colors.red;
      case HttpMethod.patch:
        return Colors.purple;
      case HttpMethod.head:
        return Colors.grey;
    }
  }

  Color _getServiceCardColor(ServiceState state, ThemeData theme) {
    switch (state) {
      case ServiceState.healthy:
        return theme.colorScheme.surfaceVariant;
      case ServiceState.error:
        return theme.colorScheme.errorContainer;
      case ServiceState.inactive:
        return theme.colorScheme.surface;
    }
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

  Future<void> _showCreateServiceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<Service>(
      context: context,
      builder: (context) => const CreateServiceDialog(),
    );

    // Refresh services list if service was created
    if (result != null) {
      ref.refresh(servicesProvider);
    }
  }

  Future<void> _showCreateGuideServiceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<Service>(
      context: context,
      builder: (context) => const CreateServiceSetDialog(),
    );

    // Refresh services list if service was created
    if (result != null) {
      ref.refresh(servicesProvider);
    }
  }
}

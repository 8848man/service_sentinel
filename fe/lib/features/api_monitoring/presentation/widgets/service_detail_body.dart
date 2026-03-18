import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/service.dart';
import '../providers/service_provider.dart';

/// Service Detail Body Widget
///
/// Consumes service data and health check providers.
/// Handles loading, error, and data states inline.
/// This widget rebuilds on provider changes, but the parent screen does not.
class ServiceDetailBody extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailBody({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // Watch service data
    final serviceAsync = ref.watch(serviceByIdProvider(int.parse(serviceId)));
    final statsAsync =
        ref.watch(serviceStatsProvider(int.parse(serviceId), '7d'));

    return serviceAsync.when(
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
              l10n.services_error_loading_service,
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
      data: (service) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (service.description != null &&
                                  service.description!.isNotEmpty)
                                Text(
                                  service.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: service.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            service.isActive
                                ? l10n.services_active
                                : l10n.services_inactive,
                            style: TextStyle(
                              color:
                                  service.isActive ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Monitoring toggle
                    Row(
                      children: [
                        const Icon(Icons.monitor_heart_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Monitoring')),
                        Switch(
                          value: service.isActive,
                          onChanged: (val) => _toggleServiceMonitoring(context, ref, service, val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Service Configuration
                    _buildConfigRow(
                      context,
                      l10n.services_endpoint,
                      service.endpointUrl,
                      Icons.link,
                    ),
                    _buildConfigRow(
                      context,
                      l10n.services_method,
                      service.httpMethod.displayName(context),
                      Icons.http,
                    ),
                    _buildConfigRow(
                      context,
                      l10n.services_type,
                      service.serviceType.displayName(context),
                      Icons.category,
                    ),
                    _buildConfigRow(
                      context,
                      l10n.services_check_interval_label,
                      '${service.checkIntervalSeconds}s',
                      Icons.timer,
                    ),
                    _buildConfigRow(
                      context,
                      l10n.services_timeout_label,
                      '${service.timeoutSeconds}s',
                      Icons.hourglass_empty,
                    ),
                    _buildConfigRow(
                      context,
                      l10n.services_failure_threshold_label,
                      '${service.failureThreshold}',
                      Icons.warning,
                    ),
                    if (service.lastCheckedAt != null)
                      _buildConfigRow(
                        context,
                        l10n.services_last_checked_label,
                        _formatDateTime(service.lastCheckedAt!),
                        Icons.access_time,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Statistics
            Text(
              l10n.services_statistics_last_7_days,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.services_unable_to_load_statistics,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ),
              ),
              data: (stats) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    l10n.services_uptime,
                    '${stats.uptimePercentage.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    l10n.services_total_checks,
                    stats.totalChecks.toString(),
                    Icons.analytics,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    l10n.services_successful,
                    stats.successfulChecks.toString(),
                    Icons.done,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    l10n.services_failed,
                    stats.failedChecks.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                  _buildStatCard(
                    context,
                    l10n.services_avg_latency,
                    '${stats.averageLatencyMs.toStringAsFixed(0)}ms',
                    Icons.speed,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder: Health Check History
            Text(
              l10n.services_health_check_history,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    l10n.services_health_check_history_placeholder,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder: Incidents
            Text(
              l10n.services_related_incidents,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    l10n.services_related_incidents_placeholder,
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
      ),
    );
  }

  Widget _buildConfigRow(
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleServiceMonitoring(
    BuildContext context,
    WidgetRef ref,
    Service service,
    bool newValue,
  ) async {
    final updateUseCase = ref.read(updateServiceProvider);
    final result = await updateUseCase.execute(
      service.id,
      ServiceUpdate(isActive: newValue),
    );
    if (context.mounted) {
      if (result.isSuccess) {
        ref.invalidate(serviceByIdProvider(service.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monitoring will update on the next check cycle.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorOrNull?.message ?? 'Failed to toggle monitoring')),
        );
      }
    }
  }
}

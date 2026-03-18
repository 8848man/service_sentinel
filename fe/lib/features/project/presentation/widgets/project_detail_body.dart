import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/project_provider.dart';
import '../../domain/entities/project.dart';
import '../../../../core/theme/app_colors.dart';

/// Project Detail Body Widget
///
/// Consumes project data and stats providers.
/// Handles loading, error, and data states inline.
/// This widget rebuilds on provider changes, but the parent screen does not.
class ProjectDetailBody extends ConsumerWidget {
  final String projectId;

  const ProjectDetailBody({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch project data
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final statsAsync = ref.watch(projectStatsProvider(projectId));

    return projectAsync.when(
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
              'Error loading project',
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
      data: (project) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (project.description != null &&
                                  project.description!.isNotEmpty)
                                Text(
                                  project.description!,
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
                            color: project.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            project.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: project.isActive ? Colors.green : Colors.grey,
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
                          value: project.isActive,
                          onChanged: (val) => _toggleMonitoring(context, ref, project, val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Project Metadata
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Created: ${_formatDate(project.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.update, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Updated: ${_formatDate(project.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (project.isLocalOnly) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Local Only (Not synced to server)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontStyle: FontStyle.italic,
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

            // Project Statistics
            Text(
              'Statistics',
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
                    'Unable to load statistics',
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
                    'Total Services',
                    stats.totalServices.toString(),
                    Icons.cloud,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    'Healthy',
                    stats.healthyServices.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'Unhealthy',
                    stats.unhealthyServices.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                  _buildStatCard(
                    context,
                    'Open Incidents',
                    stats.openIncidents.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder Sections
            Text(
              'Services',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Service list will be displayed here',
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMonitoring(
    BuildContext context,
    WidgetRef ref,
    Project project,
    bool newValue,
  ) async {
    final updateUseCase = ref.read(updateProjectProvider);
    final result = await updateUseCase.execute(
      project.id.toString(),
      ProjectUpdate(isActive: newValue),
    );
    if (context.mounted) {
      if (result.isSuccess) {
        ref.invalidate(projectByIdProvider(project.id.toString()));
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

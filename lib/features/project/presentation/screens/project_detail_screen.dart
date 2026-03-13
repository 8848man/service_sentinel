import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../presentation/providers/project_provider.dart';
import '../widgets/project_detail_body.dart';

/// Project Detail Screen
///
/// Displays detailed information about a specific project.
/// This screen is layout-only; all provider consumption happens in child widgets.
///
/// Route: /project/:id
/// Parameters: projectId (String)
class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Project',
            onPressed: () {
              // TODO: Navigate to project edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Project',
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: ProjectDetailBody(projectId: projectId),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This will delete all associated services and data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Delete project
    final useCase = ref.read(deleteProjectProvider);
    final result = await useCase.execute(projectId);

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (result.isSuccess) {
      // Invalidate projects list
      ref.invalidate(projectsProvider);

      // Navigate back
      context.go(AppRoutes.projectSelection);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete project: ${result.errorOrNull?.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

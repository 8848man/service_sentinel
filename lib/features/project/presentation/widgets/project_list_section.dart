import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';
import '../../../../core/di/repository_providers.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/project_session_notifier.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';
import '../../application/providers/project_provider.dart';
import '../../domain/entities/api_key.dart';
import '../../domain/entities/project.dart';
import 'project_create_dialog.dart';

/// Project list section - Displays all projects and allows creation
/// Consumes: projectsProvider, authStateNotifierProvider
///
/// Features:
/// - Displays loading state within section
/// - Displays error state within section
/// - Shows list of projects
/// - Allows project creation via dialog
/// - Handles project selection (sets project context and navigates to main)
class ProjectListSection extends ConsumerWidget {
  const ProjectListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Observe projects from projectsProvider (calls LoadProjects use case)
    final projectsAsync = ref.watch(projectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.projects_your_projects,
              style: theme.textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreateProjectDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.projects_new_project),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Loading/Error/Success states within section (not full screen)
        projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return _buildEmptyState(context, theme);
            }

            return Column(
              children: projects
                  .map((project) =>
                      _buildProjectCard(context, ref, project, theme))
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.projects_failed_to_load,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(projectsProvider),
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.projects_no_projects_yet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.projects_create_first_project,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    WidgetRef ref,
    Project project,
    ThemeData theme,
  ) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: _getCardColor(theme, project),
      child: ListTile(
        leading: Icon(
          project.isLocalOnly ? Icons.phonelink : Icons.cloud_done,
          color: theme.colorScheme.primary,
        ),
        title: Text(project.name),
        subtitle: project.description != null
            ? Text(
                project.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!project.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.services_inactive,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () => _handleProjectSelection(context, ref, project),
      ),
    );
  }

  /// Handle project selection
  /// - For authenticated users: Fetch API keys, load values from storage, select active key
  /// - For guests: Just set project (no API key needed)
  Future<void> _handleProjectSelection(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get auth state to determine if user is authenticated
      final authState = ref.read(authStateNotifierProvider).value;

      if (authState == null) {
        if (context.mounted) Navigator.of(context).pop();
        return;
      }
      final projectSession = ref.read(projectSessionProvider.notifier);
      final secureStorage = ref.read(secureStorageProvider);
      if (authState.isAuthenticated) {
        // For authenticated users, fetch API keys from backend
        final apiKeyRepository = ref.read(apiKeyRepositoryProvider);

        final apiKeysResult =
            await apiKeyRepository.getAll(project.id.toString());

        if (apiKeysResult.isFailure) {
          if (context.mounted) {
            final l10n = context.l10n;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.projects_failed_to_load_api_keys(
                    apiKeysResult.errorOrNull?.message ?? '')),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Get API keys from backend (without keyValue for security)
        final apiKeysFromBackend = apiKeysResult.dataOrNull ?? [];

        // Load saved key values from secure storage
        final apiKeysWithValues = <ApiKey>[];
        for (final key in apiKeysFromBackend) {
          final savedValue = await secureStorage.getApiKeyValue(key.id);
          if (savedValue != null) {
            // We have the key value stored locally
            apiKeysWithValues.add(key.copyWith(keyValue: savedValue));
          } else {
            // Key value not stored - user needs to create/configure
            apiKeysWithValues.add(key);
          }
        }

        // Create complete Project with API keys
        final projectWithKeys = project.copyWith(apiKeys: apiKeysWithValues);

        // Check if user has a saved active API key preference
        final savedActiveKeyId =
            await secureStorage.getActiveApiKeyId(project.id.toString());

        String? selectedKeyId;

        if (savedActiveKeyId != null) {
          // Check if saved key still exists and is usable
          final savedKey = projectWithKeys.getApiKeyById(savedActiveKeyId);
          if (savedKey != null &&
              savedKey.isUsable &&
              savedKey.keyValue != null) {
            selectedKeyId = savedActiveKeyId;
          }
        }
        // If no valid saved key, try to auto-select the most recently used usable key
        // if (selectedKeyId == null) {
        //   final usableKeys = projectWithKeys.usableApiKeys
        //       .where((key) => key.keyValue != null)
        //       .toList();

        //   if (usableKeys.isEmpty) {
        //     // No usable keys with values - show warning
        //     if (context.mounted) {
        //       Navigator.of(context).pop();
        //       _showNoApiKeyWarning(context, project);
        //     }
        //     return;
        //   }

        //   // Auto-select most recently used key
        //   final mostRecent = projectWithKeys.mostRecentlyUsedApiKey;
        //   selectedKeyId = mostRecent?.id ?? usableKeys.first.id;
        // }

        // Select project with active API key
        await projectSession.selectProject(
          projectWithKeys,
          activeApiKeyId: selectedKeyId,
        );

        // Update auth state with selected project
        await ref.read(authStateNotifierProvider.notifier).setProjectContext(
              project.id.toString(),
            );
      } else {
        // Guest mode - no API key needed
        await projectSession.selectProject(project);
        await ref.read(authStateNotifierProvider.notifier).setProjectContext(
              project.id.toString(),
            );
      }

      // Persist selected project ID
      await secureStorage.saveCurrentProjectId(project.id.toString());

      // Close loading and navigate to main dashboard
      if (context.mounted) {
        // Navigator.of(context).pop();
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = context.l10n;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.projects_error_selecting(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show warning when no API key is configured
  void _showNoApiKeyWarning(BuildContext context, Project project) {
    if (context.mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.projects_no_api_key_warning),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.settings_title,
            textColor: Colors.white,
            onPressed: () {
              context.go(AppRoutes.settings);
            },
          ),
        ),
      );
    }
  }

  Future<void> _showCreateProjectDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<Project>(
      context: context,
      builder: (context) => const ProjectCreateDialog(),
    );

    // Refresh projects list if project was created
    if (result != null) {
      ref.refresh(projectsProvider);
    }
  }

  Color? _getCardColor(ThemeData theme, Project project) {
    switch (project.health?.status) {
      case ProjectHealthStatus.healthy:
        // return Colors.green.withOpacity(0.1);
        return null;
      case ProjectHealthStatus.degraded:
        return Colors.red.withOpacity(0.2);
      case ProjectHealthStatus.unknown:
        return null;
      default:
        return null;
    }
  }
}

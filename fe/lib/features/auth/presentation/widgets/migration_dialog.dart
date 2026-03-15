import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Migration dialog - Shown when guest user logs in with local projects
/// Blocking dialog that allows user to:
/// 1. Migrate local projects to server
/// 2. Skip migration (local projects remain local-only)
///
/// Returns: true if user wants to migrate, false if user wants to skip
class MigrationDialog extends StatelessWidget {
  const MigrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AlertDialog(
      icon: Icon(
        Icons.cloud_upload_outlined,
        size: 64,
        color: theme.colorScheme.primary,
      ),
      title: Text(l10n.auth_migration_dialog_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.auth_migration_dialog_message,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            Icons.cloud_done,
            l10n.auth_migration_cloud_sync,
            l10n.auth_migration_cloud_sync_desc,
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            context,
            Icons.backup,
            l10n.auth_migration_backup,
            l10n.auth_migration_backup_desc,
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            context,
            Icons.group,
            l10n.auth_migration_team,
            l10n.auth_migration_team_desc,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.auth_skip_for_now),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.cloud_upload),
          label: Text(l10n.auth_migrate_now),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

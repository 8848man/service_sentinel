import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../extensions/context_extensions.dart';
import '../../../state/project_session_notifier.dart';
import '../../../auth/application/providers/auth_provider.dart';

/// API Key settings section - Manage API keys for authenticated users
/// Consumes: authStateNotifierProvider, projectSessionProvider
///
/// Features:
/// - Visible ONLY when authenticated
/// - Disabled for Guest users
/// - Display current project's API key (masked)
/// - Copy API key to clipboard
/// - Generate new API key (placeholder)
///
/// Note: For guest users, this section is completely hidden
/// Note: API keys are now project-specific (managed by ProjectSession)
class ApiKeySettingsSection extends ConsumerWidget {
  const ApiKeySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Observe auth state and project session
    final authStateAsync = ref.watch(authStateNotifierProvider);
    final projectSession = ref.watch(projectSessionProvider);

    return authStateAsync.when(
      data: (authState) {
        // Hide section completely for guest users
        if (!authState.isAuthenticated) {
          return const SizedBox.shrink();
        }

        final hasApiKey = projectSession.hasApiKey;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.settings_api_key,
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 14,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.settings_authenticated,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (projectSession.hasProject) ...[
                  // Text(
                  //   l10n.settings_api_key_desc(
                  //     projectSession.projectName ??
                  //         projectSession.projectId ??
                  //         '',
                  //   ),
                  //   style: theme.textTheme.bodySmall?.copyWith(
                  //     color: theme.colorScheme.onSurface.withOpacity(0.7),
                  //   ),
                  // ),
                  if (projectSession.activeApiKeyName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.settings_active_key(
                          projectSession.activeApiKeyName!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ] else
                  Text(
                    l10n.settings_no_project_api_key,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error.withOpacity(0.7),
                    ),
                  ),
                const SizedBox(height: 16),

                if (hasApiKey) ...[
                  // Current API key display (masked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _maskApiKey(projectSession.activeApiKeyValue!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: l10n.settings_copy_to_clipboard,
                          onPressed: () => _copyToClipboard(
                            context,
                            projectSession.activeApiKeyValue!,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.settings_security_warning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else ...[
                  // No API key set
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.settings_no_api_key,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    // Switch API key button (placeholder)
                    OutlinedButton.icon(
                      onPressed: projectSession.hasProject
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(l10n.settings_switch_key_response),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(l10n.settings_switch_key),
                    ),
                    const SizedBox(width: 8),
                    // Create new API key button (placeholder)
                    ElevatedButton.icon(
                      onPressed: projectSession.hasProject
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(l10n.settings_create_key_response),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.settings_create_key),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Mask API key for display (show first 8 and last 4 characters)
  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 12) {
      return '•' * apiKey.length;
    }

    final start = apiKey.substring(0, 8);
    final end = apiKey.substring(apiKey.length - 4);
    final masked = '•' * (apiKey.length - 12);

    return '$start$masked$end';
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settings_api_key_copied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

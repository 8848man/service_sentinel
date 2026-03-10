import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/settings/presentation/view_models/common_settings_view_model.dart';

import '../../../extensions/context_extensions.dart';
import '../../../l10n/locale_provider.dart';
import '../../../router/app_router.dart';
import '../../../state/project_session_notifier.dart';
import '../../../theme/app_theme_mode.dart';
import '../../../theme/theme_provider.dart';
import '../../../auth/application/providers/auth_provider.dart';
import '../widgets/api_key_settings_section.dart';

/// Settings screen - App settings and preferences
/// Layout only. Provider consumption happens in section widgets.
///
/// Features:
/// - Theme selection
/// - Language selection
/// - API key management (authenticated users only)
/// - Account settings
class CommonSettingsScreen extends StatelessWidget {
  const CommonSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // General settings section
              _GeneralSettingsSection(),

              SizedBox(height: 24),

              // Account section
              _AccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// General settings section (theme, language)
class _GeneralSettingsSection extends ConsumerWidget {
  const _GeneralSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notifier = ref.read(commonSettingsViewModelProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settings_general,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Theme selector
            ListTile(
              leading: Icon(
                themeMode == AppThemeMode.dark
                    ? Icons.dark_mode
                    : themeMode == AppThemeMode.light
                        ? Icons.light_mode
                        : Icons.brightness_auto,
              ),
              title: Text(l10n.settings_theme),
              subtitle: Text(_getThemeModeLabel(context, themeMode)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showThemeSelector(context, ref, themeMode),
            ),

            const Divider(),

            // Language selector
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.settings_language),
              subtitle: Text(locale.languageCode.toUpperCase()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageSelector(context, ref, locale),
            ),

            const Divider(),

            // Language selector
            ListTile(
              leading: const Icon(Icons.message),
              title: Text(l10n.settings_notifications),
              subtitle: Text(l10n.settings_notification_subtitle),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => notifier.requestPermission(),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeLabel(BuildContext context, AppThemeMode mode) {
    final l10n = context.l10n;
    switch (mode) {
      case AppThemeMode.light:
        return l10n.settings_light;
      case AppThemeMode.dark:
        return l10n.settings_dark;
      case AppThemeMode.blue:
        return l10n.settings_blue;
    }
  }

  Future<void> _showThemeSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) async {
    final l10n = context.l10n;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_select_theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values
              .map((mode) => RadioListTile<AppThemeMode>(
                    value: mode,
                    groupValue: currentMode,
                    title: Text(_getThemeModeLabel(context, mode)),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(value);
                        Navigator.of(dialogContext).pop();
                      }
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) async {
    final l10n = context.l10n;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_select_language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'en',
              groupValue: currentLocale.languageCode,
              title: Text(l10n.settings_english),
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(AppLocale.en);
                Navigator.of(dialogContext).pop();
              },
            ),
            RadioListTile<String>(
              value: 'ko',
              groupValue: currentLocale.languageCode,
              title: Text(l10n.settings_korean),
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(AppLocale.ko);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }
}

/// Account section (logout, etc.)
class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Observe auth state
    final authStateAsync = ref.watch(authStateNotifierProvider);

    return authStateAsync.when(
      data: (authState) {
        if (!authState.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // User info
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(l10n.settings_signed_in_as),
                  subtitle: Text(authState.user.email),
                ),

                const Divider(),

                // Logout button
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    l10n.settings_sign_out,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _handleLogout(context, ref),
                ),

                // Logout button
                ListTile(
                  leading: Icon(Icons.delete, color: theme.colorScheme.error),
                  title: Text(
                    l10n.settings_delete_account,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _handleDeleteAccount(context, ref),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Handle logout with confirmation
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_sign_out),
        content: Text(l10n.settings_sign_out_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authStateNotifierProvider.notifier).signOut();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.settings_sign_out),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Sign out
    await ref.read(authStateNotifierProvider.notifier).signOut();

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    // Navigate to login screen
    context.go(AppRoutes.login);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settings_signed_out)),
    );
  }

  /// Handle logout with confirmation
  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_delete_account),
        content: Text(l10n.settings_delete_account_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authStateNotifierProvider.notifier).deleteAccount();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.settings_delete_account),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Sign out
    // await ref.read(authStateNotifierProvider.notifier).deleteAccount();

    // if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    // Navigate to login screen
    context.go(AppRoutes.login);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settings_delete_account)),
    );
  }
}

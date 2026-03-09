import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/router/app_router.dart';
import 'package:service_sentinel_fe_v2/core/settings/presentation/screens/common_settings_screen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';
import '../widgets/project_list_section.dart';
import '../widgets/project_header_section.dart';

/// Project selection screen - Choose or create a project
/// Layout only. Provider consumption happens in section widgets.
///
/// Observes:
/// - authStateNotifierProvider (for user info and logout)
/// - projectsProvider (via ProjectListSection)
///
/// Features:
/// - Display all projects
/// - Create new project
/// - Select project and navigate to main
/// - Handle source of truth (Local vs Server based on auth state)
class ProjectSelectionScreen extends StatelessWidget {
  const ProjectSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.app_title),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) =>
                    Dialog(child: const CommonSettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
          // Logout action (ConsumerWidget)
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authStateNotifierProvider).value;
              final isAuthenticated = authState?.isAuthenticated ?? false;

              if (!isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: l10n.projects_sign_in,
                  onPressed: () async {
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                );
              }

              return IconButton(
                icon: const Icon(Icons.logout),
                tooltip: l10n.settings_sign_out,
                onPressed: () async {
                  // Call authStateNotifierProvider.signOut()
                  await ref.read(authStateNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section (shows user info and mode)
            ProjectHeaderSection(),

            SizedBox(height: 24),

            // Project list section (ConsumerWidget)
            ProjectListSection(),
          ],
        ),
      ),
    );
  }
}

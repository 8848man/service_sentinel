import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/state/project_session_notifier.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/application/providers/dashboard_provider.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';

/// Dashboard screen - Overview of project and services
/// Layout only. Provider consumption happens in section widgets.
///
/// Features:
/// - Welcome message with user info
/// - Project overview
/// - Quick stats
/// - Quick actions
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              _WelcomeSection(),

              SizedBox(height: 24),

              // Quick stats section (placeholder)
              _QuickStatsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Welcome section - Shows user info and current project
class _WelcomeSection extends ConsumerWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboard_welcome_back,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      _buildUserInfo(theme),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProjectInfo(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final authStateAsync = ref.watch(authStateNotifierProvider);
        final l10n = context.l10n;

        return authStateAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (authState) {
            return Text(
              authState.isAuthenticated
                  ? authState.user.email ?? 'User'
                  : l10n.dashboard_guest_mode,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            );
          },
        );
      },
    );
  }

  Consumer _buildProjectInfo(
    ThemeData theme,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final projectSession = ref.watch(projectSessionProvider);
        final l10n = context.l10n;

        if (projectSession.hasProject) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dashboard_current_project(
                      projectSession.projectName ?? ''),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.dashboard_no_project_selected,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Quick stats section - Show basic statistics
class _QuickStatsSection extends ConsumerWidget {
  const _QuickStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final dashboardState = ref.watch(dashboardOverviewProvider);

    return dashboardState.when(
      data: (data) {
        return _buildAsyncScreenFrame(
            theme: theme, data: data, context: context);
      },
      loading: () {
        return _buildAsyncScreenFrame(theme: theme, context: context);
      },
      error: (error, stack) {
        return _buildAsyncScreenFrame(theme: theme, context: context);
      },
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color backgroundColor,
  ) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsyncScreenFrame(
      {required ThemeData theme,
      DashboardOverview? data,
      required BuildContext context}) {
    final l10n = context.l10n;
    final String servicesCount = data?.totalServices.toString() ?? '-';
    final String incidentsCount = data?.unhealthyServices.toString() ?? '-';
    final String healthyCount = data?.healthyServices.toString() ?? '-';
    final String issuesCount = data != null
        ? (data.totalServices - data.healthyServices).toString()
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboard_quick_stats,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.api,
                l10n.dashboard_services,
                servicesCount,
                theme.colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.error_outline,
                l10n.dashboard_incidents,
                incidentsCount,
                theme.colorScheme.errorContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.check_circle,
                l10n.dashboard_healthy,
                healthyCount,
                theme.colorScheme.tertiaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.warning,
                l10n.dashboard_issues,
                issuesCount,
                theme.colorScheme.secondaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';

/// Project header section - Shows user info and current mode
/// Consumes: authStateNotifierProvider
///
/// Displays:
/// - User email (if authenticated) or "Guest Mode"
/// - Source of truth badge (Local / Cloud)
class ProjectHeaderSection extends ConsumerWidget {
  const ProjectHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Observe auth state from authStateNotifierProvider
    final authStateAsync = ref.watch(authStateNotifierProvider);

    return authStateAsync.when(
      data: (authState) {
        final isAuthenticated = authState.isAuthenticated;
        final user = authState.user;
        final sourceOfTruth = authState.sourceOfTruth;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAuthenticated ? Icons.person : Icons.person_outline,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAuthenticated
                                ? user.email ?? 'Authenticated User'
                                : 'Guest Mode',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          _buildSourceOfTruthBadge(theme, sourceOfTruth),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isAuthenticated
                      ? 'Your projects are synced to the cloud'
                      : 'Your projects are stored locally on this device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
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
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading auth state',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOfTruthBadge(
      ThemeData theme, SourceOfTruth sourceOfTruth) {
    final isLocal = sourceOfTruth == SourceOfTruth.local;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocal
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocal ? Icons.phonelink : Icons.cloud,
            size: 14,
            color: isLocal
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            isLocal ? 'Local Storage' : 'Cloud Storage',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isLocal
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

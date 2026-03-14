import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/extensions/context_extensions.dart';
import 'package:service_sentinel_fe_v2/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';

/// Splash screen - Initial loading screen
/// Resolves auth state on app start and navigates accordingly
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and resolve navigation
  /// - Check auth state via authStateNotifierProvider
  /// - Navigate based on authentication status and project context
  Future<void> _initializeApp() async {
    // Wait for auth state to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Observe auth state from authStateNotifierProvider
    ref.read(authStateNotifierProvider).when(
      data: (authState) {
        if (!mounted) return;

        // If authenticated and has project context, go to main
        if (authState.hasProjectContext) {
          context.go(AppRoutes.dashboard);
        }
        // If authenticated but no project context, go to project selection
        else if (authState.isAuthenticated) {
          context.go(AppRoutes.projectSelection);
        }
        // If guest (not authenticated), go to login
        else {
          context.go(AppRoutes.login);
        }
      },
      loading: () {
        // Stay on splash while loading
      },
      error: (error, stack) {
        // On error, default to login
        if (mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    ref.watch(authStateNotifierProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.app_title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.app_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

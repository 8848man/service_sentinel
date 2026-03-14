import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/extensions/context_extensions.dart';
import '../router/app_router.dart';

/// Main scaffold with bottom navigation
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(currentPath),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navigation_dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_outlined),
            selectedIcon: const Icon(Icons.cloud),
            label: l10n.navigation_services,
          ),
          NavigationDestination(
            icon: const Icon(Icons.warning_amber_outlined),
            selectedIcon: const Icon(Icons.warning_amber),
            label: l10n.navigation_incidents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navigation_settings,
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String path) {
    if (path.startsWith(AppRoutes.dashboard)) return 0;
    if (path.startsWith(AppRoutes.services)) return 1;
    if (path.startsWith(AppRoutes.incidents)) return 2;
    if (path.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.services);
        break;
      case 2:
        context.go(AppRoutes.incidents);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }
}

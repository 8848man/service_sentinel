import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/locale_provider.dart';
import '../theme/app_theme_mode.dart';
import '../theme/theme_provider.dart';

/// Shared AppBar for all /main/* routes.
///
/// Actions:
/// - Language toggle: cycles en ↔ ko
/// - Theme toggle: cycles light → dark → blue
class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return AppBar(
      title: Text(title),
      actions: [
        // Language toggle — cycles en ↔ ko
        IconButton(
          icon: Text(
            locale.languageCode.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          tooltip: locale.languageCode == 'en' ? '한국어' : 'English',
          onPressed: () {
            final next =
                locale.languageCode == 'en' ? AppLocale.ko : AppLocale.en;
            ref.read(localeProvider.notifier).setLocale(next);
          },
        ),
        // Theme toggle — cycles light → dark → blue → light
        IconButton(
          icon: Icon(_themeIcon(themeMode)),
          tooltip: _nextThemeMode(themeMode).displayName,
          onPressed: () {
            ref
                .read(themeModeProvider.notifier)
                .setThemeMode(_nextThemeMode(themeMode));
          },
        ),
      ],
    );
  }

  IconData _themeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.blue:
        return Icons.brightness_auto;
    }
  }

  AppThemeMode _nextThemeMode(AppThemeMode current) {
    final values = AppThemeMode.values;
    return values[(values.indexOf(current) + 1) % values.length];
  }
}

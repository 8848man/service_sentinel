import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';

/// Root application widget
class ServiceSentinelApp extends ConsumerWidget {
  const ServiceSentinelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Service Sentinel',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.getTheme(themeMode),
      themeMode: ThemeMode.light, // Always use theme from AppTheme

      // Localization configuration
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router configuration
      routerConfig: goRouter,
    );
  }
}

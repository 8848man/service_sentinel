import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'l10n/strings.dart';
import 'features/landing/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fontLoader = FontLoader('NotoSansKR')
    ..addFont(rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansKR-Medium.ttf'));

  await fontLoader.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleNotifier(),
      child: const ServiceSentinelApp(),
    ),
  );
}

class ServiceSentinelApp extends StatelessWidget {
  const ServiceSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Sentinel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll(false),
        ),
      ),
      home: const LandingPage(),
    );
  }
}

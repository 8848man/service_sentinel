import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales
enum AppLocale {
  en,
  ko;

  Locale get locale {
    switch (this) {
      case AppLocale.en:
        return const Locale('en');
      case AppLocale.ko:
        return const Locale('ko');
    }
  }

  String get displayName {
    switch (this) {
      case AppLocale.en:
        return 'English';
      case AppLocale.ko:
        return '한국어';
    }
  }

  static AppLocale fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return AppLocale.ko;
      case 'en':
      default:
        return AppLocale.en;
    }
  }
}

/// Storage key for locale preference
const String _localePreferenceKey = 'app_locale';

/// Provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Locale state notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocalePreference();
  }

  /// Load locale preference from local storage
  Future<void> _loadLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localePreferenceKey);
      if (localeCode != null) {
        state = Locale(localeCode);
      }
    } catch (e) {
      // If loading fails, keep default English locale
      state = const Locale('en');
    }
  }

  /// Set locale and persist to storage
  Future<void> setLocale(AppLocale appLocale) async {
    state = appLocale.locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePreferenceKey, appLocale.locale.languageCode);
    } catch (e) {
      // Log error but don't prevent locale change
    }
  }
}

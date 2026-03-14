import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_mode.dart';

/// Storage key for theme preference
const String _themePreferenceKey = 'app_theme_mode';

/// Provider for theme mode state
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.dark) {
    _loadThemePreference();
  }

  /// Load theme preference from local storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themePreferenceKey);
      if (themeName != null) {
        state = AppThemeMode.values.firstWhere(
          (mode) => mode.name == themeName,
          orElse: () => AppThemeMode.dark,
        );
      }
    } catch (e) {
      // If loading fails, keep default light theme
      state = AppThemeMode.dark;
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, mode.name);
    } catch (e) {
      // Log error but don't prevent theme change
    }
  }
}

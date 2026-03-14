/// Enumeration of available theme modes
enum AppThemeMode {
  light,
  dark,
  blue;

  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.blue:
        return 'Blue';
    }
  }
}

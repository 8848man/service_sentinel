import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// BuildContext extensions for convenient access to common services
extension BuildContextX on BuildContext {
  /// Get localized strings
  /// Usage: context.l10n.dashboard_title
  AppLocalizations get l10n => AppLocalizations.of(this);
}

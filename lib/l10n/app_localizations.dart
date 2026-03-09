import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get common_or;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get common_create;

  /// No description provided for @common_creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get common_creating;

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Service Sentinel'**
  String get app_title;

  /// No description provided for @app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered API Monitoring'**
  String get app_subtitle;

  /// No description provided for @navigation_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navigation_dashboard;

  /// No description provided for @navigation_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navigation_services;

  /// No description provided for @navigation_incidents.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get navigation_incidents;

  /// No description provided for @navigation_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigation_settings;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_signup;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_guest_mode.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get auth_guest_mode;

  /// No description provided for @auth_guest_mode_desc.
  ///
  /// In en, this message translates to:
  /// **'Use the app without signing in. Your data stays on this device.'**
  String get auth_guest_mode_desc;

  /// No description provided for @auth_enter_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Enter as Guest'**
  String get auth_enter_as_guest;

  /// No description provided for @auth_sign_in_email.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get auth_sign_in_email;

  /// No description provided for @auth_sign_in_google.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google Email'**
  String get auth_sign_in_google;

  /// No description provided for @auth_sign_in_desc.
  ///
  /// In en, this message translates to:
  /// **'Access your projects from any device with cloud sync.'**
  String get auth_sign_in_desc;

  /// No description provided for @auth_dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get auth_dont_have_account;

  /// No description provided for @auth_signing_in.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get auth_signing_in;

  /// No description provided for @auth_login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get auth_login_failed;

  /// No description provided for @auth_creating_account.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get auth_creating_account;

  /// No description provided for @auth_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_sign_up;

  /// No description provided for @auth_sign_up_email.
  ///
  /// In en, this message translates to:
  /// **'Sign Up with Email'**
  String get auth_sign_up_email;

  /// No description provided for @auth_sign_up_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign up to create a new account'**
  String get auth_sign_up_desc;

  /// No description provided for @auth_signup_failed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get auth_signup_failed;

  /// No description provided for @auth_sign_up_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get auth_sign_up_cancel;

  /// No description provided for @auth_migration_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Migrate Local Projects?'**
  String get auth_migration_dialog_title;

  /// No description provided for @auth_migration_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'You have local projects stored on this device. Would you like to migrate them to the cloud?'**
  String get auth_migration_dialog_message;

  /// No description provided for @auth_migration_cloud_sync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get auth_migration_cloud_sync;

  /// No description provided for @auth_migration_cloud_sync_desc.
  ///
  /// In en, this message translates to:
  /// **'Access your projects from any device'**
  String get auth_migration_cloud_sync_desc;

  /// No description provided for @auth_migration_backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get auth_migration_backup;

  /// No description provided for @auth_migration_backup_desc.
  ///
  /// In en, this message translates to:
  /// **'Your data is safely backed up'**
  String get auth_migration_backup_desc;

  /// No description provided for @auth_migration_team.
  ///
  /// In en, this message translates to:
  /// **'Team Collaboration'**
  String get auth_migration_team;

  /// No description provided for @auth_migration_team_desc.
  ///
  /// In en, this message translates to:
  /// **'Share projects with team members'**
  String get auth_migration_team_desc;

  /// No description provided for @auth_skip_for_now.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get auth_skip_for_now;

  /// No description provided for @auth_migrate_now.
  ///
  /// In en, this message translates to:
  /// **'Migrate Now'**
  String get auth_migrate_now;

  /// No description provided for @dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// No description provided for @dashboard_welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get dashboard_welcome_back;

  /// No description provided for @dashboard_guest_mode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get dashboard_guest_mode;

  /// No description provided for @dashboard_current_project.
  ///
  /// In en, this message translates to:
  /// **'Current Project: {projectName}'**
  String dashboard_current_project(String projectName);

  /// No description provided for @dashboard_no_project_selected.
  ///
  /// In en, this message translates to:
  /// **'No project selected. Please select a project to start monitoring.'**
  String get dashboard_no_project_selected;

  /// No description provided for @dashboard_quick_stats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get dashboard_quick_stats;

  /// No description provided for @dashboard_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get dashboard_services;

  /// No description provided for @dashboard_incidents.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get dashboard_incidents;

  /// No description provided for @dashboard_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get dashboard_healthy;

  /// No description provided for @dashboard_issues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get dashboard_issues;

  /// No description provided for @services_title.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services_title;

  /// No description provided for @services_monitored_services.
  ///
  /// In en, this message translates to:
  /// **'Monitored Services'**
  String get services_monitored_services;

  /// No description provided for @services_monitored_services_desc.
  ///
  /// In en, this message translates to:
  /// **'APIs and endpoints being monitored'**
  String get services_monitored_services_desc;

  /// No description provided for @services_add_service.
  ///
  /// In en, this message translates to:
  /// **'Add\nService'**
  String get services_add_service;

  /// No description provided for @services_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load services'**
  String get services_failed_to_load;

  /// No description provided for @services_no_services_yet.
  ///
  /// In en, this message translates to:
  /// **'No Services Yet'**
  String get services_no_services_yet;

  /// No description provided for @services_no_services_message.
  ///
  /// In en, this message translates to:
  /// **'Add your first service to start monitoring'**
  String get services_no_services_message;

  /// No description provided for @services_no_services_recommended_service.
  ///
  /// In en, this message translates to:
  /// **'Add recommended service set'**
  String get services_no_services_recommended_service;

  /// No description provided for @services_service_name.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get services_service_name;

  /// No description provided for @services_service_name_required.
  ///
  /// In en, this message translates to:
  /// **'Service Name *'**
  String get services_service_name_required;

  /// No description provided for @services_service_name_hint.
  ///
  /// In en, this message translates to:
  /// **'My API Service'**
  String get services_service_name_hint;

  /// No description provided for @services_description_optional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get services_description_optional;

  /// No description provided for @services_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter service description'**
  String get services_description_hint;

  /// No description provided for @services_endpoint_url.
  ///
  /// In en, this message translates to:
  /// **'Endpoint URL'**
  String get services_endpoint_url;

  /// No description provided for @services_endpoint_url_required.
  ///
  /// In en, this message translates to:
  /// **'Endpoint URL *'**
  String get services_endpoint_url_required;

  /// No description provided for @services_endpoint_url_hint.
  ///
  /// In en, this message translates to:
  /// **'https://api.example.com/health'**
  String get services_endpoint_url_hint;

  /// No description provided for @services_http_method.
  ///
  /// In en, this message translates to:
  /// **'HTTP Method'**
  String get services_http_method;

  /// No description provided for @services_http_method_required.
  ///
  /// In en, this message translates to:
  /// **'HTTP Method *'**
  String get services_http_method_required;

  /// No description provided for @services_service_type.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get services_service_type;

  /// No description provided for @services_service_type_required.
  ///
  /// In en, this message translates to:
  /// **'Service Type *'**
  String get services_service_type_required;

  /// No description provided for @services_timeout_seconds.
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get services_timeout_seconds;

  /// No description provided for @services_timeout_seconds_required.
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds) *'**
  String get services_timeout_seconds_required;

  /// No description provided for @services_timeout_hint.
  ///
  /// In en, this message translates to:
  /// **'10'**
  String get services_timeout_hint;

  /// No description provided for @services_check_interval_seconds.
  ///
  /// In en, this message translates to:
  /// **'Check Interval (seconds)'**
  String get services_check_interval_seconds;

  /// No description provided for @services_check_interval_seconds_required.
  ///
  /// In en, this message translates to:
  /// **'Check Interval (seconds) *'**
  String get services_check_interval_seconds_required;

  /// No description provided for @services_check_interval_hint.
  ///
  /// In en, this message translates to:
  /// **'60'**
  String get services_check_interval_hint;

  /// No description provided for @services_failure_threshold.
  ///
  /// In en, this message translates to:
  /// **'Failure Threshold'**
  String get services_failure_threshold;

  /// No description provided for @services_failure_threshold_required.
  ///
  /// In en, this message translates to:
  /// **'Failure Threshold *'**
  String get services_failure_threshold_required;

  /// No description provided for @services_failure_threshold_desc.
  ///
  /// In en, this message translates to:
  /// **'Consecutive failures before incident'**
  String get services_failure_threshold_desc;

  /// No description provided for @services_failure_threshold_hint.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get services_failure_threshold_hint;

  /// No description provided for @services_advanced_settings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get services_advanced_settings;

  /// No description provided for @services_service_details.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get services_service_details;

  /// No description provided for @services_manual_check_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Manual check feature coming soon'**
  String get services_manual_check_coming_soon;

  /// No description provided for @services_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Edit feature coming soon'**
  String get services_edit_coming_soon;

  /// No description provided for @services_deactivate_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Deactivate feature coming soon'**
  String get services_deactivate_coming_soon;

  /// No description provided for @services_deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get services_deactivate;

  /// No description provided for @services_delete_service.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get services_delete_service;

  /// No description provided for @services_delete_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service? This will remove all monitoring data. This action cannot be undone.'**
  String get services_delete_confirmation_message;

  /// No description provided for @services_service_deleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get services_service_deleted;

  /// No description provided for @services_failed_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete service: {error}'**
  String services_failed_to_delete(String error);

  /// No description provided for @services_check_interval.
  ///
  /// In en, this message translates to:
  /// **'Check interval: {seconds}s'**
  String services_check_interval(int seconds);

  /// No description provided for @services_failure_threshold_value.
  ///
  /// In en, this message translates to:
  /// **'Failure threshold: {count}'**
  String services_failure_threshold_value(int count);

  /// No description provided for @services_last_checked.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {time}'**
  String services_last_checked(String time);

  /// No description provided for @services_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get services_just_now;

  /// No description provided for @services_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String services_minutes_ago(int minutes);

  /// No description provided for @services_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String services_hours_ago(int hours);

  /// No description provided for @services_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String services_days_ago(int days);

  /// No description provided for @services_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get services_active;

  /// No description provided for @services_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get services_inactive;

  /// No description provided for @services_error_loading_service.
  ///
  /// In en, this message translates to:
  /// **'Error loading service'**
  String get services_error_loading_service;

  /// No description provided for @services_endpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get services_endpoint;

  /// No description provided for @services_method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get services_method;

  /// No description provided for @services_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get services_type;

  /// No description provided for @services_check_interval_label.
  ///
  /// In en, this message translates to:
  /// **'Check Interval'**
  String get services_check_interval_label;

  /// No description provided for @services_timeout_label.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get services_timeout_label;

  /// No description provided for @services_failure_threshold_label.
  ///
  /// In en, this message translates to:
  /// **'Failure Threshold'**
  String get services_failure_threshold_label;

  /// No description provided for @services_last_checked_label.
  ///
  /// In en, this message translates to:
  /// **'Last Checked'**
  String get services_last_checked_label;

  /// No description provided for @services_statistics_last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Statistics (Last 7 Days)'**
  String get services_statistics_last_7_days;

  /// No description provided for @services_unable_to_load_statistics.
  ///
  /// In en, this message translates to:
  /// **'Unable to load statistics'**
  String get services_unable_to_load_statistics;

  /// No description provided for @services_uptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get services_uptime;

  /// No description provided for @services_total_checks.
  ///
  /// In en, this message translates to:
  /// **'Total Checks'**
  String get services_total_checks;

  /// No description provided for @services_successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get services_successful;

  /// No description provided for @services_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get services_failed;

  /// No description provided for @services_avg_latency.
  ///
  /// In en, this message translates to:
  /// **'Avg Latency'**
  String get services_avg_latency;

  /// No description provided for @services_health_check_history.
  ///
  /// In en, this message translates to:
  /// **'Health Check History'**
  String get services_health_check_history;

  /// No description provided for @services_health_check_history_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Health check history will be displayed here'**
  String get services_health_check_history_placeholder;

  /// No description provided for @services_related_incidents.
  ///
  /// In en, this message translates to:
  /// **'Related Incidents'**
  String get services_related_incidents;

  /// No description provided for @services_related_incidents_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Related incidents will be displayed here'**
  String get services_related_incidents_placeholder;

  /// No description provided for @incidents_title.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get incidents_title;

  /// No description provided for @incidents_desc.
  ///
  /// In en, this message translates to:
  /// **'Service failure events and alerts'**
  String get incidents_desc;

  /// No description provided for @incidents_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load incidents'**
  String get incidents_failed_to_load;

  /// No description provided for @incidents_no_incidents.
  ///
  /// In en, this message translates to:
  /// **'No Incidents'**
  String get incidents_no_incidents;

  /// No description provided for @incidents_all_services_running.
  ///
  /// In en, this message translates to:
  /// **'All services are running smoothly'**
  String get incidents_all_services_running;

  /// No description provided for @incidents_open_incidents.
  ///
  /// In en, this message translates to:
  /// **'Open Incidents'**
  String get incidents_open_incidents;

  /// No description provided for @incidents_resolved_incidents.
  ///
  /// In en, this message translates to:
  /// **'Resolved Incidents'**
  String get incidents_resolved_incidents;

  /// No description provided for @incidents_detected.
  ///
  /// In en, this message translates to:
  /// **'Detected: {time}'**
  String incidents_detected(String time);

  /// No description provided for @incidents_failures_count.
  ///
  /// In en, this message translates to:
  /// **'{count} failures'**
  String incidents_failures_count(int count);

  /// No description provided for @incidents_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get incidents_timeline;

  /// No description provided for @incidents_timeline_detected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get incidents_timeline_detected;

  /// No description provided for @incidents_timeline_acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get incidents_timeline_acknowledged;

  /// No description provided for @incidents_timeline_resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get incidents_timeline_resolved;

  /// No description provided for @incidents_ai_analysis_available.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Available'**
  String get incidents_ai_analysis_available;

  /// No description provided for @incidents_ai_analysis_in_progress.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis In Progress'**
  String get incidents_ai_analysis_in_progress;

  /// No description provided for @incidents_root_cause_analysis_completed.
  ///
  /// In en, this message translates to:
  /// **'Root cause analysis completed'**
  String get incidents_root_cause_analysis_completed;

  /// No description provided for @incidents_root_cause_analysis_generating.
  ///
  /// In en, this message translates to:
  /// **'Root cause analysis is being generated'**
  String get incidents_root_cause_analysis_generating;

  /// No description provided for @incidents_incident_details.
  ///
  /// In en, this message translates to:
  /// **'Incident Details'**
  String get incidents_incident_details;

  /// No description provided for @incidents_request_ai_analysis.
  ///
  /// In en, this message translates to:
  /// **'Request AI Analysis'**
  String get incidents_request_ai_analysis;

  /// No description provided for @incidents_acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get incidents_acknowledge;

  /// No description provided for @incidents_resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get incidents_resolve;

  /// No description provided for @incidents_acknowledged_success.
  ///
  /// In en, this message translates to:
  /// **'Incident acknowledged successfully'**
  String get incidents_acknowledged_success;

  /// No description provided for @incidents_failed_to_acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Failed to acknowledge: {error}'**
  String incidents_failed_to_acknowledge(String error);

  /// No description provided for @incidents_resolve_incident.
  ///
  /// In en, this message translates to:
  /// **'Resolve Incident'**
  String get incidents_resolve_incident;

  /// No description provided for @incidents_resolve_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this incident as resolved?'**
  String get incidents_resolve_confirmation;

  /// No description provided for @incidents_resolved_success.
  ///
  /// In en, this message translates to:
  /// **'Incident resolved successfully'**
  String get incidents_resolved_success;

  /// No description provided for @incidents_failed_to_resolve.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve: {error}'**
  String incidents_failed_to_resolve(String error);

  /// No description provided for @incidents_request_analysis.
  ///
  /// In en, this message translates to:
  /// **'Request Analysis'**
  String get incidents_request_analysis;

  /// No description provided for @incidents_request_analysis_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Request AI Analysis'**
  String get incidents_request_analysis_dialog_title;

  /// No description provided for @incidents_request_analysis_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'Request AI to analyze this incident and provide root cause analysis, debug steps, and suggested actions?\n\nAnalysis may take a few moments to complete.'**
  String get incidents_request_analysis_dialog_message;

  /// No description provided for @incidents_ai_analysis_requested.
  ///
  /// In en, this message translates to:
  /// **'AI analysis requested. It will be available shortly.'**
  String get incidents_ai_analysis_requested;

  /// No description provided for @incidents_failed_to_request_analysis.
  ///
  /// In en, this message translates to:
  /// **'Failed to request analysis: {error}'**
  String incidents_failed_to_request_analysis(String error);

  /// No description provided for @incidents_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get incidents_statistics;

  /// No description provided for @incidents_consecutive_failures.
  ///
  /// In en, this message translates to:
  /// **'Consecutive Failures'**
  String get incidents_consecutive_failures;

  /// No description provided for @incidents_total_affected_checks.
  ///
  /// In en, this message translates to:
  /// **'Total Affected Checks'**
  String get incidents_total_affected_checks;

  /// No description provided for @incidents_incident_not_found.
  ///
  /// In en, this message translates to:
  /// **'Incident not found'**
  String get incidents_incident_not_found;

  /// No description provided for @incidents_ai_analysis_view_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis view coming soon'**
  String get incidents_ai_analysis_view_coming_soon;

  /// No description provided for @incidents_view_analysis.
  ///
  /// In en, this message translates to:
  /// **'View Analysis'**
  String get incidents_view_analysis;

  /// No description provided for @incidents_ai_analysis_request_sent.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis request sent'**
  String get incidents_ai_analysis_request_sent;

  /// No description provided for @incidents_ai_root_cause.
  ///
  /// In en, this message translates to:
  /// **'AI Root Cause Analysis'**
  String get incidents_ai_root_cause;

  /// No description provided for @incidents_generated_by.
  ///
  /// In en, this message translates to:
  /// **'Generated by {model}'**
  String incidents_generated_by(String model);

  /// No description provided for @incidents_root_cause_hypothesis.
  ///
  /// In en, this message translates to:
  /// **'Root Cause Hypothesis'**
  String get incidents_root_cause_hypothesis;

  /// No description provided for @incidents_debug_checklist.
  ///
  /// In en, this message translates to:
  /// **'Debug Checklist'**
  String get incidents_debug_checklist;

  /// No description provided for @incidents_suggested_actions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Actions'**
  String get incidents_suggested_actions;

  /// No description provided for @incidents_no_analysis_available.
  ///
  /// In en, this message translates to:
  /// **'No AI Analysis Available'**
  String get incidents_no_analysis_available;

  /// No description provided for @incidents_analysis_not_available.
  ///
  /// In en, this message translates to:
  /// **'Analysis Not Available'**
  String get incidents_analysis_not_available;

  /// No description provided for @incidents_error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error loading incident'**
  String get incidents_error_loading;

  /// No description provided for @incidents_service_id.
  ///
  /// In en, this message translates to:
  /// **'Service ID'**
  String get incidents_service_id;

  /// No description provided for @incidents_detected_at.
  ///
  /// In en, this message translates to:
  /// **'Detected At'**
  String get incidents_detected_at;

  /// No description provided for @incidents_acknowledged_at.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged At'**
  String get incidents_acknowledged_at;

  /// No description provided for @incidents_resolved_at.
  ///
  /// In en, this message translates to:
  /// **'Resolved At'**
  String get incidents_resolved_at;

  /// No description provided for @incidents_ai_analysis_complete.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Complete'**
  String get incidents_ai_analysis_complete;

  /// No description provided for @incidents_ai_analysis_pending.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Pending'**
  String get incidents_ai_analysis_pending;

  /// No description provided for @incidents_ai_root_cause_available.
  ///
  /// In en, this message translates to:
  /// **'AI Root Cause Analysis Available'**
  String get incidents_ai_root_cause_available;

  /// No description provided for @incidents_view_ai_insights.
  ///
  /// In en, this message translates to:
  /// **'View AI-generated insights, root cause hypothesis, and suggested actions'**
  String get incidents_view_ai_insights;

  /// No description provided for @incidents_related_health_checks.
  ///
  /// In en, this message translates to:
  /// **'Related Health Checks'**
  String get incidents_related_health_checks;

  /// No description provided for @incidents_related_health_checks_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Related health checks will be displayed here'**
  String get incidents_related_health_checks_placeholder;

  /// No description provided for @incidents_related_error_patterns.
  ///
  /// In en, this message translates to:
  /// **'Related Error Patterns'**
  String get incidents_related_error_patterns;

  /// No description provided for @incidents_no_analysis_message.
  ///
  /// In en, this message translates to:
  /// **'AI analysis has not been generated for this incident yet.\nRequest an analysis from the incident detail view.'**
  String get incidents_no_analysis_message;

  /// No description provided for @incidents_confidence_score.
  ///
  /// In en, this message translates to:
  /// **'Confidence Score'**
  String get incidents_confidence_score;

  /// No description provided for @incidents_confidence_high.
  ///
  /// In en, this message translates to:
  /// **'High confidence in the analysis'**
  String get incidents_confidence_high;

  /// No description provided for @incidents_confidence_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate confidence - manual verification recommended'**
  String get incidents_confidence_moderate;

  /// No description provided for @incidents_confidence_low.
  ///
  /// In en, this message translates to:
  /// **'Low confidence - requires further investigation'**
  String get incidents_confidence_low;

  /// No description provided for @incidents_analysis_metadata.
  ///
  /// In en, this message translates to:
  /// **'Analysis Metadata'**
  String get incidents_analysis_metadata;

  /// No description provided for @incidents_metadata_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get incidents_metadata_model;

  /// No description provided for @incidents_metadata_tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get incidents_metadata_tokens;

  /// No description provided for @incidents_metadata_tokens_detail.
  ///
  /// In en, this message translates to:
  /// **'{total} (prompt: {prompt}, completion: {completion})'**
  String incidents_metadata_tokens_detail(
      int total, int prompt, int completion);

  /// No description provided for @incidents_metadata_cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get incidents_metadata_cost;

  /// No description provided for @incidents_metadata_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get incidents_metadata_duration;

  /// No description provided for @incidents_metadata_duration_value.
  ///
  /// In en, this message translates to:
  /// **'{milliseconds}ms'**
  String incidents_metadata_duration_value(int milliseconds);

  /// No description provided for @incidents_metadata_analyzed_at.
  ///
  /// In en, this message translates to:
  /// **'Analyzed At'**
  String get incidents_metadata_analyzed_at;

  /// No description provided for @incidents_failed_to_load_analysis.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Analysis'**
  String get incidents_failed_to_load_analysis;

  /// No description provided for @projects_title.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects_title;

  /// No description provided for @projects_your_projects.
  ///
  /// In en, this message translates to:
  /// **'Your Projects'**
  String get projects_your_projects;

  /// No description provided for @projects_new_project.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get projects_new_project;

  /// No description provided for @projects_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load projects'**
  String get projects_failed_to_load;

  /// No description provided for @projects_error_selecting.
  ///
  /// In en, this message translates to:
  /// **'Error selecting project: {error}'**
  String projects_error_selecting(String error);

  /// No description provided for @projects_guest_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Guest Limit Reached'**
  String get projects_guest_limit_reached;

  /// No description provided for @projects_guest_limit_message.
  ///
  /// In en, this message translates to:
  /// **'Guest users are limited to 1 project. Sign in with Google to create unlimited projects and access advanced features.'**
  String get projects_guest_limit_message;

  /// No description provided for @projects_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get projects_sign_in;

  /// No description provided for @projects_create_new_project.
  ///
  /// In en, this message translates to:
  /// **'Create New Project'**
  String get projects_create_new_project;

  /// No description provided for @projects_project_name.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projects_project_name;

  /// No description provided for @projects_project_name_required.
  ///
  /// In en, this message translates to:
  /// **'Project Name *'**
  String get projects_project_name_required;

  /// No description provided for @projects_project_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get projects_project_name_hint;

  /// No description provided for @projects_description_optional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get projects_description_optional;

  /// No description provided for @projects_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter project description'**
  String get projects_description_hint;

  /// No description provided for @projects_project_details.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projects_project_details;

  /// No description provided for @projects_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Edit feature coming soon'**
  String get projects_edit_coming_soon;

  /// No description provided for @projects_delete_project.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get projects_delete_project;

  /// No description provided for @projects_delete_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this project? This action cannot be undone.'**
  String get projects_delete_confirmation;

  /// No description provided for @projects_project_deleted.
  ///
  /// In en, this message translates to:
  /// **'Project deleted successfully'**
  String get projects_project_deleted;

  /// No description provided for @projects_failed_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete project: {error}'**
  String projects_failed_to_delete(String error);

  /// No description provided for @projects_no_projects_yet.
  ///
  /// In en, this message translates to:
  /// **'No Projects Yet'**
  String get projects_no_projects_yet;

  /// No description provided for @projects_create_first_project.
  ///
  /// In en, this message translates to:
  /// **'Create your first project to start monitoring your services'**
  String get projects_create_first_project;

  /// No description provided for @projects_failed_to_load_api_keys.
  ///
  /// In en, this message translates to:
  /// **'Failed to load API keys: {error}'**
  String projects_failed_to_load_api_keys(String error);

  /// No description provided for @projects_no_api_key_warning.
  ///
  /// In en, this message translates to:
  /// **'No API key configured for this project. Please create one in settings.'**
  String get projects_no_api_key_warning;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notificaion'**
  String get settings_notifications;

  /// No description provided for @settings_notification_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Request notification permission'**
  String get settings_notification_subtitle;

  /// No description provided for @settings_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_light;

  /// No description provided for @settings_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_dark;

  /// No description provided for @settings_blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get settings_blue;

  /// No description provided for @settings_select_theme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get settings_select_theme;

  /// No description provided for @settings_select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settings_select_language;

  /// No description provided for @settings_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_english;

  /// No description provided for @settings_korean.
  ///
  /// In en, this message translates to:
  /// **'한국어 (Korean)'**
  String get settings_korean;

  /// No description provided for @settings_change_project.
  ///
  /// In en, this message translates to:
  /// **'Change Project'**
  String get settings_change_project;

  /// No description provided for @settings_change_project_desc.
  ///
  /// In en, this message translates to:
  /// **'Select a different project'**
  String get settings_change_project_desc;

  /// No description provided for @settings_no_project_selected.
  ///
  /// In en, this message translates to:
  /// **'No Project Selected'**
  String get settings_no_project_selected;

  /// No description provided for @settings_no_project_desc.
  ///
  /// In en, this message translates to:
  /// **'Select a project to get started'**
  String get settings_no_project_desc;

  /// No description provided for @settings_select_project.
  ///
  /// In en, this message translates to:
  /// **'Select Project'**
  String get settings_select_project;

  /// No description provided for @settings_signed_in_as.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get settings_signed_in_as;

  /// No description provided for @settings_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settings_sign_out;

  /// No description provided for @settings_sign_out_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settings_sign_out_confirmation;

  /// No description provided for @settings_signed_out.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get settings_signed_out;

  /// No description provided for @settings_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_delete_account;

  /// No description provided for @settings_delete_account_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account and included informations?'**
  String get settings_delete_account_confirmation;

  /// No description provided for @settings_deleted_account.
  ///
  /// In en, this message translates to:
  /// **'your account deleted successfully'**
  String get settings_deleted_account;

  /// No description provided for @settings_api_key.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settings_api_key;

  /// No description provided for @settings_authenticated.
  ///
  /// In en, this message translates to:
  /// **'Authenticated'**
  String get settings_authenticated;

  /// No description provided for @settings_api_key_desc.
  ///
  /// In en, this message translates to:
  /// **'API key for project: {project}'**
  String settings_api_key_desc(String project);

  /// No description provided for @settings_active_key.
  ///
  /// In en, this message translates to:
  /// **'Active key: {keyName}'**
  String settings_active_key(String keyName);

  /// No description provided for @settings_no_project_api_key.
  ///
  /// In en, this message translates to:
  /// **'No project selected. Select a project to view API key.'**
  String get settings_no_project_api_key;

  /// No description provided for @settings_no_api_key.
  ///
  /// In en, this message translates to:
  /// **'No API Key'**
  String get settings_no_api_key;

  /// No description provided for @settings_security_warning.
  ///
  /// In en, this message translates to:
  /// **'Keep your API key secure. Do not share it publicly.'**
  String get settings_security_warning;

  /// No description provided for @settings_switch_key.
  ///
  /// In en, this message translates to:
  /// **'Switch Key'**
  String get settings_switch_key;

  /// No description provided for @settings_switch_key_response.
  ///
  /// In en, this message translates to:
  /// **'Switch Key is preparation'**
  String get settings_switch_key_response;

  /// No description provided for @settings_create_key.
  ///
  /// In en, this message translates to:
  /// **'Create Key'**
  String get settings_create_key;

  /// No description provided for @settings_create_key_response.
  ///
  /// In en, this message translates to:
  /// **'Create Key is preparation'**
  String get settings_create_key_response;

  /// No description provided for @settings_api_key_copied.
  ///
  /// In en, this message translates to:
  /// **'API key copied to clipboard'**
  String get settings_api_key_copied;

  /// No description provided for @settings_copy_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get settings_copy_to_clipboard;

  /// No description provided for @analysis_title.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Overview'**
  String get analysis_title;

  /// No description provided for @analysis_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Analysis'**
  String get analysis_refresh;

  /// No description provided for @analysis_refresh_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Refresh feature coming soon'**
  String get analysis_refresh_coming_soon;

  /// No description provided for @analysis_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get analysis_filter;

  /// No description provided for @analysis_filter_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Filter feature coming soon'**
  String get analysis_filter_coming_soon;

  /// No description provided for @analysis_bulk_request_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Bulk analysis request coming soon'**
  String get analysis_bulk_request_coming_soon;

  /// No description provided for @analysis_request_analysis.
  ///
  /// In en, this message translates to:
  /// **'Request Analysis'**
  String get analysis_request_analysis;

  /// No description provided for @analysis_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading AI Analysis...'**
  String get analysis_loading;

  /// No description provided for @analysis_summary.
  ///
  /// In en, this message translates to:
  /// **'Analysis Summary'**
  String get analysis_summary;

  /// No description provided for @analysis_total_analyses.
  ///
  /// In en, this message translates to:
  /// **'Total Analyses'**
  String get analysis_total_analyses;

  /// No description provided for @analysis_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get analysis_pending;

  /// No description provided for @analysis_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get analysis_completed;

  /// No description provided for @analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get analysis_failed;

  /// No description provided for @analysis_recent_analyses.
  ///
  /// In en, this message translates to:
  /// **'Recent AI Analyses'**
  String get analysis_recent_analyses;

  /// No description provided for @analysis_no_analyses.
  ///
  /// In en, this message translates to:
  /// **'No AI analyses yet'**
  String get analysis_no_analyses;

  /// No description provided for @analysis_no_analyses_message.
  ///
  /// In en, this message translates to:
  /// **'Request AI analysis on incidents to get started'**
  String get analysis_no_analyses_message;

  /// No description provided for @analysis_insights_recommendations.
  ///
  /// In en, this message translates to:
  /// **'Insights & Recommendations'**
  String get analysis_insights_recommendations;

  /// No description provided for @analysis_ai_powered_insights.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Insights'**
  String get analysis_ai_powered_insights;

  /// No description provided for @analysis_insights_message.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze your incident patterns and provide recommendations:'**
  String get analysis_insights_message;

  /// No description provided for @analysis_insight_root_cause.
  ///
  /// In en, this message translates to:
  /// **'Root cause identification'**
  String get analysis_insight_root_cause;

  /// No description provided for @analysis_insight_pattern_detection.
  ///
  /// In en, this message translates to:
  /// **'Pattern detection across incidents'**
  String get analysis_insight_pattern_detection;

  /// No description provided for @analysis_insight_remediation.
  ///
  /// In en, this message translates to:
  /// **'Suggested remediation steps'**
  String get analysis_insight_remediation;

  /// No description provided for @analysis_insight_prevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention recommendations'**
  String get analysis_insight_prevention;

  /// No description provided for @analysis_auth_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get analysis_auth_required;

  /// No description provided for @analysis_auth_required_message.
  ///
  /// In en, this message translates to:
  /// **'AI analysis is only available for authenticated users with server access.'**
  String get analysis_auth_required_message;

  /// No description provided for @service_type_http_api.
  ///
  /// In en, this message translates to:
  /// **'HTTP API'**
  String get service_type_http_api;

  /// No description provided for @service_type_https_api.
  ///
  /// In en, this message translates to:
  /// **'HTTPS API'**
  String get service_type_https_api;

  /// No description provided for @service_type_gcp_endpoint.
  ///
  /// In en, this message translates to:
  /// **'GCP Endpoint'**
  String get service_type_gcp_endpoint;

  /// No description provided for @service_type_firebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase'**
  String get service_type_firebase;

  /// No description provided for @service_type_websocket.
  ///
  /// In en, this message translates to:
  /// **'WebSocket'**
  String get service_type_websocket;

  /// No description provided for @service_type_grpc.
  ///
  /// In en, this message translates to:
  /// **'gRPC'**
  String get service_type_grpc;

  /// No description provided for @http_method_get.
  ///
  /// In en, this message translates to:
  /// **'GET'**
  String get http_method_get;

  /// No description provided for @http_method_post.
  ///
  /// In en, this message translates to:
  /// **'POST'**
  String get http_method_post;

  /// No description provided for @http_method_put.
  ///
  /// In en, this message translates to:
  /// **'PUT'**
  String get http_method_put;

  /// No description provided for @http_method_delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get http_method_delete;

  /// No description provided for @http_method_patch.
  ///
  /// In en, this message translates to:
  /// **'PATCH'**
  String get http_method_patch;

  /// No description provided for @http_method_head.
  ///
  /// In en, this message translates to:
  /// **'HEAD'**
  String get http_method_head;

  /// No description provided for @incident_status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get incident_status_open;

  /// No description provided for @incident_status_investigating.
  ///
  /// In en, this message translates to:
  /// **'Investigating'**
  String get incident_status_investigating;

  /// No description provided for @incident_status_resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get incident_status_resolved;

  /// No description provided for @incident_status_acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get incident_status_acknowledged;

  /// No description provided for @incident_severity_critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get incident_severity_critical;

  /// No description provided for @incident_severity_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get incident_severity_high;

  /// No description provided for @incident_severity_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get incident_severity_medium;

  /// No description provided for @incident_severity_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get incident_severity_low;

  /// No description provided for @service_state_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get service_state_healthy;

  /// No description provided for @service_state_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get service_state_error;

  /// No description provided for @service_state_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get service_state_inactive;

  /// No description provided for @project_health_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get project_health_healthy;

  /// No description provided for @project_health_degraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get project_health_degraded;

  /// No description provided for @project_health_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get project_health_unknown;

  /// No description provided for @error_general.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get error_general;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get error_network;

  /// No description provided for @error_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized. Please login again.'**
  String get error_unauthorized;

  /// No description provided for @error_not_found.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get error_not_found;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get error_server;

  /// No description provided for @error_validation.
  ///
  /// In en, this message translates to:
  /// **'Validation error. Please check your input.'**
  String get error_validation;

  /// No description provided for @error_storage.
  ///
  /// In en, this message translates to:
  /// **'Storage error. Please try again.'**
  String get error_storage;

  /// No description provided for @error_undefined.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred.'**
  String get error_undefined;

  /// No description provided for @error_analysis.
  ///
  /// In en, this message translates to:
  /// **'AI analysis error. Please try again.'**
  String get error_analysis;

  /// No description provided for @error_guest_limit.
  ///
  /// In en, this message translates to:
  /// **'guest only can create 1 project'**
  String get error_guest_limit;

  /// No description provided for @error_service_name_required.
  ///
  /// In en, this message translates to:
  /// **'Service name is required'**
  String get error_service_name_required;

  /// No description provided for @error_failed_to_create_service.
  ///
  /// In en, this message translates to:
  /// **'Failed to create service'**
  String get error_failed_to_create_service;

  /// No description provided for @error_auth_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Authentication state unavailable'**
  String get error_auth_unavailable;

  /// No description provided for @error_failed_to_create_project.
  ///
  /// In en, this message translates to:
  /// **'Failed to create project'**
  String get error_failed_to_create_project;

  /// No description provided for @error_failed_to_bootstrap_guest.
  ///
  /// In en, this message translates to:
  /// **'Failed to bootstrap guest user'**
  String get error_failed_to_bootstrap_guest;

  /// No description provided for @error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get error_timeout;

  /// No description provided for @error_connection_failed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please check your network.'**
  String get error_connection_failed;

  /// No description provided for @error_invalid_response.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response.'**
  String get error_invalid_response;

  /// No description provided for @error_firebase_auth.
  ///
  /// In en, this message translates to:
  /// **'Authentication error occurred.'**
  String get error_firebase_auth;

  /// No description provided for @error_firebase_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get error_firebase_user_not_found;

  /// No description provided for @error_firebase_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get error_firebase_wrong_password;

  /// No description provided for @error_firebase_email_in_use.
  ///
  /// In en, this message translates to:
  /// **'Email address is already in use.'**
  String get error_firebase_email_in_use;

  /// No description provided for @error_firebase_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get error_firebase_weak_password;

  /// No description provided for @error_firebase_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get error_firebase_invalid_email;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// No description provided for @validation_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validation_email_invalid;

  /// No description provided for @validation_password_min_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {length} characters'**
  String validation_password_min_length(int length);

  /// No description provided for @validation_url_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get validation_url_invalid;

  /// No description provided for @validation_number_min.
  ///
  /// In en, this message translates to:
  /// **'Value must be at least {min}'**
  String validation_number_min(int min);

  /// No description provided for @validation_number_max.
  ///
  /// In en, this message translates to:
  /// **'Value must be at most {max}'**
  String validation_number_max(int max);

  /// No description provided for @validation_field_required.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validation_field_required(String field);

  /// No description provided for @validation_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get validation_invalid_number;

  /// No description provided for @validation_url_protocol.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get validation_url_protocol;

  /// No description provided for @validation_number_between.
  ///
  /// In en, this message translates to:
  /// **'Value must be between {min} and {max}'**
  String validation_number_between(int min, int max);

  /// No description provided for @validation_max_length.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed {max} characters'**
  String validation_max_length(int max);

  /// No description provided for @validation_project_name_required.
  ///
  /// In en, this message translates to:
  /// **'Project name is required'**
  String get validation_project_name_required;

  /// No description provided for @validation_project_name_max_length.
  ///
  /// In en, this message translates to:
  /// **'Project name cannot exceed 100 characters'**
  String get validation_project_name_max_length;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_save => 'Save';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_done => 'Done';

  @override
  String get common_or => 'OR';

  @override
  String get common_close => 'Close';

  @override
  String get common_create => 'Create';

  @override
  String get common_creating => 'Creating...';

  @override
  String get app_title => 'Service Sentinel';

  @override
  String get app_subtitle => 'AI-Powered API Monitoring';

  @override
  String get navigation_dashboard => 'Dashboard';

  @override
  String get navigation_services => 'Services';

  @override
  String get navigation_incidents => 'Incidents';

  @override
  String get navigation_settings => 'Settings';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_logout => 'Logout';

  @override
  String get auth_signup => 'Sign Up';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_forgot_password => 'Forgot Password?';

  @override
  String get auth_guest_mode => 'Continue as Guest';

  @override
  String get auth_guest_mode_desc =>
      'Use the app without signing in. Your data stays on this device.';

  @override
  String get auth_enter_as_guest => 'Enter as Guest';

  @override
  String get auth_sign_in_email => 'Sign in with Email';

  @override
  String get auth_sign_in_google => 'Sign in with Google Email';

  @override
  String get auth_sign_in_desc =>
      'Access your projects from any device with cloud sync.';

  @override
  String get auth_dont_have_account => 'Don\'t have an account? Sign up';

  @override
  String get auth_signing_in => 'Signing in...';

  @override
  String get auth_login_failed => 'Login failed. Please try again.';

  @override
  String get auth_creating_account => 'Creating account...';

  @override
  String get auth_sign_up => 'Sign Up';

  @override
  String get auth_sign_up_email => 'Sign Up with Email';

  @override
  String get auth_sign_up_desc => 'Sign up to create a new account';

  @override
  String get auth_signup_failed => 'Sign up failed. Please try again.';

  @override
  String get auth_sign_up_cancel => 'Cancel';

  @override
  String get auth_migration_dialog_title => 'Migrate Local Projects?';

  @override
  String get auth_migration_dialog_message =>
      'You have local projects stored on this device. Would you like to migrate them to the cloud?';

  @override
  String get auth_migration_cloud_sync => 'Cloud Sync';

  @override
  String get auth_migration_cloud_sync_desc =>
      'Access your projects from any device';

  @override
  String get auth_migration_backup => 'Backup';

  @override
  String get auth_migration_backup_desc => 'Your data is safely backed up';

  @override
  String get auth_migration_team => 'Team Collaboration';

  @override
  String get auth_migration_team_desc => 'Share projects with team members';

  @override
  String get auth_skip_for_now => 'Skip for Now';

  @override
  String get auth_migrate_now => 'Migrate Now';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get dashboard_welcome_back => 'Welcome back!';

  @override
  String get dashboard_guest_mode => 'Guest Mode';

  @override
  String dashboard_current_project(String projectName) {
    return 'Current Project: $projectName';
  }

  @override
  String get dashboard_no_project_selected =>
      'No project selected. Please select a project to start monitoring.';

  @override
  String get dashboard_quick_stats => 'Quick Stats';

  @override
  String get dashboard_services => 'Services';

  @override
  String get dashboard_incidents => 'Incidents';

  @override
  String get dashboard_healthy => 'Healthy';

  @override
  String get dashboard_issues => 'Issues';

  @override
  String get services_title => 'Services';

  @override
  String get services_monitored_services => 'Monitored Services';

  @override
  String get services_monitored_services_desc =>
      'APIs and endpoints being monitored';

  @override
  String get services_add_service => 'Add\nService';

  @override
  String get services_failed_to_load => 'Failed to load services';

  @override
  String get services_no_services_yet => 'No Services Yet';

  @override
  String get services_no_services_message =>
      'Add your first service to start monitoring';

  @override
  String get services_no_services_recommended_service =>
      'Add recommended service set';

  @override
  String get services_service_name => 'Service Name';

  @override
  String get services_service_name_required => 'Service Name *';

  @override
  String get services_service_name_hint => 'My API Service';

  @override
  String get services_description_optional => 'Description (Optional)';

  @override
  String get services_description_hint => 'Enter service description';

  @override
  String get services_endpoint_url => 'Endpoint URL';

  @override
  String get services_endpoint_url_required => 'Endpoint URL *';

  @override
  String get services_endpoint_url_hint => 'https://api.example.com/health';

  @override
  String get services_http_method => 'HTTP Method';

  @override
  String get services_http_method_required => 'HTTP Method *';

  @override
  String get services_service_type => 'Service Type';

  @override
  String get services_service_type_required => 'Service Type *';

  @override
  String get services_timeout_seconds => 'Timeout (seconds)';

  @override
  String get services_timeout_seconds_required => 'Timeout (seconds) *';

  @override
  String get services_timeout_hint => '10';

  @override
  String get services_check_interval_seconds => 'Check Interval (seconds)';

  @override
  String get services_check_interval_seconds_required =>
      'Check Interval (seconds) *';

  @override
  String get services_check_interval_hint => '60';

  @override
  String get services_failure_threshold => 'Failure Threshold';

  @override
  String get services_failure_threshold_required => 'Failure Threshold *';

  @override
  String get services_failure_threshold_desc =>
      'Consecutive failures before incident';

  @override
  String get services_failure_threshold_hint => '3';

  @override
  String get services_advanced_settings => 'Advanced Settings';

  @override
  String get services_service_details => 'Service Details';

  @override
  String get services_manual_check_coming_soon =>
      'Manual check feature coming soon';

  @override
  String get services_edit_coming_soon => 'Edit feature coming soon';

  @override
  String get services_deactivate_coming_soon =>
      'Deactivate feature coming soon';

  @override
  String get services_deactivate => 'Deactivate';

  @override
  String get services_delete_service => 'Delete Service';

  @override
  String get services_delete_confirmation_message =>
      'Are you sure you want to delete this service? This will remove all monitoring data. This action cannot be undone.';

  @override
  String get services_service_deleted => 'Service deleted successfully';

  @override
  String services_failed_to_delete(String error) {
    return 'Failed to delete service: $error';
  }

  @override
  String services_check_interval(int seconds) {
    return 'Check interval: ${seconds}s';
  }

  @override
  String services_failure_threshold_value(int count) {
    return 'Failure threshold: $count';
  }

  @override
  String services_last_checked(String time) {
    return 'Last checked: $time';
  }

  @override
  String get services_just_now => 'Just now';

  @override
  String services_minutes_ago(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String services_hours_ago(int hours) {
    return '${hours}h ago';
  }

  @override
  String services_days_ago(int days) {
    return '${days}d ago';
  }

  @override
  String get services_active => 'Active';

  @override
  String get services_inactive => 'Inactive';

  @override
  String get services_error_loading_service => 'Error loading service';

  @override
  String get services_endpoint => 'Endpoint';

  @override
  String get services_method => 'Method';

  @override
  String get services_type => 'Type';

  @override
  String get services_check_interval_label => 'Check Interval';

  @override
  String get services_timeout_label => 'Timeout';

  @override
  String get services_failure_threshold_label => 'Failure Threshold';

  @override
  String get services_last_checked_label => 'Last Checked';

  @override
  String get services_statistics_last_7_days => 'Statistics (Last 7 Days)';

  @override
  String get services_unable_to_load_statistics => 'Unable to load statistics';

  @override
  String get services_uptime => 'Uptime';

  @override
  String get services_total_checks => 'Total Checks';

  @override
  String get services_successful => 'Successful';

  @override
  String get services_failed => 'Failed';

  @override
  String get services_avg_latency => 'Avg Latency';

  @override
  String get services_health_check_history => 'Health Check History';

  @override
  String get services_health_check_history_placeholder =>
      'Health check history will be displayed here';

  @override
  String get services_related_incidents => 'Related Incidents';

  @override
  String get services_related_incidents_placeholder =>
      'Related incidents will be displayed here';

  @override
  String get incidents_title => 'Incidents';

  @override
  String get incidents_desc => 'Service failure events and alerts';

  @override
  String get incidents_failed_to_load => 'Failed to load incidents';

  @override
  String get incidents_no_incidents => 'No Incidents';

  @override
  String get incidents_all_services_running =>
      'All services are running smoothly';

  @override
  String get incidents_open_incidents => 'Open Incidents';

  @override
  String get incidents_resolved_incidents => 'Resolved Incidents';

  @override
  String incidents_detected(String time) {
    return 'Detected: $time';
  }

  @override
  String incidents_failures_count(int count) {
    return '$count failures';
  }

  @override
  String get incidents_timeline => 'Timeline';

  @override
  String get incidents_timeline_detected => 'Detected';

  @override
  String get incidents_timeline_acknowledged => 'Acknowledged';

  @override
  String get incidents_timeline_resolved => 'Resolved';

  @override
  String get incidents_ai_analysis_available => 'AI Analysis Available';

  @override
  String get incidents_ai_analysis_in_progress => 'AI Analysis In Progress';

  @override
  String get incidents_root_cause_analysis_completed =>
      'Root cause analysis completed';

  @override
  String get incidents_root_cause_analysis_generating =>
      'Root cause analysis is being generated';

  @override
  String get incidents_incident_details => 'Incident Details';

  @override
  String get incidents_request_ai_analysis => 'Request AI Analysis';

  @override
  String get incidents_acknowledge => 'Acknowledge';

  @override
  String get incidents_resolve => 'Resolve';

  @override
  String get incidents_acknowledged_success =>
      'Incident acknowledged successfully';

  @override
  String incidents_failed_to_acknowledge(String error) {
    return 'Failed to acknowledge: $error';
  }

  @override
  String get incidents_resolve_incident => 'Resolve Incident';

  @override
  String get incidents_resolve_confirmation =>
      'Are you sure you want to mark this incident as resolved?';

  @override
  String get incidents_resolved_success => 'Incident resolved successfully';

  @override
  String incidents_failed_to_resolve(String error) {
    return 'Failed to resolve: $error';
  }

  @override
  String get incidents_request_analysis => 'Request Analysis';

  @override
  String get incidents_request_analysis_dialog_title => 'Request AI Analysis';

  @override
  String get incidents_request_analysis_dialog_message =>
      'Request AI to analyze this incident and provide root cause analysis, debug steps, and suggested actions?\n\nAnalysis may take a few moments to complete.';

  @override
  String get incidents_ai_analysis_requested =>
      'AI analysis requested. It will be available shortly.';

  @override
  String incidents_failed_to_request_analysis(String error) {
    return 'Failed to request analysis: $error';
  }

  @override
  String get incidents_statistics => 'Statistics';

  @override
  String get incidents_consecutive_failures => 'Consecutive Failures';

  @override
  String get incidents_total_affected_checks => 'Total Affected Checks';

  @override
  String get incidents_incident_not_found => 'Incident not found';

  @override
  String get incidents_ai_analysis_view_coming_soon =>
      'AI Analysis view coming soon';

  @override
  String get incidents_view_analysis => 'View Analysis';

  @override
  String get incidents_ai_analysis_request_sent => 'AI Analysis request sent';

  @override
  String get incidents_ai_root_cause => 'AI Root Cause Analysis';

  @override
  String incidents_generated_by(String model) {
    return 'Generated by $model';
  }

  @override
  String get incidents_root_cause_hypothesis => 'Root Cause Hypothesis';

  @override
  String get incidents_debug_checklist => 'Debug Checklist';

  @override
  String get incidents_suggested_actions => 'Suggested Actions';

  @override
  String get incidents_no_analysis_available => 'No AI Analysis Available';

  @override
  String get incidents_analysis_not_available => 'Analysis Not Available';

  @override
  String get incidents_error_loading => 'Error loading incident';

  @override
  String get incidents_service_id => 'Service ID';

  @override
  String get incidents_detected_at => 'Detected At';

  @override
  String get incidents_acknowledged_at => 'Acknowledged At';

  @override
  String get incidents_resolved_at => 'Resolved At';

  @override
  String get incidents_ai_analysis_complete => 'AI Analysis Complete';

  @override
  String get incidents_ai_analysis_pending => 'AI Analysis Pending';

  @override
  String get incidents_ai_root_cause_available =>
      'AI Root Cause Analysis Available';

  @override
  String get incidents_view_ai_insights =>
      'View AI-generated insights, root cause hypothesis, and suggested actions';

  @override
  String get incidents_related_health_checks => 'Related Health Checks';

  @override
  String get incidents_related_health_checks_placeholder =>
      'Related health checks will be displayed here';

  @override
  String get incidents_related_error_patterns => 'Related Error Patterns';

  @override
  String get incidents_no_analysis_message =>
      'AI analysis has not been generated for this incident yet.\nRequest an analysis from the incident detail view.';

  @override
  String get incidents_confidence_score => 'Confidence Score';

  @override
  String get incidents_confidence_high => 'High confidence in the analysis';

  @override
  String get incidents_confidence_moderate =>
      'Moderate confidence - manual verification recommended';

  @override
  String get incidents_confidence_low =>
      'Low confidence - requires further investigation';

  @override
  String get incidents_analysis_metadata => 'Analysis Metadata';

  @override
  String get incidents_metadata_model => 'Model';

  @override
  String get incidents_metadata_tokens => 'Tokens';

  @override
  String incidents_metadata_tokens_detail(
      int total, int prompt, int completion) {
    return '$total (prompt: $prompt, completion: $completion)';
  }

  @override
  String get incidents_metadata_cost => 'Cost';

  @override
  String get incidents_metadata_duration => 'Duration';

  @override
  String incidents_metadata_duration_value(int milliseconds) {
    return '${milliseconds}ms';
  }

  @override
  String get incidents_metadata_analyzed_at => 'Analyzed At';

  @override
  String get incidents_failed_to_load_analysis => 'Failed to Load Analysis';

  @override
  String get projects_title => 'Projects';

  @override
  String get projects_your_projects => 'Your Projects';

  @override
  String get projects_new_project => 'New Project';

  @override
  String get projects_failed_to_load => 'Failed to load projects';

  @override
  String projects_error_selecting(String error) {
    return 'Error selecting project: $error';
  }

  @override
  String get projects_guest_limit_reached => 'Guest Limit Reached';

  @override
  String get projects_guest_limit_message =>
      'Guest users are limited to 1 project. Sign in with Google to create unlimited projects and access advanced features.';

  @override
  String get projects_sign_in => 'Sign In';

  @override
  String get projects_create_new_project => 'Create New Project';

  @override
  String get projects_project_name => 'Project Name';

  @override
  String get projects_project_name_required => 'Project Name *';

  @override
  String get projects_project_name_hint => 'Enter project name';

  @override
  String get projects_description_optional => 'Description (Optional)';

  @override
  String get projects_description_hint => 'Enter project description';

  @override
  String get projects_project_details => 'Project Details';

  @override
  String get projects_edit_coming_soon => 'Edit feature coming soon';

  @override
  String get projects_delete_project => 'Delete Project';

  @override
  String get projects_delete_confirmation =>
      'Are you sure you want to delete this project? This action cannot be undone.';

  @override
  String get projects_project_deleted => 'Project deleted successfully';

  @override
  String projects_failed_to_delete(String error) {
    return 'Failed to delete project: $error';
  }

  @override
  String get projects_no_projects_yet => 'No Projects Yet';

  @override
  String get projects_create_first_project =>
      'Create your first project to start monitoring your services';

  @override
  String projects_failed_to_load_api_keys(String error) {
    return 'Failed to load API keys: $error';
  }

  @override
  String get projects_no_api_key_warning =>
      'No API key configured for this project. Please create one in settings.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general => 'General';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_notifications => 'Notificaion';

  @override
  String get settings_notification_subtitle =>
      'Request notification permission';

  @override
  String get settings_light => 'Light';

  @override
  String get settings_dark => 'Dark';

  @override
  String get settings_blue => 'Blue';

  @override
  String get settings_select_theme => 'Select Theme';

  @override
  String get settings_select_language => 'Select Language';

  @override
  String get settings_english => 'English';

  @override
  String get settings_korean => '한국어 (Korean)';

  @override
  String get settings_change_project => 'Change Project';

  @override
  String get settings_change_project_desc => 'Select a different project';

  @override
  String get settings_no_project_selected => 'No Project Selected';

  @override
  String get settings_no_project_desc => 'Select a project to get started';

  @override
  String get settings_select_project => 'Select Project';

  @override
  String get settings_signed_in_as => 'Signed in as';

  @override
  String get settings_sign_out => 'Sign Out';

  @override
  String get settings_sign_out_confirmation =>
      'Are you sure you want to sign out?';

  @override
  String get settings_signed_out => 'Signed out successfully';

  @override
  String get settings_delete_account => 'Delete Account';

  @override
  String get settings_delete_account_confirmation =>
      'Are you sure you want to delete this account and included informations?';

  @override
  String get settings_deleted_account => 'your account deleted successfully';

  @override
  String get settings_api_key => 'API Key';

  @override
  String get settings_authenticated => 'Authenticated';

  @override
  String settings_api_key_desc(String project) {
    return 'API key for project: $project';
  }

  @override
  String settings_active_key(String keyName) {
    return 'Active key: $keyName';
  }

  @override
  String get settings_no_project_api_key =>
      'No project selected. Select a project to view API key.';

  @override
  String get settings_no_api_key => 'No API Key';

  @override
  String get settings_security_warning =>
      'Keep your API key secure. Do not share it publicly.';

  @override
  String get settings_switch_key => 'Switch Key';

  @override
  String get settings_switch_key_response => 'Switch Key is preparation';

  @override
  String get settings_create_key => 'Create Key';

  @override
  String get settings_create_key_response => 'Create Key is preparation';

  @override
  String get settings_api_key_copied => 'API key copied to clipboard';

  @override
  String get settings_copy_to_clipboard => 'Copy to clipboard';

  @override
  String get analysis_title => 'AI Analysis Overview';

  @override
  String get analysis_refresh => 'Refresh Analysis';

  @override
  String get analysis_refresh_coming_soon => 'Refresh feature coming soon';

  @override
  String get analysis_filter => 'Filter';

  @override
  String get analysis_filter_coming_soon => 'Filter feature coming soon';

  @override
  String get analysis_bulk_request_coming_soon =>
      'Bulk analysis request coming soon';

  @override
  String get analysis_request_analysis => 'Request Analysis';

  @override
  String get analysis_loading => 'Loading AI Analysis...';

  @override
  String get analysis_summary => 'Analysis Summary';

  @override
  String get analysis_total_analyses => 'Total Analyses';

  @override
  String get analysis_pending => 'Pending';

  @override
  String get analysis_completed => 'Completed';

  @override
  String get analysis_failed => 'Failed';

  @override
  String get analysis_recent_analyses => 'Recent AI Analyses';

  @override
  String get analysis_no_analyses => 'No AI analyses yet';

  @override
  String get analysis_no_analyses_message =>
      'Request AI analysis on incidents to get started';

  @override
  String get analysis_insights_recommendations => 'Insights & Recommendations';

  @override
  String get analysis_ai_powered_insights => 'AI-Powered Insights';

  @override
  String get analysis_insights_message =>
      'AI will analyze your incident patterns and provide recommendations:';

  @override
  String get analysis_insight_root_cause => 'Root cause identification';

  @override
  String get analysis_insight_pattern_detection =>
      'Pattern detection across incidents';

  @override
  String get analysis_insight_remediation => 'Suggested remediation steps';

  @override
  String get analysis_insight_prevention => 'Prevention recommendations';

  @override
  String get analysis_auth_required => 'Authentication Required';

  @override
  String get analysis_auth_required_message =>
      'AI analysis is only available for authenticated users with server access.';

  @override
  String get service_type_http_api => 'HTTP API';

  @override
  String get service_type_https_api => 'HTTPS API';

  @override
  String get service_type_gcp_endpoint => 'GCP Endpoint';

  @override
  String get service_type_firebase => 'Firebase';

  @override
  String get service_type_websocket => 'WebSocket';

  @override
  String get service_type_grpc => 'gRPC';

  @override
  String get http_method_get => 'GET';

  @override
  String get http_method_post => 'POST';

  @override
  String get http_method_put => 'PUT';

  @override
  String get http_method_delete => 'DELETE';

  @override
  String get http_method_patch => 'PATCH';

  @override
  String get http_method_head => 'HEAD';

  @override
  String get incident_status_open => 'Open';

  @override
  String get incident_status_investigating => 'Investigating';

  @override
  String get incident_status_resolved => 'Resolved';

  @override
  String get incident_status_acknowledged => 'Acknowledged';

  @override
  String get incident_severity_critical => 'Critical';

  @override
  String get incident_severity_high => 'High';

  @override
  String get incident_severity_medium => 'Medium';

  @override
  String get incident_severity_low => 'Low';

  @override
  String get service_state_healthy => 'Healthy';

  @override
  String get service_state_error => 'Error';

  @override
  String get service_state_inactive => 'Inactive';

  @override
  String get project_health_healthy => 'Healthy';

  @override
  String get project_health_degraded => 'Degraded';

  @override
  String get project_health_unknown => 'Unknown';

  @override
  String get error_general => 'An error occurred. Please try again.';

  @override
  String get error_network => 'Network error. Please check your connection.';

  @override
  String get error_unauthorized => 'Unauthorized. Please login again.';

  @override
  String get error_not_found => 'Resource not found.';

  @override
  String get error_server => 'Server error. Please try again later.';

  @override
  String get error_validation => 'Validation error. Please check your input.';

  @override
  String get error_storage => 'Storage error. Please try again.';

  @override
  String get error_undefined => 'Unknown error occurred.';

  @override
  String get error_analysis => 'AI analysis error. Please try again.';

  @override
  String get error_guest_limit => 'guest only can create 1 project';

  @override
  String get error_service_name_required => 'Service name is required';

  @override
  String get error_failed_to_create_service => 'Failed to create service';

  @override
  String get error_auth_unavailable => 'Authentication state unavailable';

  @override
  String get error_failed_to_create_project => 'Failed to create project';

  @override
  String get error_failed_to_bootstrap_guest =>
      'Failed to bootstrap guest user';

  @override
  String get error_timeout => 'Request timed out. Please try again.';

  @override
  String get error_connection_failed =>
      'Connection failed. Please check your network.';

  @override
  String get error_invalid_response => 'Invalid server response.';

  @override
  String get error_firebase_auth => 'Authentication error occurred.';

  @override
  String get error_firebase_user_not_found => 'User not found.';

  @override
  String get error_firebase_wrong_password => 'Incorrect password.';

  @override
  String get error_firebase_email_in_use => 'Email address is already in use.';

  @override
  String get error_firebase_weak_password => 'Password is too weak.';

  @override
  String get error_firebase_invalid_email => 'Invalid email address.';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_email_invalid => 'Please enter a valid email address';

  @override
  String validation_password_min_length(int length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get validation_url_invalid => 'Please enter a valid URL';

  @override
  String validation_number_min(int min) {
    return 'Value must be at least $min';
  }

  @override
  String validation_number_max(int max) {
    return 'Value must be at most $max';
  }

  @override
  String validation_field_required(String field) {
    return '$field is required';
  }

  @override
  String get validation_invalid_number => 'Invalid number';

  @override
  String get validation_url_protocol =>
      'URL must start with http:// or https://';

  @override
  String validation_number_between(int min, int max) {
    return 'Value must be between $min and $max';
  }

  @override
  String validation_max_length(int max) {
    return 'Cannot exceed $max characters';
  }

  @override
  String get validation_project_name_required => 'Project name is required';

  @override
  String get validation_project_name_max_length =>
      'Project name cannot exceed 100 characters';
}

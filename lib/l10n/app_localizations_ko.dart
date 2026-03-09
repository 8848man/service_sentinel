// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get common_ok => '확인';

  @override
  String get common_cancel => '취소';

  @override
  String get common_confirm => '확인';

  @override
  String get common_delete => '삭제';

  @override
  String get common_edit => '편집';

  @override
  String get common_save => '저장';

  @override
  String get common_loading => '로딩 중...';

  @override
  String get common_error => '오류';

  @override
  String get common_success => '성공';

  @override
  String get common_retry => '재시도';

  @override
  String get common_back => '뒤로';

  @override
  String get common_next => '다음';

  @override
  String get common_skip => '건너뛰기';

  @override
  String get common_done => '완료';

  @override
  String get common_or => '또는';

  @override
  String get common_close => '닫기';

  @override
  String get common_create => '생성';

  @override
  String get common_creating => '생성 중...';

  @override
  String get app_title => '서비스 센티넬';

  @override
  String get app_subtitle => 'AI 기반 API 모니터링';

  @override
  String get navigation_dashboard => '대시보드';

  @override
  String get navigation_services => '서비스';

  @override
  String get navigation_incidents => '인시던트';

  @override
  String get navigation_settings => '설정';

  @override
  String get auth_login => '로그인';

  @override
  String get auth_logout => '로그아웃';

  @override
  String get auth_signup => '회원가입';

  @override
  String get auth_email => '이메일';

  @override
  String get auth_password => '비밀번호';

  @override
  String get auth_forgot_password => '비밀번호를 잊으셨나요?';

  @override
  String get auth_guest_mode => '게스트로 계속하기';

  @override
  String get auth_guest_mode_desc => '로그인 없이 앱을 사용합니다. 데이터는 이 기기에만 저장됩니다.';

  @override
  String get auth_enter_as_guest => '게스트로 입장';

  @override
  String get auth_sign_in_email => '이메일로 로그인';

  @override
  String get auth_sign_in_google => '구글 계정으로 로그인';

  @override
  String get auth_sign_in_desc => '클라우드 동기화로 모든 기기에서 프로젝트에 액세스하세요.';

  @override
  String get auth_dont_have_account => '계정이 없으신가요? 가입하기';

  @override
  String get auth_signing_in => '로그인 중...';

  @override
  String get auth_login_failed => '로그인에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get auth_creating_account => '계정 생성 중...';

  @override
  String get auth_sign_up => '회원가입';

  @override
  String get auth_sign_up_email => '이메일로 회원가입';

  @override
  String get auth_sign_up_desc => '새 계정을 생성하려면 가입하세요';

  @override
  String get auth_signup_failed => '회원가입에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get auth_sign_up_cancel => '취소';

  @override
  String get auth_migration_dialog_title => '로컬 프로젝트를 마이그레이션하시겠습니까?';

  @override
  String get auth_migration_dialog_message =>
      '이 기기에 저장된 로컬 프로젝트가 있습니다. 클라우드로 마이그레이션하시겠습니까?';

  @override
  String get auth_migration_cloud_sync => '클라우드 동기화';

  @override
  String get auth_migration_cloud_sync_desc => '모든 기기에서 프로젝트에 액세스';

  @override
  String get auth_migration_backup => '백업';

  @override
  String get auth_migration_backup_desc => '데이터가 안전하게 백업됩니다';

  @override
  String get auth_migration_team => '팀 협업';

  @override
  String get auth_migration_team_desc => '팀원과 프로젝트 공유';

  @override
  String get auth_skip_for_now => '나중에 하기';

  @override
  String get auth_migrate_now => '지금 마이그레이션';

  @override
  String get dashboard_title => '대시보드';

  @override
  String get dashboard_welcome_back => '다시 오신 것을 환영합니다!';

  @override
  String get dashboard_guest_mode => '게스트 모드';

  @override
  String dashboard_current_project(String projectName) {
    return '현재 프로젝트: $projectName';
  }

  @override
  String get dashboard_no_project_selected =>
      '프로젝트가 선택되지 않았습니다. 모니터링을 시작하려면 프로젝트를 선택하세요.';

  @override
  String get dashboard_quick_stats => '빠른 통계';

  @override
  String get dashboard_services => '서비스';

  @override
  String get dashboard_incidents => '인시던트';

  @override
  String get dashboard_healthy => '정상';

  @override
  String get dashboard_issues => '문제';

  @override
  String get services_title => '서비스';

  @override
  String get services_monitored_services => '모니터링 중인 서비스';

  @override
  String get services_monitored_services_desc => '모니터링 중인 API 및 엔드포인트';

  @override
  String get services_add_service => '서비스 추가';

  @override
  String get services_failed_to_load => '서비스를 로드하지 못했습니다';

  @override
  String get services_no_services_yet => '서비스가 없습니다';

  @override
  String get services_no_services_message => '첫 번째 서비스를 추가하여 모니터링을 시작하세요';

  @override
  String get services_no_services_recommended_service => '추천 서비스 세트 등록하기';

  @override
  String get services_service_name => '서비스 이름';

  @override
  String get services_service_name_required => '서비스 이름 *';

  @override
  String get services_service_name_hint => '내 API 서비스';

  @override
  String get services_description_optional => '설명 (선택사항)';

  @override
  String get services_description_hint => '서비스 설명 입력';

  @override
  String get services_endpoint_url => '엔드포인트 URL';

  @override
  String get services_endpoint_url_required => '엔드포인트 URL *';

  @override
  String get services_endpoint_url_hint => 'https://api.example.com/health';

  @override
  String get services_http_method => 'HTTP 메서드';

  @override
  String get services_http_method_required => 'HTTP 메서드 *';

  @override
  String get services_service_type => '서비스 타입';

  @override
  String get services_service_type_required => '서비스 타입 *';

  @override
  String get services_timeout_seconds => '타임아웃 (초)';

  @override
  String get services_timeout_seconds_required => '타임아웃 (초) *';

  @override
  String get services_timeout_hint => '10';

  @override
  String get services_check_interval_seconds => '확인 간격 (초)';

  @override
  String get services_check_interval_seconds_required => '확인 간격 (초) *';

  @override
  String get services_check_interval_hint => '60';

  @override
  String get services_failure_threshold => '실패 임계값';

  @override
  String get services_failure_threshold_required => '실패 임계값 *';

  @override
  String get services_failure_threshold_desc => '인시던트 발생 전 연속 실패 횟수';

  @override
  String get services_failure_threshold_hint => '3';

  @override
  String get services_advanced_settings => '고급 설정';

  @override
  String get services_service_details => '서비스 세부정보';

  @override
  String get services_manual_check_coming_soon => '수동 확인 기능 준비 중';

  @override
  String get services_edit_coming_soon => '편집 기능 준비 중';

  @override
  String get services_deactivate_coming_soon => '비활성화 기능 준비 중';

  @override
  String get services_deactivate => '비활성화';

  @override
  String get services_delete_service => '서비스 삭제';

  @override
  String get services_delete_confirmation_message =>
      '이 서비스를 삭제하시겠습니까? 모든 모니터링 데이터가 제거됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get services_service_deleted => '서비스가 성공적으로 삭제되었습니다';

  @override
  String services_failed_to_delete(String error) {
    return '서비스 삭제 실패: $error';
  }

  @override
  String services_check_interval(int seconds) {
    return '확인 간격: $seconds초';
  }

  @override
  String services_failure_threshold_value(int count) {
    return '실패 임계값: $count';
  }

  @override
  String services_last_checked(String time) {
    return '마지막 확인: $time';
  }

  @override
  String get services_just_now => '방금 전';

  @override
  String services_minutes_ago(int minutes) {
    return '$minutes분 전';
  }

  @override
  String services_hours_ago(int hours) {
    return '$hours시간 전';
  }

  @override
  String services_days_ago(int days) {
    return '$days일 전';
  }

  @override
  String get services_active => '활성';

  @override
  String get services_inactive => '비활성';

  @override
  String get services_error_loading_service => '서비스 로드 오류';

  @override
  String get services_endpoint => '엔드포인트';

  @override
  String get services_method => '메서드';

  @override
  String get services_type => '유형';

  @override
  String get services_check_interval_label => '확인 간격';

  @override
  String get services_timeout_label => '타임아웃';

  @override
  String get services_failure_threshold_label => '실패 임계값';

  @override
  String get services_last_checked_label => '마지막 확인';

  @override
  String get services_statistics_last_7_days => '통계 (최근 7일)';

  @override
  String get services_unable_to_load_statistics => '통계를 로드할 수 없습니다';

  @override
  String get services_uptime => '가동 시간';

  @override
  String get services_total_checks => '총 확인 횟수';

  @override
  String get services_successful => '성공';

  @override
  String get services_failed => '실패';

  @override
  String get services_avg_latency => '평균 지연 시간';

  @override
  String get services_health_check_history => '상태 확인 기록';

  @override
  String get services_health_check_history_placeholder => '상태 확인 기록이 여기에 표시됩니다';

  @override
  String get services_related_incidents => '관련 인시던트';

  @override
  String get services_related_incidents_placeholder => '관련 인시던트가 여기에 표시됩니다';

  @override
  String get incidents_title => '인시던트';

  @override
  String get incidents_desc => '서비스 장애 이벤트 및 알림';

  @override
  String get incidents_failed_to_load => '인시던트를 로드하지 못했습니다';

  @override
  String get incidents_no_incidents => '인시던트 없음';

  @override
  String get incidents_all_services_running => '모든 서비스가 정상적으로 실행 중입니다';

  @override
  String get incidents_open_incidents => '열린 인시던트';

  @override
  String get incidents_resolved_incidents => '해결된 인시던트';

  @override
  String incidents_detected(String time) {
    return '발견됨: $time';
  }

  @override
  String incidents_failures_count(int count) {
    return '$count회 실패';
  }

  @override
  String get incidents_timeline => '타임라인';

  @override
  String get incidents_timeline_detected => '발견됨';

  @override
  String get incidents_timeline_acknowledged => '확인됨';

  @override
  String get incidents_timeline_resolved => '해결됨';

  @override
  String get incidents_ai_analysis_available => 'AI 분석 가능';

  @override
  String get incidents_ai_analysis_in_progress => 'AI 분석 진행 중';

  @override
  String get incidents_root_cause_analysis_completed => '근본 원인 분석 완료';

  @override
  String get incidents_root_cause_analysis_generating => '근본 원인 분석 생성 중';

  @override
  String get incidents_incident_details => '인시던트 세부정보';

  @override
  String get incidents_request_ai_analysis => 'AI 분석 요청';

  @override
  String get incidents_acknowledge => '확인';

  @override
  String get incidents_resolve => '해결';

  @override
  String get incidents_acknowledged_success => '인시던트가 성공적으로 확인되었습니다';

  @override
  String incidents_failed_to_acknowledge(String error) {
    return '확인 실패: $error';
  }

  @override
  String get incidents_resolve_incident => '인시던트 해결';

  @override
  String get incidents_resolve_confirmation => '이 인시던트를 해결됨으로 표시하시겠습니까?';

  @override
  String get incidents_resolved_success => '인시던트가 성공적으로 해결되었습니다';

  @override
  String incidents_failed_to_resolve(String error) {
    return '해결 실패: $error';
  }

  @override
  String get incidents_request_analysis => '분석 요청';

  @override
  String get incidents_request_analysis_dialog_title => 'AI 분석 요청';

  @override
  String get incidents_request_analysis_dialog_message =>
      '이 인시던트를 분석하여 근본 원인 분석, 디버그 단계 및 권장 조치를 제공하도록 AI에 요청하시겠습니까?\n\n분석 완료까지 시간이 걸릴 수 있습니다.';

  @override
  String get incidents_ai_analysis_requested => 'AI 분석이 요청되었습니다. 곧 사용할 수 있습니다.';

  @override
  String incidents_failed_to_request_analysis(String error) {
    return '분석 요청 실패: $error';
  }

  @override
  String get incidents_statistics => '통계';

  @override
  String get incidents_consecutive_failures => '연속 실패';

  @override
  String get incidents_total_affected_checks => '총 영향받은 확인';

  @override
  String get incidents_incident_not_found => '인시던트를 찾을 수 없습니다';

  @override
  String get incidents_ai_analysis_view_coming_soon => 'AI 분석 보기 준비 중';

  @override
  String get incidents_view_analysis => '분석 보기';

  @override
  String get incidents_ai_analysis_request_sent => 'AI 분석 요청이 전송되었습니다';

  @override
  String get incidents_ai_root_cause => 'AI 근본 원인 분석';

  @override
  String incidents_generated_by(String model) {
    return '$model에서 생성됨';
  }

  @override
  String get incidents_root_cause_hypothesis => '근본 원인 가설';

  @override
  String get incidents_debug_checklist => '디버그 체크리스트';

  @override
  String get incidents_suggested_actions => '권장 조치';

  @override
  String get incidents_no_analysis_available => '사용 가능한 AI 분석이 없습니다';

  @override
  String get incidents_analysis_not_available => '분석을 사용할 수 없음';

  @override
  String get incidents_error_loading => '인시던트 로드 오류';

  @override
  String get incidents_service_id => '서비스 ID';

  @override
  String get incidents_detected_at => '발견 시각';

  @override
  String get incidents_acknowledged_at => '확인 시각';

  @override
  String get incidents_resolved_at => '해결 시각';

  @override
  String get incidents_ai_analysis_complete => 'AI 분석 완료';

  @override
  String get incidents_ai_analysis_pending => 'AI 분석 대기 중';

  @override
  String get incidents_ai_root_cause_available => 'AI 근본 원인 분석 가능';

  @override
  String get incidents_view_ai_insights => 'AI 생성 인사이트, 근본 원인 가설 및 권장 조치 보기';

  @override
  String get incidents_related_health_checks => '관련 상태 확인';

  @override
  String get incidents_related_health_checks_placeholder =>
      '관련 상태 확인이 여기에 표시됩니다';

  @override
  String get incidents_related_error_patterns => '관련 오류 패턴';

  @override
  String get incidents_no_analysis_message =>
      '이 인시던트에 대한 AI 분석이 아직 생성되지 않았습니다.\n인시던트 세부정보 화면에서 분석을 요청하세요.';

  @override
  String get incidents_confidence_score => '신뢰도 점수';

  @override
  String get incidents_confidence_high => '분석에 대한 높은 신뢰도';

  @override
  String get incidents_confidence_moderate => '중간 신뢰도 - 수동 검증 권장';

  @override
  String get incidents_confidence_low => '낮은 신뢰도 - 추가 조사 필요';

  @override
  String get incidents_analysis_metadata => '분석 메타데이터';

  @override
  String get incidents_metadata_model => '모델';

  @override
  String get incidents_metadata_tokens => '토큰';

  @override
  String incidents_metadata_tokens_detail(
      int total, int prompt, int completion) {
    return '$total (프롬프트: $prompt, 완료: $completion)';
  }

  @override
  String get incidents_metadata_cost => '비용';

  @override
  String get incidents_metadata_duration => '소요 시간';

  @override
  String incidents_metadata_duration_value(int milliseconds) {
    return '${milliseconds}ms';
  }

  @override
  String get incidents_metadata_analyzed_at => '분석 시각';

  @override
  String get incidents_failed_to_load_analysis => '분석 로드 실패';

  @override
  String get projects_title => '프로젝트';

  @override
  String get projects_your_projects => '내 프로젝트';

  @override
  String get projects_new_project => '새 프로젝트';

  @override
  String get projects_failed_to_load => '프로젝트를 로드하지 못했습니다';

  @override
  String projects_error_selecting(String error) {
    return '프로젝트 선택 오류: $error';
  }

  @override
  String get projects_guest_limit_reached => '게스트 제한 도달';

  @override
  String get projects_guest_limit_message =>
      '게스트 사용자는 1개의 프로젝트로 제한됩니다. 무제한 프로젝트를 생성하고 고급 기능에 액세스하려면 Google로 로그인하세요.';

  @override
  String get projects_sign_in => '로그인';

  @override
  String get projects_create_new_project => '새 프로젝트 생성';

  @override
  String get projects_project_name => '프로젝트 이름';

  @override
  String get projects_project_name_required => '프로젝트 이름 *';

  @override
  String get projects_project_name_hint => '프로젝트 이름 입력';

  @override
  String get projects_description_optional => '설명 (선택사항)';

  @override
  String get projects_description_hint => '프로젝트 설명 입력';

  @override
  String get projects_project_details => '프로젝트 세부정보';

  @override
  String get projects_edit_coming_soon => '편집 기능 준비 중';

  @override
  String get projects_delete_project => '프로젝트 삭제';

  @override
  String get projects_delete_confirmation =>
      '이 프로젝트를 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get projects_project_deleted => '프로젝트가 성공적으로 삭제되었습니다';

  @override
  String projects_failed_to_delete(String error) {
    return '프로젝트 삭제 실패: $error';
  }

  @override
  String get projects_no_projects_yet => '프로젝트가 없습니다';

  @override
  String get projects_create_first_project => '첫 번째 프로젝트를 생성하여 서비스 모니터링을 시작하세요';

  @override
  String projects_failed_to_load_api_keys(String error) {
    return 'API 키 로드 실패: $error';
  }

  @override
  String get projects_no_api_key_warning =>
      '이 프로젝트에 대한 API 키가 구성되지 않았습니다. 설정에서 생성해 주세요.';

  @override
  String get settings_title => '설정';

  @override
  String get settings_general => '일반';

  @override
  String get settings_theme => '테마';

  @override
  String get settings_language => '언어';

  @override
  String get settings_notifications => '알림';

  @override
  String get settings_notification_subtitle => '알림 권한 요청을 받습니다.';

  @override
  String get settings_light => '라이트';

  @override
  String get settings_dark => '다크';

  @override
  String get settings_blue => '블루';

  @override
  String get settings_select_theme => '테마 선택';

  @override
  String get settings_select_language => '언어 선택';

  @override
  String get settings_english => 'English';

  @override
  String get settings_korean => '한국어 (Korean)';

  @override
  String get settings_change_project => '프로젝트 변경';

  @override
  String get settings_change_project_desc => '다른 프로젝트 선택';

  @override
  String get settings_no_project_selected => '선택된 프로젝트 없음';

  @override
  String get settings_no_project_desc => '시작하려면 프로젝트를 선택하세요';

  @override
  String get settings_select_project => '프로젝트 선택';

  @override
  String get settings_signed_in_as => '로그인:';

  @override
  String get settings_sign_out => '로그아웃';

  @override
  String get settings_sign_out_confirmation => '로그아웃하시겠습니까?';

  @override
  String get settings_signed_out => '성공적으로 로그아웃되었습니다';

  @override
  String get settings_delete_account => '계정 삭제';

  @override
  String get settings_delete_account_confirmation =>
      '정말로 이 계정과 해당하는 정보를 삭제하시겠습니까?';

  @override
  String get settings_deleted_account => '계정이 삭제되었습니다.';

  @override
  String get settings_api_key => 'API 키';

  @override
  String get settings_authenticated => '인증됨';

  @override
  String settings_api_key_desc(String project) {
    return '프로젝트 API 키: $project';
  }

  @override
  String settings_active_key(String keyName) {
    return '활성 키: $keyName';
  }

  @override
  String get settings_no_project_api_key =>
      '프로젝트가 선택되지 않았습니다. API 키를 보려면 프로젝트를 선택하세요.';

  @override
  String get settings_no_api_key => 'API 키 없음';

  @override
  String get settings_security_warning => 'API 키를 안전하게 보관하세요. 공개적으로 공유하지 마세요.';

  @override
  String get settings_switch_key => '키 전환';

  @override
  String get settings_switch_key_response => '키 전환 기능은 준비중입니다.';

  @override
  String get settings_create_key => '키 생성';

  @override
  String get settings_create_key_response => '키 생성 기능은 준비중입니다.';

  @override
  String get settings_api_key_copied => 'API 키가 클립보드에 복사되었습니다';

  @override
  String get settings_copy_to_clipboard => '클립보드에 복사';

  @override
  String get analysis_title => 'AI 분석 개요';

  @override
  String get analysis_refresh => '분석 새로고침';

  @override
  String get analysis_refresh_coming_soon => '새로고침 기능 준비 중';

  @override
  String get analysis_filter => '필터';

  @override
  String get analysis_filter_coming_soon => '필터 기능 준비 중';

  @override
  String get analysis_bulk_request_coming_soon => '대량 분석 요청 기능 준비 중';

  @override
  String get analysis_request_analysis => '분석 요청';

  @override
  String get analysis_loading => 'AI 분석 로딩 중...';

  @override
  String get analysis_summary => '분석 요약';

  @override
  String get analysis_total_analyses => '총 분석';

  @override
  String get analysis_pending => '대기 중';

  @override
  String get analysis_completed => '완료됨';

  @override
  String get analysis_failed => '실패';

  @override
  String get analysis_recent_analyses => '최근 AI 분석';

  @override
  String get analysis_no_analyses => '아직 AI 분석이 없습니다';

  @override
  String get analysis_no_analyses_message => '인시던트에 대한 AI 분석을 요청하여 시작하세요';

  @override
  String get analysis_insights_recommendations => '인사이트 및 권장사항';

  @override
  String get analysis_ai_powered_insights => 'AI 기반 인사이트';

  @override
  String get analysis_insights_message => 'AI가 인시던트 패턴을 분석하고 권장사항을 제공합니다:';

  @override
  String get analysis_insight_root_cause => '근본 원인 식별';

  @override
  String get analysis_insight_pattern_detection => '인시던트 간 패턴 감지';

  @override
  String get analysis_insight_remediation => '권장 해결 단계';

  @override
  String get analysis_insight_prevention => '예방 권장사항';

  @override
  String get analysis_auth_required => '인증 필요';

  @override
  String get analysis_auth_required_message =>
      'AI 분석은 서버 액세스 권한이 있는 인증된 사용자만 사용할 수 있습니다.';

  @override
  String get service_type_http_api => 'HTTP API';

  @override
  String get service_type_https_api => 'HTTPS API';

  @override
  String get service_type_gcp_endpoint => 'GCP 엔드포인트';

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
  String get incident_status_open => '열림';

  @override
  String get incident_status_investigating => '조사 중';

  @override
  String get incident_status_resolved => '해결됨';

  @override
  String get incident_status_acknowledged => '확인됨';

  @override
  String get incident_severity_critical => '치명적';

  @override
  String get incident_severity_high => '높음';

  @override
  String get incident_severity_medium => '중간';

  @override
  String get incident_severity_low => '낮음';

  @override
  String get service_state_healthy => '정상';

  @override
  String get service_state_error => '오류';

  @override
  String get service_state_inactive => '비활성';

  @override
  String get project_health_healthy => '정상';

  @override
  String get project_health_degraded => '저하됨';

  @override
  String get project_health_unknown => '알 수 없음';

  @override
  String get error_general => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get error_network => '네트워크 오류. 연결을 확인해 주세요.';

  @override
  String get error_unauthorized => '인증되지 않았습니다. 다시 로그인해 주세요.';

  @override
  String get error_not_found => '리소스를 찾을 수 없습니다.';

  @override
  String get error_server => '서버 오류. 나중에 다시 시도해 주세요.';

  @override
  String get error_validation => '유효성 검사 오류. 입력을 확인해 주세요.';

  @override
  String get error_storage => '저장소 오류. 다시 시도해 주세요.';

  @override
  String get error_undefined => '알 수 없는 오류가 발생했습니다.';

  @override
  String get error_analysis => 'AI 분석 오류. 다시 시도해 주세요.';

  @override
  String get error_guest_limit => '게스트는 하나의 프로젝트만 만들 수 있습니다.';

  @override
  String get error_service_name_required => '서비스 이름이 필요합니다';

  @override
  String get error_failed_to_create_service => '서비스 생성에 실패했습니다';

  @override
  String get error_auth_unavailable => '인증 상태를 사용할 수 없습니다';

  @override
  String get error_failed_to_create_project => '프로젝트 생성에 실패했습니다';

  @override
  String get error_failed_to_bootstrap_guest => '게스트 사용자 부트스트랩에 실패했습니다';

  @override
  String get error_timeout => '요청 시간이 초과되었습니다. 다시 시도해 주세요.';

  @override
  String get error_connection_failed => '연결에 실패했습니다. 네트워크를 확인해 주세요.';

  @override
  String get error_invalid_response => '잘못된 서버 응답입니다.';

  @override
  String get error_firebase_auth => '인증 오류가 발생했습니다.';

  @override
  String get error_firebase_user_not_found => '사용자를 찾을 수 없습니다.';

  @override
  String get error_firebase_wrong_password => '비밀번호가 올바르지 않습니다.';

  @override
  String get error_firebase_email_in_use => '이메일 주소가 이미 사용 중입니다.';

  @override
  String get error_firebase_weak_password => '비밀번호가 너무 약합니다.';

  @override
  String get error_firebase_invalid_email => '잘못된 이메일 주소입니다.';

  @override
  String get validation_required => '이 필드는 필수입니다';

  @override
  String get validation_email_invalid => '유효한 이메일 주소를 입력해 주세요';

  @override
  String validation_password_min_length(int length) {
    return '비밀번호는 최소 $length자 이상이어야 합니다';
  }

  @override
  String get validation_url_invalid => '유효한 URL을 입력해 주세요';

  @override
  String validation_number_min(int min) {
    return '값은 최소 $min 이상이어야 합니다';
  }

  @override
  String validation_number_max(int max) {
    return '값은 최대 $max 이하여야 합니다';
  }

  @override
  String validation_field_required(String field) {
    return '$field이(가) 필요합니다';
  }

  @override
  String get validation_invalid_number => '유효하지 않은 숫자';

  @override
  String get validation_url_protocol => 'URL은 http:// 또는 https://로 시작해야 합니다';

  @override
  String validation_number_between(int min, int max) {
    return '값은 $min에서 $max 사이여야 합니다';
  }

  @override
  String validation_max_length(int max) {
    return '$max자를 초과할 수 없습니다';
  }

  @override
  String get validation_project_name_required => '프로젝트 이름이 필요합니다';

  @override
  String get validation_project_name_max_length => '프로젝트 이름은 100자를 초과할 수 없습니다';
}

import 'package:flutter/material.dart';

abstract class SSStrings {
  String get navFeatures;
  String get navPricing;
  String get navStartFree;

  String get heroHeadline1;
  String get heroHeadline2;
  String get heroSubheadline;
  String get heroFreeTierNote;
  String get heroCtaPrimary;
  String get heroCtaSecondary;

  String get targetSectionTitle;
  String get targetSectionSubtitle;
  String get target1Role;
  String get target1Pain;
  String get target1Solution;
  String get target2Role;
  String get target2Pain;
  String get target2Solution;
  String get target3Role;
  String get target3Pain;
  String get target3Solution;
  String get target4Role;
  String get target4Pain;
  String get target4Solution;
  String get targetCtaNudge;

  String get featuresSectionTitle;
  String get featuresSectionSubtitle;
  String get featuresCard1Title;
  String get featuresCard1Description;
  String get featuresCard1Cta;
  String get featuresCard2Title;
  String get featuresCard2Description;
  String get featuresCard2Cta;
  String get featuresCard3Title;
  String get featuresCard3Description;
  String get featuresCard3Cta;
  String get featuresStep1;
  String get featuresStep2;
  String get featuresStep3;
  String get featuresFreeTierNote;

  String get previewSectionTitle;
  String get previewSectionSubtitle;
  String get previewCaption1;
  String get previewCaption2;
  String get previewCaption3;

  String get handySectionTitle;
  String get handySectionSubtitle;
  String get handyMobileTitle;
  String get handyMobilePlatform;
  String get handyMobileBullet1;
  String get handyMobileBullet2;
  String get handyMobileBullet3;
  String get handyWebTitle;
  String get handyWebBadge;
  String get handyWebBullet1;
  String get handyWebBullet2;
  String get handyWebBullet3;

  String get downloadSectionTitle;
  String get downloadSectionSubtitle;
  String get downloadAppStore;
  String get downloadAppStoreSub;
  String get downloadGooglePlay;
  String get downloadGooglePlaySub;
  String get downloadWeb;
  String get downloadWebSub;

  String get ctaHeadline1;
  String get ctaHeadline2;
  String get ctaSubtext;
  String get ctaFreeTierNote;
  String get ctaButton;
  String get ctaFooter;
}

class SSStringsEn extends SSStrings {
  @override
  String get navFeatures => 'Features';
  @override
  String get navPricing => 'Pricing';
  @override
  String get navStartFree => 'Start Free →';

  @override
  String get heroHeadline1 => 'You build it.';
  @override
  String get heroHeadline2 => 'We watch it.';
  @override
  String get heroSubheadline =>
      'So you can focus on what matters — building the next one.';
  @override
  String get heroFreeTierNote => 'Free for up to 3 projects. Always.';
  @override
  String get heroCtaPrimary => 'Start Monitoring Free →';
  @override
  String get heroCtaSecondary => 'View Demo';

  @override
  String get targetSectionTitle => 'Built for the ones who do it all.';
  @override
  String get targetSectionSubtitle =>
      'If any of these sound familiar, Service Sentinel is for you.';
  @override
  String get target1Role => 'Solo Founder';
  @override
  String get target1Pain => 'Shipping at 3AM';
  @override
  String get target1Solution => 'Wake up to reports, not disasters.';
  @override
  String get target2Role => 'Side Project Owner';
  @override
  String get target2Pain => 'At your day job while your app is live';
  @override
  String get target2Solution => 'We watch it while you can\'t.';
  @override
  String get target3Role => 'Vibe Coder';
  @override
  String get target3Pain => 'Building with AI, shipping fast';
  @override
  String get target3Solution =>
      'But who\'s watching the APIs your app depends on?';
  @override
  String get target4Role => 'Freelancer / Agency';
  @override
  String get target4Pain => 'Managing multiple clients\' projects';
  @override
  String get target4Solution => 'One incident unnoticed is one client lost.';
  @override
  String get targetCtaNudge => 'Sound like you? Start free →';

  @override
  String get featuresSectionTitle => 'Why Service Sentinel?';
  @override
  String get featuresSectionSubtitle =>
      'Everything you need to keep your APIs healthy — without the complexity.';
  @override
  String get featuresCard1Title => 'Project-Centric Monitoring';
  @override
  String get featuresCard1Description =>
      'Group your frontend, backend, and third-party APIs under a single '
      'project. See the health of your entire service at a glance.';
  @override
  String get featuresCard1Cta => 'Learn more';
  @override
  String get featuresCard2Title => 'Instant Incidents';
  @override
  String get featuresCard2Description =>
      'When failures hit your threshold, an incident is created automatically '
      'and you get notified immediately via push notification.';
  @override
  String get featuresCard2Cta => 'Learn more';
  @override
  String get featuresCard3Title => 'Zero Setup Required';
  @override
  String get featuresCard3Description =>
      'No agents. No SDKs. Just register your URL and monitoring starts '
      'instantly — no infrastructure changes needed.';
  @override
  String get featuresCard3Cta => 'Learn more';
  @override
  String get featuresStep1 => 'Create a project';
  @override
  String get featuresStep2 => 'Register your APIs';
  @override
  String get featuresStep3 => 'Get notified';
  @override
  String get featuresFreeTierNote =>
      'Up to 3 projects · Up to 20 APIs per project · No credit card required';

  @override
  String get previewSectionTitle => 'See it in action';
  @override
  String get previewSectionSubtitle =>
      'A clean, focused interface designed for developers who want insight without noise.';
  @override
  String get previewCaption1 => 'Project List';
  @override
  String get previewCaption2 => 'Dashboard';
  @override
  String get previewCaption3 => 'Incident Detail';

  @override
  String get handySectionTitle => 'Monitoring in your pocket.';
  @override
  String get handySectionSubtitle =>
      'Whether you\'re at your desk or on the go, Service Sentinel keeps you in the loop.';
  @override
  String get handyMobileTitle => 'Mobile App';
  @override
  String get handyMobilePlatform => 'iOS & Android';
  @override
  String get handyMobileBullet1 => 'Push notifications';
  @override
  String get handyMobileBullet2 => 'Check at a glance';
  @override
  String get handyMobileBullet3 => 'Resolve on the go';
  @override
  String get handyWebTitle => 'Web App';
  @override
  String get handyWebBadge => 'Coming Soon';
  @override
  String get handyWebBullet1 => 'Full dashboard';
  @override
  String get handyWebBullet2 => 'Team collaboration';
  @override
  String get handyWebBullet3 => 'Advanced analytics';

  @override
  String get downloadSectionTitle => 'Get started on your platform';
  @override
  String get downloadSectionSubtitle =>
      'Free for up to 3 projects. No credit card required.';
  @override
  String get downloadAppStore => 'App Store';
  @override
  String get downloadAppStoreSub => 'iOS / iPadOS';
  @override
  String get downloadGooglePlay => 'Google Play';
  @override
  String get downloadGooglePlaySub => 'Android';
  @override
  String get downloadWeb => 'Web App';
  @override
  String get downloadWebSub => 'Coming Soon';

  @override
  String get ctaHeadline1 => 'Your next project';
  @override
  String get ctaHeadline2 => 'needs a sentinel.';
  @override
  String get ctaSubtext =>
      'Start in minutes. No installation. No complex setup.';
  @override
  String get ctaFreeTierNote => 'Free for 3 projects · No credit card required';
  @override
  String get ctaButton => 'Start Monitoring Free →';
  @override
  String get ctaFooter => '© 2026 Service Sentinel. All rights reserved.';
}

class SSStringsKo extends SSStrings {
  @override
  String get navFeatures => '기능';
  @override
  String get navPricing => '요금제';
  @override
  String get navStartFree => '무료 시작 →';

  @override
  String get heroHeadline1 => '만드는 건 당신.';
  @override
  String get heroHeadline2 => '지키는 건 센티넬.';
  @override
  String get heroSubheadline => '다음 프로젝트에 집중하세요. 나머지는 저희가 합니다.';
  @override
  String get heroFreeTierNote => '3개 프로젝트까지 무료.';
  @override
  String get heroCtaPrimary => '무료로 시작하기 →';
  @override
  String get heroCtaSecondary => '데모 보기';

  @override
  String get targetSectionTitle => '혼자서 다 하는 분들을 위해 만들었습니다.';
  @override
  String get targetSectionSubtitle => '이 중 하나라도 공감되신다면, 서비스 센티넬이 필요합니다.';
  @override
  String get target1Role => '1인 창업자';
  @override
  String get target1Pain => '새벽 3시에 배포 중';
  @override
  String get target1Solution => '장애는 센티넬이 먼저 발견합니다.';
  @override
  String get target2Role => '사이드 프로젝트 운영자';
  @override
  String get target2Pain => '본업 중인데 서비스는 돌아가는 중';
  @override
  String get target2Solution => '자리를 비운 사이, 센티넬이 지킵니다.';
  @override
  String get target3Role => '바이브 코더';
  @override
  String get target3Pain => 'AI로 빠르게 만들고 바로 배포';
  @override
  String get target3Solution => '내 앱이 쓰는 외부 API는 누가 지키나요?';
  @override
  String get target4Role => '프리랜서 / 에이전시';
  @override
  String get target4Pain => '여러 클라이언트 프로젝트를 동시에 관리 중';
  @override
  String get target4Solution => '놓친 장애 하나가 계약 하나를 잃게 합니다.';
  @override
  String get targetCtaNudge => '공감되시나요? 무료로 시작하기 →';

  @override
  String get featuresSectionTitle => '왜 서비스 센티넬인가요?';
  @override
  String get featuresSectionSubtitle => '복잡함 없이 API 상태를 유지하는 데 필요한 모든 것.';
  @override
  String get featuresCard1Title => '프로젝트 중심 관리';
  @override
  String get featuresCard1Description =>
      '프론트엔드, 백엔드, 외부 API를 하나의 프로젝트로 묶어 서비스 전체 상태를 한눈에 확인하세요.';
  @override
  String get featuresCard1Cta => '자세히 보기';
  @override
  String get featuresCard2Title => '즉각적인 인시던트';
  @override
  String get featuresCard2Description =>
      '실패 횟수가 임계치를 넘으면 인시던트를 생성하고 즉시 알림을 발송합니다.';
  @override
  String get featuresCard2Cta => '자세히 보기';
  @override
  String get featuresCard3Title => '설치 불필요';
  @override
  String get featuresCard3Description =>
      '에이전트도, SDK도 없습니다. URL 등록 후 바로 모니터링을 시작하세요.';
  @override
  String get featuresCard3Cta => '자세히 보기';
  @override
  String get featuresStep1 => '프로젝트 생성';
  @override
  String get featuresStep2 => 'API 등록';
  @override
  String get featuresStep3 => '알림 받기';
  @override
  String get featuresFreeTierNote => '최대 3개 프로젝트 · 프로젝트당 최대 20개 API · 신용카드 불필요';

  @override
  String get previewSectionTitle => '실제 화면을 확인해보세요';
  @override
  String get previewSectionSubtitle => '불필요한 정보 없이, 개발자를 위한 깔끔하고 직관적인 인터페이스.';
  @override
  String get previewCaption1 => '프로젝트 목록';
  @override
  String get previewCaption2 => '대시보드';
  @override
  String get previewCaption3 => '인시던트';

  @override
  String get handySectionTitle => '언제 어디서든, 내 손안에.';
  @override
  String get handySectionSubtitle => '데스크탑이든 이동 중이든, 서비스 센티넬이 항상 알려드립니다.';
  @override
  String get handyMobileTitle => '모바일 앱';
  @override
  String get handyMobilePlatform => 'iOS & Android';
  @override
  String get handyMobileBullet1 => '푸시 알림';
  @override
  String get handyMobileBullet2 => '한눈에 확인';
  @override
  String get handyMobileBullet3 => '이동 중에도 해결';
  @override
  String get handyWebTitle => '웹 앱';
  @override
  String get handyWebBadge => '출시 예정';
  @override
  String get handyWebBullet1 => '전체 대시보드';
  @override
  String get handyWebBullet2 => '팀 협업';
  @override
  String get handyWebBullet3 => '고급 분석';

  @override
  String get downloadSectionTitle => '지금 시작하세요';
  @override
  String get downloadSectionSubtitle => '3개 프로젝트까지 무료. 신용카드 불필요.';
  @override
  String get downloadAppStore => 'App Store';
  @override
  String get downloadAppStoreSub => 'iOS / iPadOS';
  @override
  String get downloadGooglePlay => 'Google Play';
  @override
  String get downloadGooglePlaySub => 'Android';
  @override
  String get downloadWeb => '웹 앱';
  @override
  String get downloadWebSub => '출시 예정';

  @override
  String get ctaHeadline1 => '다음 프로젝트에도';
  @override
  String get ctaHeadline2 => '센티넬이 필요합니다.';
  @override
  String get ctaSubtext => '몇 분 안에 시작하세요. 설치 불필요. 복잡한 설정 없음.';
  @override
  String get ctaFreeTierNote => '3개 프로젝트까지 무료 · 신용카드 불필요';
  @override
  String get ctaButton => '무료로 시작하기 →';
  @override
  String get ctaFooter => '© 2026 서비스 센티넬. 모든 권리 보유.';
}

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get currentLocale => _locale;

  SSStrings get strings =>
      _locale.languageCode == 'ko' ? SSStringsKo() : SSStringsEn();

  void toggle() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ko') : const Locale('en');
    notifyListeners();
  }
}

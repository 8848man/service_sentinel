import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/auth/application/providers/auth_provider.dart';
import 'package:service_sentinel_fe_v2/core/auth/application/utils/resolve_platform.dart';

// 기기 토큰을 등록해주는 서비스
// 웹일 경우, VAPID 키를 사용하여 FCM 토큰을 가져오고, 모바일일 경우 일반적으로 FCM 토큰을 가져옴
// 가져온 토큰이 기존에 저장된 토큰과 다를 경우, 서버에 등록 요청을 보내고, 성공 시 로컬에 저장
// 앱이 실행될 때마다 호출하여 토큰이 변경되었는지 확인하고, 변경되었다면 서버에 등록
class DeviceRegistrationService {
  DeviceRegistrationService(this.ref);

  final Ref ref;

  static const _webVapidKey =
      'BAy43_jIy6T8SGfbMrwNXeV_Uk_UnesKTZg_pQDU5SyzcaPpOS8agySjY3HGEnzOgvVeC_l_T4PyfTNnlyEL8qA';

  Future<void> registerIfNeeded() async {
    if (!_isSupportedPlatform()) return;

    try {
      final token = await _getFcmToken();
      if (token == null) return;

      await ref
          .read(registerDeviceTokenUseCaseProvider)
          .execute(token, resolvePlatformType());
    } catch (e) {
      debugPrint('Device registration failed: $e');
    }
  }

  bool _isSupportedPlatform() {
    if (kIsWeb) return true;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<String?> _getFcmToken() async {
    if (kIsWeb) {
      return FirebaseMessaging.instance.getToken(
        vapidKey: _webVapidKey,
      );
    }

    return FirebaseMessaging.instance.getToken();
  }
}

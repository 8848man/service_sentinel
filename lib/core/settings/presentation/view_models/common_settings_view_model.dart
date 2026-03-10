import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:service_sentinel_fe_v2/core/services/device_registration_service.dart';
part 'common_settings_view_model.g.dart';

@riverpod
class CommonSettingsViewModel extends _$CommonSettingsViewModel {
  @override
  Future<void> build() async {}

  void requestPermission() {
    // FCM 알림 권한 요청
    FirebaseMessaging.instance.requestPermission();

    // 권한 요청 후, 토큰 등록 시도
    DeviceRegistrationService(ref).registerIfNeeded();
  }
}

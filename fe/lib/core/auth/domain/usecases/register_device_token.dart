import 'package:service_sentinel_fe_v2/core/auth/domain/repositories/device_token_repository.dart';

class RegisterDeviceTokenUseCase {
  RegisterDeviceTokenUseCase(this._deviceTokenRepository);
  final IDeviceTokenRepository _deviceTokenRepository;

  Future<void> execute(String token, String platformType) async {
    await _deviceTokenRepository.saveDeviceToken(token, platformType);
  }
}

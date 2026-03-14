abstract class IDeviceTokenRepository {
  Future<void> saveDeviceToken(String token, String platformType);
  Future<void> deactiveDeviceToken(String token);
}

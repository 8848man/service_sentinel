import 'package:dio/dio.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/repositories/device_token_repository.dart';
import 'package:service_sentinel_fe_v2/core/config/app_config.dart';

class DeviceTokenRepository implements IDeviceTokenRepository {
  DeviceTokenRepository(this._dio);
  final Dio _dio;
  final String _baseUrl = '${AppConfig.apiUrl}/device-tokens';
  @override
  Future<void> deactiveDeviceToken(String token) async {
    try {
      await _dio.post(
        _baseUrl,
        data: {
          'token': token,
        },
      );
    } catch (e) {
      print('Error deactivating device token: $e');
    }
  }

  @override
  Future<void> saveDeviceToken(String token, String platformType) async {
    try {
      await _dio.post(
        _baseUrl,
        data: {
          'token': token,
          'platform': platformType,
        },
      );
    } catch (e) {
      print('Error saving device token: $e');
    }
  }
}

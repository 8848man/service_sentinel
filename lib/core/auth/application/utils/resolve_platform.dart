import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

String resolvePlatformType() {
  if (kIsWeb) {
    return 'web';
  }
  if (Platform.isAndroid) {
    return 'android';
  }
  if (Platform.isIOS) {
    return 'ios';
  }
  return 'unknown'; // 혹은 throw
}

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_sentinel_fe_v2/core/di/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for hosting main app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 권한 요청 (최초 1회만 팝업 뜸)
  unawaited(FirebaseMessaging.instance.requestPermission());

  // Initialize Hive for local storage (Guest mode)
  await Hive.initFlutter();

  final prefs = await SharedPreferences.getInstance();
  // final token = await FirebaseMessaging.instance.getToken();
  // print("WEB TOKEN: $token");
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ServiceSentinelApp(),
    ),
  );
}

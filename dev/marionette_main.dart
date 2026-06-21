// Dev-only Marionette entry point.
//
// Launch with:
//   flutter run -t dev/marionette_main.dart -d macos --debug
//   flutter run -t dev/marionette_main.dart -d <ios-simulator-id> --debug
//
// This file lives outside lib/ and depends on dev_dependencies only, so the
// production entry point stays free from Marionette test hooks.
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:Neralune/app/app_root.dart';
import 'package:Neralune/app/di/infrastructure_providers.dart';
import 'package:Neralune/core/config/app_config.dart';
import 'package:Neralune/firebase_options.dart';

Future<void> main() async {
  final isFlutterTest = Platform.environment.containsKey('FLUTTER_TEST');
  if (kDebugMode && !isFlutterTest) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      overrides: [dioProvider.overrideWithValue(_buildMarionetteDio())],
      child: const AppRoot(),
    ),
  );
}

Dio _buildMarionetteDio() {
  final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        _logHttp('request', '${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logHttp(
          'response',
          '${response.statusCode} ${response.requestOptions.method} '
              '${response.requestOptions.uri} body=${_compactData(response.data)}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        final response = error.response;
        _logHttp(
          'error',
          '${response?.statusCode ?? 'NO_STATUS'} '
              '${error.requestOptions.method} ${error.requestOptions.uri} '
              'message=${error.message} body=${_compactData(response?.data)}',
        );
        handler.next(error);
      },
    ),
  );

  return dio;
}

void _logHttp(String event, String message) {
  developer.log('[$event] $message', name: 'DIO');
}

String _compactData(Object? data) {
  if (data == null) {
    return 'null';
  }

  final text = data.toString().replaceAll(RegExp(r'\s+'), ' ');
  const maxLength = 1200;
  if (text.length <= maxLength) {
    return text;
  }

  return '${text.substring(0, maxLength)}...';
}

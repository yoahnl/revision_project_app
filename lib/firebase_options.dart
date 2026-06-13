import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      _ => throw UnsupportedError(
        'Firebase is not configured for this platform.',
      ),
    };
  }

  static const _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
  );
  static const _appleAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:000000000000:ios:0000000000000000000000',
  );
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: '1:000000000000:android:0000000000000000000000',
  );
  static const _webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:000000000000:web:0000000000000000000000',
  );
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '000000000000',
  );
  static const _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'revision-dev',
  );
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'revision-dev.appspot.com',
  );
  static const _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'revision-dev.firebaseapp.com',
  );
  static const _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.revision.revisionApp',
  );

  static const web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _webAppId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: _authDomain,
    storageBucket: _storageBucket,
  );

  static const android = FirebaseOptions(
    apiKey: _apiKey,
    appId: _androidAppId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static const ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appleAppId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: _iosBundleId,
  );

  static const macos = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appleAppId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: _iosBundleId,
  );
}

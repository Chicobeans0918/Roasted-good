// File generated for the Roasted project (from GoogleService-Info.plist).
// Firebase API keys are public client identifiers (security comes from
// Firestore rules); this file is safe to commit.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  /// True now that real options have been generated.
  static bool get isConfigured => true;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for iOS.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_3Jbp5p2WMjZGxdrRpSBMLfQADuSLJwY',
    appId: '1:943027758563:ios:a0afd6a6fe8442f976ecd6',
    messagingSenderId: '943027758563',
    projectId: 'roasted-app-579f9',
    storageBucket: 'roasted-app-579f9.firebasestorage.app',
    iosBundleId: 'com.beanquest.coffeeBeans',
  );
}

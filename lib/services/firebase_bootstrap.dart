import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Initializes Firebase only when real options have been generated.
/// Returns true when Firebase is ready, false when running offline
/// on the bundled seed data.
abstract final class FirebaseBootstrap {
  static Future<bool> init() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      return false;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      // No Firebase config for this platform (e.g. web) — stay offline
      // on the bundled seed data.
      return false;
    }
    return true;
  }
}

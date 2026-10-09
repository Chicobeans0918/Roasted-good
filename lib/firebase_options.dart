// PLACEHOLDER — DO NOT EDIT BY HAND.
//
// This file is a stand-in. Run `flutterfire configure` (see FIREBASE_SETUP.md)
// to generate the real Firebase options for the Roasted project. Until then
// `DefaultFirebaseOptions.isConfigured` is false and the app runs fully
// offline on its bundled seed data.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for the Roasted app.
class DefaultFirebaseOptions {
  /// False until `flutterfire configure` has generated real options.
  static bool get isConfigured => false;

  static FirebaseOptions get currentPlatform {
    // ignore: avoid_print
    print(
      'Firebase is not configured. Follow FIREBASE_SETUP.md, then run '
      '`flutterfire configure` to generate lib/firebase_options.dart.',
    );
    throw UnsupportedError(
      'Firebase options have not been generated. '
      'Follow FIREBASE_SETUP.md and run `flutterfire configure`.',
    );
  }
}

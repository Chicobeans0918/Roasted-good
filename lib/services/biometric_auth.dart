import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Face ID / biometric login for Roasted.
///
/// How it works: after a successful email+password login, the credentials
/// are stored in the iOS Keychain (via flutter_secure_storage). On the
/// next launch, the login screen offers a Face ID button — a successful
/// scan signs the user in with the stored credentials.
///
/// Biometrics never replace the Firebase session; they just unlock the
/// saved login. Nothing is stored until the user logs in with a password
/// at least once.
class BiometricAuth {
  BiometricAuth._();

  static final BiometricAuth instance = BiometricAuth._();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _emailKey = 'roasted_biometric_email';
  static const _passwordKey = 'roasted_biometric_password';

  /// True when the device can do biometric auth (Face ID enrolled, etc.).
  Future<bool> get canUseBiometrics async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// True when a previous password login was saved for biometric reuse.
  Future<bool> get hasSavedCredentials async {
    try {
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      return email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Saves credentials after a successful password login.
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _emailKey, value: email.trim());
    await _storage.write(key: _passwordKey, value: password);
  }

  /// Runs the Face ID prompt. Returns false if the user cancels/fails.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Log in to Roasted with Face ID',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }

  /// The saved credentials. Call only after [authenticate] succeeds.
  Future<({String email, String password})?> getCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }
}

import 'package:firebase_auth/firebase_auth.dart';

/// Authentication for Roasted.
///
/// When Firebase is configured, this wraps FirebaseAuth (email/password).
/// When it is not configured (offline builds), sign-in methods succeed
/// without an account and the app runs on the bundled seed data.
class AuthService {
  AuthService({required this.firebaseEnabled});

  final bool firebaseEnabled;

  /// Set by main() after Firebase bootstrap. Falls back to a lazy
  /// offline instance so widgets (and tests) never hit an
  /// uninitialized late variable.
  static AuthService? _instance;

  static AuthService get instance =>
      _instance ??= AuthService(firebaseEnabled: false);

  static set instance(AuthService service) => _instance = service;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser =>
      firebaseEnabled ? _auth.currentUser : null;

  bool get isSignedIn => firebaseEnabled && _auth.currentUser != null;

  Stream<User?> authStateChanges() =>
      firebaseEnabled
          ? _auth.authStateChanges()
          : Stream<User?>.value(null);

  Future<void> signInWithEmail(String email, String password) async {
    if (!firebaseEnabled) return; // offline: just enter
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> registerWithEmail(String email, String password) async {
    if (!firebaseEnabled) return; // offline: just enter
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    if (!firebaseEnabled) return;
    await _auth.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Authentication for Roasted.
///
/// When Firebase is configured, this wraps FirebaseAuth (email/password,
/// Sign in with Apple, anonymous guest). When it is not configured
/// (placeholder firebase_options.dart), every method succeeds offline and
/// the app runs without an account.
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

  /// Sign in with Apple. On iOS this uses the native Apple sheet;
  /// the Xcode "Sign in with Apple" capability must be enabled
  /// (see FIREBASE_SETUP.md).
  Future<void> signInWithApple() async {
    if (!firebaseEnabled) return; // offline: just enter
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    await _auth.signInWithCredential(oauthCredential);
  }

  /// Guest mode: anonymous Firebase session when configured,
  /// plain offline entry otherwise. Tastings stay on-device unless
  /// the guest later upgrades to a full account.
  Future<void> signInAsGuest() async {
    if (!firebaseEnabled) return;
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    if (!firebaseEnabled) return;
    await _auth.signOut();
  }
}

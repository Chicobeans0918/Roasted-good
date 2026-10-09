import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../navigation/app_shell.dart';
import '../services/auth_service.dart';
import '../services/user_data_sync.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Entry screen — serif wordmark up top, boxed fields, espresso button.
/// Wires Firebase Auth (email/password, Apple, guest) when configured;
/// otherwise signs in offline on the bundled seed data.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _registerMode = false;
  bool _busy = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enter(BuildContext context) async {
    final auth = AuthService.instance;
    final state = AppState.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      if (_registerMode) {
        if (email.isEmpty || password.isEmpty) {
          _snack('Enter an email and a password to create your account.');
          return;
        }
        await auth.registerWithEmail(email, password);
      } else {
        if (email.isNotEmpty || password.isNotEmpty) {
          await auth.signInWithEmail(email, password);
        }
        // Empty fields: offline-style entry (also covers unconfigured Firebase).
      }
      await _attachRemote(state, auth);
      navigator.pushReplacementNamed(AppShell.routeName);
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyAuthError(e));
    } catch (e) {
      _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    final auth = AuthService.instance;
    final state = AppState.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await auth.signInWithApple();
      await _attachRemote(state, auth);
      navigator.pushReplacementNamed(AppShell.routeName);
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyAuthError(e));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        _snack('Apple sign-in failed. Please try again.');
      }
    } catch (_) {
      _snack('Apple sign-in is not available right now.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest(BuildContext context) async {
    final auth = AuthService.instance;
    final state = AppState.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await auth.signInAsGuest();
      await _attachRemote(state, auth);
      navigator.pushReplacementNamed(AppShell.routeName);
    } catch (_) {
      navigator.pushReplacementNamed(AppShell.routeName);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Pulls the signed-in user's tastings + wishlist from Firestore.
  Future<void> _attachRemote(AppState state, AuthService auth) async {
    final user = auth.currentUser;
    if (user == null) {
      state.detachRemote();
      return;
    }
    await state.attachRemote(
      uid: user.uid,
      sync: UserDataSync(FirebaseFirestore.instance),
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password didn\'t match. Try again.';
      case 'email-already-in-use':
        return 'That email is already registered. Try logging in.';
      case 'weak-password':
        return 'Choose a stronger password (6+ characters).';
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }

  InputDecoration _field({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.creamDark.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Roasted',
                  textAlign: TextAlign.center,
                  style: AppType.serifStyle(size: 44, weight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your daily coffee companion',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: _field(
                    label: 'Email address',
                    hint: 'Enter your email',
                    icon: Icons.mail_outline,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: _field(
                    label: 'Password',
                    hint: 'Enter password',
                    icon: Icons.key_outlined,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _busy ? null : () => _enter(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cream,
                            ),
                          )
                        : Text(
                            _registerMode ? 'Create account' : 'Log in',
                            style: AppType.serifStyle(
                              size: 17,
                              color: AppColors.cream,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : () => _signInWithApple(context),
                    icon: const Icon(Icons.phone_iphone, size: 20),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Continue with Apple'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _registerMode
                            ? 'Already have an account? '
                            : "Don't have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => setState(
                          () => _registerMode = !_registerMode,
                        ),
                        child: Text(
                          _registerMode ? 'Log in' : 'Register an account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : () => _continueAsGuest(context),
                    child: Text(
                      'Continue as guest',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'By signing up, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

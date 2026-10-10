import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import 'navigation/app_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_bootstrap.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase when configured (see FIREBASE_SETUP.md); otherwise the app
  // runs fully offline on its bundled seed data.
  final firebaseReady = await FirebaseBootstrap.init();
  AuthService.instance = AuthService(firebaseEnabled: firebaseReady);

  final state = AppState();
  // Try the remote catalogue (Firestore) when Firebase is ready;
  // falls back to bundled seed data silently.
  unawaited(state.refreshCatalogue(firebaseEnabled: firebaseReady));

  runApp(RoastedApp(state: state));
}

class RoastedApp extends StatelessWidget {
  const RoastedApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    // Rebuilds when AppState notifies (e.g. the theme toggle), so the
    // active theme switches instantly.
    return AppStateScope(
      state: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) => MaterialApp(
          title: 'Roasted',
          theme: AppTheme.light(),
          // Designed dark theme (deep espresso, cream text) — honours the
          // user's Light / Dark / System choice, defaulting to system.
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          initialRoute: LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (_) => const LoginScreen(),
            AppShell.routeName: (_) => const AppShell(),
          },
        ),
      ),
    );
  }
}

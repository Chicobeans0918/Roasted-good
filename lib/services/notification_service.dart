import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles push notification registration and display.
///
/// Flow:
/// 1. [init] requests iOS permission and fetches the FCM token.
/// 2. The token is stored at `users/{uid}/private/fcm` so Cloud Functions
///    can target this device for comment/like notifications.
/// 3. Foreground messages are surfaced via [onForegroundMessage]; the app
///    shell shows them as a lightweight banner.
///
/// The token is saved both for restored sessions (in [init]) and on
/// sign-in (via [setUser]): previously only the sign-in path saved it,
/// so users who were already logged in never registered a token.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  bool _initialized = false;
  String? _uid;

  /// Stream of messages received while the app is in the foreground.
  Stream<RemoteMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage;

  /// Call once at startup (after Firebase init). Safe to call repeatedly.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Restored sessions never pass through the login screen, so register
      // the token here too — otherwise already-signed-in users never get one.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
        await _fetchAndSaveToken(user.uid, 'init');
      }
      // Keep the token fresh for the signed-in user.
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        final uid = _uid;
        if (uid != null) _saveToken(uid, token);
      });
    } catch (_) {
      // Messaging unavailable (e.g. simulator without push) — non-fatal.
    }
  }

  /// Call when the user signs in / out so the token follows the account.
  Future<void> setUser(String? uid) async {
    _uid = uid;
    if (uid == null) return;
    await _fetchAndSaveToken(uid, 'setUser');
  }

  /// Requests permission, then fetches + saves the FCM token, retrying
  /// while Apple's device token is still in flight. Records every outcome
  /// in `users/{uid}/private/fcm_status` so a missing token is diagnosable
  /// instead of failing silently.
  Future<void> _fetchAndSaveToken(String uid, String via) async {
    final messaging = FirebaseMessaging.instance;
    try {
      final settings = await messaging.requestPermission(
          alert: true, badge: true, sound: true);
      await _saveStatus(uid, {
        'permission': settings.authorizationStatus.toString(),
        'via': via,
      });
    } catch (_) {}
    String? token;
    Object? lastError;
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        token = await messaging.getToken();
        if (token != null) break;
      } catch (e) {
        lastError = e;
      }
      if (attempt == 0) {
        // Does Apple even issue this phone a device token? This single
        // flag separates an Apple-side failure from a Firebase-side one.
        try {
          final apns = await messaging.getAPNSToken();
          await _saveStatus(uid, {'apnsTokenPresent': apns != null});
        } catch (_) {}
      }
      if (token == null) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    if (token != null) {
      await _saveToken(uid, token);
      await _saveStatus(uid, {'tokenSaved': true, 'via': via});
    } else if (lastError != null) {
      await _saveStatus(uid, {
        'tokenSaved': false,
        'getTokenError': lastError.toString(),
        'via': via,
      });
    } else {
      await _saveStatus(uid,
          {'tokenSaved': false, 'tokenNull': true, 'via': via});
    }
  }

  /// Diagnostic breadcrumb: records what registration actually did, so a
  /// missing token can be traced instead of failing silently.
  Future<void> _saveStatus(String uid, Map<String, dynamic> fields) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('private')
          .doc('fcm_status')
          .set(
              {...fields, 'updatedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('private')
          .doc('fcm')
          .set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': 'ios',
      }, SetOptions(merge: true));
    } catch (e) {
      await _saveStatus(
          uid, {'tokenSaved': false, 'saveError': e.toString()});
    }
  }
}

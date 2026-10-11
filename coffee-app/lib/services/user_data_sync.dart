import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tried_coffee.dart';

/// Best-effort Firestore sync for a signed-in user's personal data.
/// Every method swallows errors: offline must never break the app —
/// the in-memory state is always the source of truth for the UI.
class UserDataSync {
  UserDataSync(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _tastings(String uid) =>
      _db.collection('users').doc(uid).collection('tastings');

  DocumentReference<Map<String, dynamic>> _wishlist(String uid) =>
      _db.collection('users').doc(uid).collection('wishlist').doc('main');

  /// Loads remote tastings + wishlist into memory. Returns the pair so
  /// the caller can replace local state.
  Future<({List<TriedCoffee> tastings, Set<String> wishlist})> pull(
    String uid,
  ) async {
    try {
      final tastingsSnap = await _tastings(uid).get();
      final tastings = [
        for (final doc in tastingsSnap.docs)
          TriedCoffee.fromMap(doc.data(), doc.id),
      ];
      final wishlistSnap = await _wishlist(uid).get();
      final ids = wishlistSnap.data()?['beanIds'];
      final wishlist = {
        for (final id in (ids as List? ?? [])) id as String,
      };
      return (tastings: tastings, wishlist: wishlist);
    } catch (_) {
      return (tastings: <TriedCoffee>[], wishlist: <String>{});
    }
  }

  Future<void> pushTasting(String uid, TriedCoffee tasting) async {
    try {
      await _tastings(uid).doc(tasting.id).set(tasting.toMap());
    } catch (_) {/* offline: keep local only */}
  }

  Future<void> removeTasting(String uid, String tastingId) async {
    try {
      await _tastings(uid).doc(tastingId).delete();
    } catch (_) {/* offline: keep local only */}
  }

  Future<void> pushWishlist(String uid, Set<String> beanIds) async {
    try {
      await _wishlist(uid).set({
        'beanIds': beanIds.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {/* offline: keep local only */}
  }
}

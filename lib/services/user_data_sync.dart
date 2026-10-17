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

  DocumentReference<Map<String, dynamic>> _barcodeLinks(String uid) =>
      _db.collection('users').doc(uid).collection('barcodes').doc('main');

  /// Loads remote tastings + wishlist + barcode links into memory.
  /// Returns the triple so the caller can replace local state.
  Future<
      ({
        List<TriedCoffee> tastings,
        Set<String> wishlist,
        Map<String, String> barcodeLinks,
      })> pull(
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
      final linksSnap = await _barcodeLinks(uid).get();
      final rawLinks = linksSnap.data()?['links'];
      final barcodeLinks = {
        for (final e in (rawLinks as Map? ?? {}).entries)
          e.key as String: e.value as String,
      };
      return (
        tastings: tastings,
        wishlist: wishlist,
        barcodeLinks: barcodeLinks
      );
    } catch (_) {
      return (
        tastings: <TriedCoffee>[],
        wishlist: <String>{},
        barcodeLinks: <String, String>{},
      );
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

  /// barcode -> beanId links the user created by scanning bags.
  Future<void> pushBarcodeLinks(
    String uid,
    Map<String, String> links,
  ) async {
    try {
      await _barcodeLinks(uid).set({
        'links': links,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {/* offline: keep local only */}
  }
}

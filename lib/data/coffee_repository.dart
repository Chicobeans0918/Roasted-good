import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/coffee_bean.dart';
import '../models/coffee_shop.dart';

/// The catalogue served to the UI: beans + shops.
class Catalogue {
  const Catalogue({required this.beans, required this.shops});

  final List<CoffeeBean> beans;
  final List<CoffeeShop> shops;
}

/// Loads the catalogue. Tries Firestore when Firebase is configured,
/// and falls back to the bundled seed data on any failure (or when
/// Firebase is not configured). Offline never breaks the app.
Future<Catalogue> loadCatalogue({required bool firebaseEnabled}) async {
  if (firebaseEnabled) {
    try {
      final db = FirebaseFirestore.instance;
      final beansSnap =
          await db.collection('beans').orderBy('name').get();
      final shopsSnap =
          await db.collection('shops').orderBy('name').get();
      if (beansSnap.docs.isNotEmpty) {
        return Catalogue(
          beans: [
            for (final doc in beansSnap.docs)
              CoffeeBean.fromMap(doc.data(), doc.id),
          ],
          shops: [
            for (final doc in shopsSnap.docs)
              CoffeeShop.fromMap(doc.data(), doc.id),
          ],
        );
      }
      // Empty collections (e.g. not seeded yet): fall through to bundled.
    } catch (e) {
      debugPrint('Firestore catalogue load failed, using bundled: $e');
    }
  }
  return Catalogue(
    beans: SampleData.beans,
    shops: SampleData.shops,
  );
}

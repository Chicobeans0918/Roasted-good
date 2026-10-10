import 'package:flutter/material.dart';

import '../data/coffee_repository.dart';
import '../data/sample_data.dart';
import '../models/coffee_bean.dart';
import '../models/coffee_shop.dart';
import '../models/tried_coffee.dart';
import '../services/user_data_sync.dart';

/// App-wide state: catalogue, wishlist, tasting log, ratings, and
/// recommendation tuning. Provided above [MaterialApp] via [AppStateScope].
///
/// Personal data (tastings, wishlist) can optionally sync to Firestore for
/// a signed-in user via [attachRemote]; all sync is best-effort and the
/// in-memory state is always the source of truth for the UI.
class AppState extends ChangeNotifier {
  List<CoffeeBean> _beans = SampleData.beans;
  List<CoffeeShop> _shops = SampleData.shops;

  final Set<String> _wishlistBeanIds = {};
  final Map<String, double> _ratings = {};
  final List<TriedCoffee> _tried = [];

  String roastPreference = 'Medium';
  double surpriseMe = 0.5;
  bool decafOnly = false;

  /// Appearance: follows the system by default; the user can pin
  /// Light or Dark from Profile → Information.
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  String? _uid;
  UserDataSync? _sync;

  // ——— Catalogue ———

  List<CoffeeBean> get beans => List.unmodifiable(_beans);
  List<CoffeeShop> get shops => List.unmodifiable(_shops);

  CoffeeBean? beanFor(String id) {
    for (final bean in _beans) {
      if (bean.id == id) return bean;
    }
    return null;
  }

  /// Loads the catalogue from Firestore when available, otherwise keeps
  /// the bundled seed data.
  Future<void> refreshCatalogue({required bool firebaseEnabled}) async {
    final catalogue = await loadCatalogue(firebaseEnabled: firebaseEnabled);
    _beans = catalogue.beans;
    _shops = catalogue.shops;
    notifyListeners();
  }

  // ——— Remote sync ———

  /// Attaches Firestore sync for a signed-in user and pulls their
  /// remote tastings + wishlist into local state.
  Future<void> attachRemote({
    required String uid,
    required UserDataSync sync,
  }) async {
    _uid = uid;
    _sync = sync;
    final remote = await sync.pull(uid);
    if (remote.tastings.isNotEmpty) {
      _tried
        ..clear()
        ..addAll(remote.tastings);
      for (final t in remote.tastings) {
        _ratings[t.beanId] = t.rating;
      }
    }
    if (remote.wishlist.isNotEmpty) {
      _wishlistBeanIds
        ..clear()
        ..addAll(remote.wishlist);
    }
    notifyListeners();
  }

  void detachRemote() {
    _uid = null;
    _sync = null;
  }

  // ——— Wishlist ———

  Set<String> get wishlistBeanIds => Set.unmodifiable(_wishlistBeanIds);

  bool isWishlisted(String beanId) => _wishlistBeanIds.contains(beanId);

  List<CoffeeBean> get wishlistedBeans => [
        for (final bean in _beans)
          if (_wishlistBeanIds.contains(bean.id)) bean,
      ];

  void toggleWishlist(String beanId) {
    if (_wishlistBeanIds.contains(beanId)) {
      _wishlistBeanIds.remove(beanId);
    } else {
      _wishlistBeanIds.add(beanId);
    }
    notifyListeners();
    final uid = _uid;
    if (uid != null) {
      _sync?.pushWishlist(uid, _wishlistBeanIds);
    }
  }

  // ——— Ratings ———

  double? ratingFor(String beanId) => _ratings[beanId];

  void setRating(String beanId, double rating) {
    _ratings[beanId] = rating;
    notifyListeners();
  }

  // ——— Tasting log ———

  /// Coffees the user has logged as tried, newest last.
  List<TriedCoffee> get triedCoffees => List.unmodifiable(_tried);

  bool hasTried(String beanId) => _tried.any((t) => t.beanId == beanId);

  /// Tastings grouped by bean: one entry per bean with its tastings
  /// newest first. Beans ordered by most recent tasting.
  List<(CoffeeBean, List<TriedCoffee>)> get tastingsByBean {
    final byBean = <String, List<TriedCoffee>>{};
    for (final t in _tried) {
      byBean.putIfAbsent(t.beanId, () => []).add(t);
    }
    final entries = <(CoffeeBean, List<TriedCoffee>)>[];
    for (final entry in byBean.entries) {
      final bean = beanFor(entry.key);
      if (bean == null) continue;
      final tastings = entry.value
        ..sort((a, b) => b.date.compareTo(a.date));
      entries.add((bean, tastings));
    }
    entries.sort((a, b) => b.$2.first.date.compareTo(a.$2.first.date));
    return entries;
  }

  void logTasting(TriedCoffee tried) {
    _tried.add(tried);
    // Keep the per-bean rating in sync with the latest tasting.
    _ratings[tried.beanId] = tried.rating;
    notifyListeners();
    final uid = _uid;
    if (uid != null) {
      _sync?.pushTasting(uid, tried);
    }
  }

  void removeTasting(TriedCoffee tried) {
    _tried.remove(tried);
    notifyListeners();
    final uid = _uid;
    if (uid != null) {
      _sync?.removeTasting(uid, tried.id);
    }
  }

  // ——— Café Perks ———

  /// Check-ins needed at one shop to earn a free coffee.
  static const int perkThreshold = 10;

  final Map<String, int> _perkCheckIns = {};

  /// Check-in counts per shop id. Local-only state.
  Map<String, int> get perkCheckIns => Map.unmodifiable(_perkCheckIns);

  int perkVisitsFor(String shopId) => _perkCheckIns[shopId] ?? 0;

  bool perkRewardReady(String shopId) =>
      perkVisitsFor(shopId) >= perkThreshold;

  void checkInAtShop(String shopId) {
    _perkCheckIns.update(shopId, (v) => v + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void redeemPerk(String shopId) {
    _perkCheckIns.remove(shopId);
    notifyListeners();
  }

  // ——— Tuning ———

  void updateTuning({String? roast, double? surprise, bool? decaf}) {
    if (roast != null) roastPreference = roast;
    if (surprise != null) surpriseMe = surprise;
    if (decaf != null) decafOnly = decaf;
    notifyListeners();
  }

  /// Convenience accessor for [AppStateScope.of].
  static AppState of(BuildContext context) => AppStateScope.of(context);
}

/// Exposes [AppState] to the widget tree.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree.');
    return scope!.notifier!;
  }
}

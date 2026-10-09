import '../models/coffee_bean.dart';
import '../models/tried_coffee.dart';

/// Simple palate-based recommendations: beans the user hasn't tried yet,
/// scored by how closely they match the roast, origins, and tasting notes
/// of their highly-rated tastings (4+ stars).
List<CoffeeBean> recommendBeans({
  required List<CoffeeBean> beans,
  required List<TriedCoffee> tried,
  required Map<String, CoffeeBean> beanById,
  String roastPreference = 'Medium',
  double surpriseMe = 0.5,
  bool decafOnly = false,
  int limit = 8,
}) {
  var candidates = beans.where((b) {
    if (tried.any((t) => t.beanId == b.id)) return false;
    if (decafOnly && !b.decaf) return false;
    return true;
  }).toList();

  final liked = [
    for (final t in tried)
      if (t.rating >= 4 && t.liked) t,
  ];
  final likedBeans = [
    for (final t in liked)
      if (beanById[t.beanId] != null) beanById[t.beanId]!,
  ];

  int score(CoffeeBean bean) {
    var s = 0;
    for (final likedBean in likedBeans) {
      if (bean.roastLevel == likedBean.roastLevel) s += 2;
      if (bean.origin == likedBean.origin) s += 2;
      for (final note in bean.tastingNotes) {
        if (likedBean.tastingNotes.contains(note)) s += 1;
      }
    }
    if (bean.roastLevel == roastPreference) s += 1;
    if (bean.local) s += 1; // nudge local roasters
    return s;
  }

  candidates.sort((a, b) => score(b).compareTo(score(a)));

  // "Surprise me" mixes in lower-scored beans for variety.
  if (surpriseMe > 0.66 && candidates.length > limit) {
    final top = candidates.take(limit - 2).toList();
    final rest = candidates.skip(limit - 2).toList()..shuffle();
    candidates = [...top, ...rest.take(2)];
  }

  return candidates.take(limit).toList();
}

/// A one-line summary of the user's taste identity for headers.
String tasteIdentityLine(List<TriedCoffee> tried) {
  if (tried.isEmpty) return 'Log a tasting to discover your palate';
  final roasts = <String, int>{};
  for (final t in tried) {
    // Roast comes from the bean; counted via brew context here is
    // approximated by brew method family.
    roasts.update(t.brewMethod, (v) => v + 1, ifAbsent: () => 1);
  }
  final topBrew = roasts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;
  final likedCount = tried.where((t) => t.liked).length;
  final likeWord = likedCount == tried.length ? 'loves' : 'leans toward';
  return 'Coffee lover who $likeWord $topBrew brews';
}

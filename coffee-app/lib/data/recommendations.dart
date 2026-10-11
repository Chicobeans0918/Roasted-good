import 'dart:math';

import '../models/coffee_bean.dart';
import '../models/tried_coffee.dart';

/// A recommendation with its score and a one-line human explanation.
class ScoredRecommendation {
  const ScoredRecommendation({
    required this.bean,
    required this.score,
    required this.reason,
  });

  final CoffeeBean bean;
  final double score;
  final String reason;
}

/// Recommends untried beans based on the user's palate.
///
/// Scoring (tune-sheet params still apply):
/// - roast match with 4★+ tastings: +3 × tasting weight
/// - origin match with 4★+ tastings: +3 × tasting weight
/// - tasting-note overlap with 4★+ tastings: +2 × tasting weight per note
/// - local roaster: +2
/// - roast-preference slider: +roastBoost
/// Tasting weight: liked ×1.5, 5★ ×2, tasted in the last 30 days ×1.5.
/// Each pick carries a short explanation of the strongest signal.
List<ScoredRecommendation> recommendBeans({
  required List<CoffeeBean> beans,
  required List<TriedCoffee> tried,
  required Map<String, CoffeeBean> beanById,
  required String roastPreference,
  double roastBoost = 2.0,
  required double surpriseMe,
  required bool decafOnly,
  required int limit,
}) {
  final triedIds = tried.map((t) => t.beanId).toSet();
  var candidates =
      beans.where((b) => !triedIds.contains(b.id)).toList();
  if (decafOnly) {
    candidates = candidates.where((b) => b.decaf).toList();
  }

  final now = DateTime.now();
  final scored = <ScoredRecommendation>[];
  for (final bean in candidates) {
    var score = 0.0;
    final noteWeights = <String, double>{};
    final originWeights = <String, double>{};
    var roastSignal = 0.0;

    for (final t in tried) {
      final tasted = beanById[t.beanId];
      if (tasted == null || t.rating < 4) continue;

      // How much this tasting counts.
      var w = 1.0;
      if (t.liked) w *= 1.5;
      if (t.rating >= 5) w *= 2.0;
      if (now.difference(t.date).inDays <= 30) w *= 1.5;

      if (tasted.roastLevel == bean.roastLevel) {
        score += 3 * w;
        roastSignal += 3 * w;
      }
      if (tasted.origin == bean.origin) {
        score += 3 * w;
        originWeights.update(
          bean.origin,
          (v) => v + 3 * w,
          ifAbsent: () => 3 * w,
        );
      }
      for (final note in bean.tastingNotes) {
        if (tasted.tastingNotes.contains(note)) {
          score += 2 * w;
          noteWeights.update(
            note,
            (v) => v + 2 * w,
            ifAbsent: () => 2 * w,
          );
        }
      }
    }

    if (bean.local) score += 2;
    if (bean.roastLevel == roastPreference) score += roastBoost;

    String? topKey(Map<String, double> weights) {
      if (weights.isEmpty) return null;
      return weights.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final topNote = topKey(noteWeights);
    final topOrigin = topKey(originWeights);
    final String reason;
    if (topNote != null && topOrigin != null) {
      reason =
          'Because you loved ${topNote.toLowerCase()} coffees from $topOrigin';
    } else if (topNote != null) {
      reason = 'Because you loved ${topNote.toLowerCase()} coffees';
    } else if (topOrigin != null) {
      reason = 'Because you loved coffees from $topOrigin';
    } else if (roastSignal > 0) {
      reason =
          'Because you keep reaching for ${bean.roastLevel.toLowerCase()} roasts';
    } else if (bean.local) {
      reason = "From a local roaster you'll love";
    } else {
      reason = 'Matches your taste profile';
    }

    scored.add(
      ScoredRecommendation(bean: bean, score: score, reason: reason),
    );
  }

  scored.sort((a, b) => b.score.compareTo(a.score));
  final top = scored.take(limit).toList();
  if (surpriseMe > 0) {
    final random = Random();
    if (random.nextDouble() < surpriseMe) {
      top.shuffle(random);
    }
  }
  return top;
}

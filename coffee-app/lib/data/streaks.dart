import '../models/tried_coffee.dart';

/// Pure streak helpers computed from tasting dates.
/// A "day" is a calendar day in local time; multiple tastings on the
/// same day count once.

/// Day-truncated dates that have at least one tasting.
Set<DateTime> tastingDays(List<TriedCoffee> tried) {
  return {
    for (final t in tried)
      DateTime(t.date.year, t.date.month, t.date.day),
  };
}

/// Consecutive days with at least one tasting, ending today or yesterday.
/// The streak stays "alive" if the user logged today or yesterday —
/// missing a full day breaks it.
int currentStreak(List<TriedCoffee> tried, {DateTime? now}) {
  final days = tastingDays(tried);
  if (days.isEmpty) return 0;
  final ref = now ?? DateTime.now();
  var cursor = DateTime(ref.year, ref.month, ref.day);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Longest run of consecutive tasting days, ever.
int longestStreak(List<TriedCoffee> tried) {
  final days = tastingDays(tried).toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? prev;
  for (final d in days) {
    if (prev != null &&
        d.difference(prev) == const Duration(days: 1)) {
      run++;
    } else {
      run = 1;
    }
    if (run > best) best = run;
    prev = d;
  }
  return best;
}

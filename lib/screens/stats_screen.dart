import 'package:flutter/material.dart';

import '../models/tried_coffee.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bean_detail_sheet.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/rating_stars.dart';

/// Stats: the coffee journey in numbers, plus a Hall of fame of
/// top-rated beans.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  /// Consecutive days with at least one tasting, ending today or yesterday.
  int _streak(List<TriedCoffee> tried) {
    if (tried.isEmpty) return 0;
    final days = {
      for (final t in tried)
        DateTime(t.date.year, t.date.month, t.date.day),
    };
    var cursor = DateTime.now();
    final today = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(today)) {
      cursor = today.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(
        DateTime(cursor.year, cursor.month, cursor.day))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<(String, int)> _topOrigins(AppState state, List<TriedCoffee> tried) {
    final counts = <String, int>{};
    for (final t in tried) {
      final bean = state.beanFor(t.beanId);
      if (bean == null) continue;
      counts.update(bean.origin, (v) => v + 1, ifAbsent: () => 1);
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in sorted.take(3)) (e.key, e.value)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final tried = state.triedCoffees;
    final beansTried = {
      for (final t in tried) t.beanId,
    }.length;
    final origins = {
      for (final t in tried)
        if (state.beanFor(t.beanId) != null)
          state.beanFor(t.beanId)!.origin,
    }.length;
    final avg = tried.isEmpty
        ? '–'
        : (tried.map((t) => t.rating).reduce((a, b) => a + b) /
                tried.length)
            .toStringAsFixed(1);
    final likedPct = tried.isEmpty
        ? '–'
        : '${(tried.where((t) => t.liked).length / tried.length * 100).round()}%';
    final topOrigins = _topOrigins(state, tried);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
          children: [
            Text(
              'Coffee stats',
              style: AppType.serifStyle(size: 34, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Your journey in numbers',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                StatTile(
                  icon: Icons.coffee_outlined,
                  value: '${tried.length}',
                  label: 'TASTINGS',
                ),
                const SizedBox(width: 16),
                StatTile(
                  icon: Icons.spa_outlined,
                  value: '$beansTried',
                  label: 'BEANS',
                ),
                const SizedBox(width: 16),
                StatTile(
                  icon: Icons.public_outlined,
                  value: '$origins',
                  label: 'ORIGINS',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                StatTile(
                  icon: Icons.star_border,
                  value: avg,
                  label: 'AVG RATING',
                  iconColor: AppColors.starOrange,
                ),
                const SizedBox(width: 16),
                StatTile(
                  icon: Icons.thumb_up_outlined,
                  value: likedPct,
                  label: 'LIKED',
                ),
                const SizedBox(width: 16),
                StatTile(
                  icon: Icons.local_fire_department_outlined,
                  value: '${_streak(tried)}',
                  label: 'DAY STREAK',
                ),
              ],
            ),
            const SizedBox(height: 44),
            const SectionTitle(
              icon: Icons.public_outlined,
              text: 'Top origins',
            ),
            const SizedBox(height: 16),
            if (topOrigins.isEmpty)
              const EmptyCard(
                text: 'Log tastings to see your top origins',
              )
            else
              FlavourBars(
                flavours: [
                  for (final (name, count) in topOrigins)
                    (
                      name,
                      count / topOrigins.first.$2,
                    ),
                ],
              ),
            const SizedBox(height: 44),
            const SectionTitle(
              icon: Icons.emoji_events_outlined,
              text: 'Hall of fame',
            ),
            const SizedBox(height: 6),
            Text(
              'Your highest-rated beans',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _HallOfFame(state: state, tried: tried),
          ],
        ),
      ),
    );
  }
}

/// Beans ranked by their best tasting rating; ties break newest first.
class _HallOfFame extends StatelessWidget {
  const _HallOfFame({required this.state, required this.tried});

  final AppState state;
  final List<TriedCoffee> tried;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = <String, TriedCoffee>{};
    for (final t in tried) {
      final current = best[t.beanId];
      if (current == null ||
          t.rating > current.rating ||
          (t.rating == current.rating && t.date.isAfter(current.date))) {
        best[t.beanId] = t;
      }
    }
    final ranked = best.values.toList()
      ..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        if (byRating != 0) return byRating;
        return b.date.compareTo(a.date);
      });

    if (ranked.isEmpty) {
      return const EmptyCard(
        text: 'Rate some beans to build your hall of fame',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < ranked.length && i < 10; i++)
          Builder(builder: (context) {
            final t = ranked[i];
            final bean = state.beanFor(t.beanId);
            if (bean == null) return const SizedBox.shrink();
            return InkWell(
              onTap: () => showBeanDetailSheet(context, bean),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${i + 1}',
                        style: AppType.serifStyle(
                          size: 22,
                          weight: FontWeight.w600,
                          color: i == 0
                              ? AppColors.starOrange
                              : AppColors.muted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bean.name,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${bean.origin} · ${t.brewMethod}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    RatingStars(rating: t.rating, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      t.rating.toStringAsFixed(1).replaceAll('.0', ''),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

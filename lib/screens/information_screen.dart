import 'package:flutter/material.dart';

import '../data/recommendations.dart';
import '../models/tried_coffee.dart';
import '../state/app_state.dart';
import '../widgets/profile_widgets.dart';

/// Profile → Information: taste identity, flavour affinities, rating style.
class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  List<(String, double)> _flavours(
      AppState state, List<TriedCoffee> tried) {
    final counts = <String, int>{};
    var total = 0;
    for (final t in tried) {
      if (t.rating < 4) continue;
      final bean = state.beanFor(t.beanId);
      if (bean == null) continue;
      for (final note in bean.tastingNotes) {
        counts.update(note, (v) => v + 1, ifAbsent: () => 1);
        total++;
      }
    }
    if (total == 0) return [];
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;
    return [
      for (final e in sorted.take(5)) (e.key, e.value / max),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final tried = state.triedCoffees;
    final beanCount = {
      for (final t in tried) t.beanId,
    }.length;
    final origins = {
      for (final t in tried)
        if (state.beanFor(t.beanId) != null)
          state.beanFor(t.beanId)!.origin,
    }.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Information')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        children: [
          TasteIdentityCard(
            headline: tried.isEmpty
                ? 'Your palate is a blank slate — for now'
                : tasteIdentityLine(tried),
            subline: tried.isEmpty
                ? 'Log your first tasting to build your taste identity'
                : "Based on $beanCount coffees you've logged across "
                    "$origins origin${origins == 1 ? '' : 's'}",
          ),
          const SizedBox(height: 48),
          const SectionTitle(
            icon: Icons.trending_up_outlined,
            text: 'Flavours You Love',
          ),
          const SizedBox(height: 16),
          FlavourBars(flavours: _flavours(state, tried)),
          const SizedBox(height: 48),
          const SectionTitle(
            icon: Icons.star_border,
            text: 'Your Rating Style',
          ),
          const SizedBox(height: 16),
          RatingStyleCard(tried: tried),
          const SizedBox(height: 8),
          Text(
            'Member since October 2026',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

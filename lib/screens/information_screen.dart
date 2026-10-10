import 'package:flutter/material.dart';

import '../models/tried_coffee.dart';
import '../screens/feedback_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
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
    final p = context.palette;
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
                : tasteIdentityLine(tried, state.beanFor),
            subline: tried.isEmpty
                ? 'Log your first tasting to build your taste identity'
                : "Based on $beanCount coffees you've logged across "
                    "$origins origin${origins == 1 ? '' : 's'}",
          ),
          const SizedBox(height: 48),
          const SectionTitle(
            icon: Icons.brightness_6_outlined,
            text: 'Appearance',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: p.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THEME',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined, size: 18),
                      label: Text('Light'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined, size: 18),
                      label: Text('Dark'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined, size: 18),
                      label: Text('System'),
                    ),
                  ],
                  selected: {state.themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      state.setThemeMode(selection.first),
                ),
              ],
            ),
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
          const SizedBox(height: 48),
          const SectionTitle(
            icon: Icons.feedback_outlined,
            text: 'Feedback',
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FeedbackScreen(),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: p.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send feedback',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Testing Roasted? Tell us what you think',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: p.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

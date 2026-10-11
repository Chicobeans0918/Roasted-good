import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/profile_widgets.dart';

/// Profile → Coffees tried: each bean once, with all of its tastings
/// nested underneath, newest first.
class TriedScreen extends StatelessWidget {
  const TriedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final grouped = state.tastingsByBean;

    final topPick = state.triedCoffees.isEmpty
        ? null
        : state.triedCoffees
            .reduce((a, b) => a.rating >= b.rating ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Coffees tried')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        children: [
          const SectionTitle(
            icon: Icons.emoji_events_outlined,
            text: 'Your #1 Pick',
          ),
          const SizedBox(height: 16),
          if (topPick == null ||
              state.beanFor(topPick.beanId) == null)
            const EmptyCard(text: 'No tastings logged yet')
          else
            PickCard(
              bean: state.beanFor(topPick.beanId)!,
              rating: topPick.rating,
            ),
          const SizedBox(height: 40),
          Text(
            '${grouped.length} BEAN${grouped.length == 1 ? '' : 'S'} TRIED',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          if (grouped.isEmpty)
            const EmptyCard(
              text: 'Log a tasting from any bean to build your history',
            )
          else
            for (final (bean, tastings) in grouped)
              GroupedTastingCard(bean: bean, tastings: tastings),
        ],
      ),
    );
  }
}

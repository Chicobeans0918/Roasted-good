import 'package:flutter/material.dart';

import '../screens/perks_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Compact Café Perks summary for the Profile screen — one slim row.
/// Tapping opens the full [PerksScreen] with every partner shop.
class PerksSection extends StatelessWidget {
  const PerksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);

    var checkIns = 0;
    var rewards = 0;
    for (final shop in state.shops) {
      checkIns += state.perkVisitsFor(shop.id);
      if (state.perkRewardReady(shop.id)) rewards++;
    }

    final subtitle = rewards > 0
        ? '$checkIns check-ins · $rewards free ${rewards == 1 ? 'coffee' : 'coffees'} ready'
        : checkIns > 0
            ? '$checkIns check-ins so far'
            : 'Check in at partner cafés, earn free coffee';

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PerksScreen(),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: p.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 28,
              color: p.ink,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Café Perks',
                    style: AppType.serifFor(
                      context,
                      size: 19,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: p.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (rewards > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$rewards',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.onAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: p.muted,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/coffee_shop.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Full Café Perks screen: check in at partner shops; every
/// [AppState.perkThreshold] visits earns a free coffee. Local-only state.
class PerksScreen extends StatelessWidget {
  const PerksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Café Perks')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          children: [
            Text(
              'Check in at partner cafés — '
              '${AppState.perkThreshold} visits earns a free coffee',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            for (final shop in state.shops) _PerkShopCard(shop: shop),
          ],
        ),
      ),
    );
  }
}

class _PerkShopCard extends StatelessWidget {
  const _PerkShopCard({required this.shop});

  final CoffeeShop shop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final visits = state.perkVisitsFor(shop.id);
    final ready = state.perkRewardReady(shop.id);
    const threshold = AppState.perkThreshold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shop.address,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (ready)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'FREE COFFEE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: p.onAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (visits / threshold).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: p.surfaceVariant.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(p.sage),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ready ? 'Reward earned' : '$visits of $threshold visits',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              if (ready)
                ElevatedButton(
                  onPressed: () {
                    state.redeemPerk(shop.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Enjoy your free coffee at ${shop.name}! '
                          'Show this screen to your barista.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Redeem'),
                )
              else
                OutlinedButton(
                  onPressed: () {
                    state.checkInAtShop(shop.id);
                    final n = state.perkVisitsFor(shop.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Checked in at ${shop.name} — $n of $threshold',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Check in'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data/streaks.dart';
import '../screens/information_screen.dart';
import '../screens/tried_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/wrapped_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/perks_section.dart';
import '../widgets/profile_widgets.dart';

/// Profile, reworked for calm: a name header with a one-line summary,
/// then grouped slim rows — Your coffee, Rewards, Settings. Every row
/// shares the same visual treatment; nothing shouts.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final tried = state.triedCoffees;
    final streak = currentStreak(tried);

    final summaryParts = <String>[
      tasteIdentityLine(tried, state.beanFor),
      '${tried.length} tasting${tried.length == 1 ? '' : 's'}',
    ];
    if (streak > 0) summaryParts.add('$streak-day streak');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
          children: [
            Text(
              state.userName.isEmpty ? 'Coffee lover' : state.userName,
              style: AppType.serifFor(
                context,
                size: 38,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summaryParts.join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.muted,
              ),
            ),
            const SizedBox(height: 36),
            const _GroupLabel('Your coffee'),
            const SizedBox(height: 12),
            _ProfileRow(
              icon: Icons.coffee_outlined,
              label: 'Coffees tried',
              screen: const TriedScreen(),
            ),
            const SizedBox(height: 12),
            _ProfileRow(
              icon: Icons.favorite_border,
              label: 'Wishlist',
              screen: const WishlistScreen(),
            ),
            const SizedBox(height: 28),
            const _GroupLabel('Rewards'),
            const SizedBox(height: 12),
            const PerksSection(),
            const SizedBox(height: 12),
            const _WrappedRow(),
            const SizedBox(height: 28),
            const _GroupLabel('Settings'),
            const SizedBox(height: 12),
            _ProfileRow(
              icon: Icons.person_outline,
              label: 'Information',
              screen: const InformationScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small-caps group label, e.g. "Your coffee".
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: p.muted,
        letterSpacing: 1.6,
      ),
    );
  }
}

/// Slim tappable row opening a profile section screen.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final String label;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);

    String? badge;
    if (screen is TriedScreen) {
      final n = state.tastingsByBean.length;
      if (n > 0) badge = '$n';
    } else if (screen is WishlistScreen) {
      final n = state.wishlistBeanIds.length;
      if (n > 0) badge = '$n';
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
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
            Icon(icon, size: 26, color: p.ink),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppType.serifFor(
                  context,
                  size: 19,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
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
                  badge,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.onAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Icon(Icons.chevron_right, color: p.muted),
          ],
        ),
      ),
    );
  }
}

/// Slim "Year in Coffee" row — the old full-width banner, quieted down.
class _WrappedRow extends StatelessWidget {
  const _WrappedRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final year = DateTime.now().year;
    final locked = !isWrappedUnlocked(month: DateTime.now().month);

    final subtitle = locked
        ? 'Unlocks in December'
        : state.triedCoffees.isEmpty
            ? 'Log tastings to unlock it'
            : '$year · ${state.triedCoffees.length} tasting'
                '${state.triedCoffees.length == 1 ? '' : 's'}';

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WrappedScreen(),
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
              locked
                  ? Icons.lock_outline
                  : Icons.auto_awesome_outlined,
              size: 26,
              color: p.ink,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year in Coffee',
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
            Icon(Icons.chevron_right, color: p.muted),
          ],
        ),
      ),
    );
  }
}

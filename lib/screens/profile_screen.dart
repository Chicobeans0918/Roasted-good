import 'package:flutter/material.dart';

import '../data/streaks.dart';
import '../screens/information_screen.dart';
import '../screens/recommended_screen.dart';
import '../screens/tried_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/wrapped_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/perks_section.dart';
import '../widgets/profile_widgets.dart';

/// Profile: serif name header, taste summary, key stats, and a 2x2 grid
/// of separate section cards — Information, Coffees tried, Recommended,
/// Wishlist — each opening its own screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final tried = state.triedCoffees;
    final origins = {
      for (final t in tried)
        if (state.beanFor(t.beanId) != null)
          state.beanFor(t.beanId)!.origin,
    }.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
          children: [
            // Header: the user's name.
            Text(
              'Marc-André',
              style: AppType.serifFor(
                context,
                size: 38,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tasteIdentityLine(tried, state.beanFor),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: p.muted,
              ),
            ),
            const SizedBox(height: 28),
            // Key stats.
            Row(
              children: [
                StatTile(
                  icon: Icons.coffee_outlined,
                  value: '${tried.length}',
                  label: 'TRIED',
                ),
                const SizedBox(width: 16),
                StatTile(
                  icon: Icons.public_outlined,
                  value: '$origins',
                  label: 'ORIGINS',
                ),
              ],
            ),
            const SizedBox(height: 44),
            // Café Perks: check-ins toward a free coffee.
            const PerksSection(),
            const SizedBox(height: 44),
            // Year in Coffee.
            _WrappedBanner(),
            const SizedBox(height: 44),
            // 2x2 grid of separate section cards.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: const [
                _SectionCard(
                  icon: Icons.person_outline,
                  label: 'Information',
                  screen: InformationScreen(),
                ),
                _SectionCard(
                  icon: Icons.coffee_outlined,
                  label: 'Coffees tried',
                  screen: TriedScreen(),
                ),
                _SectionCard(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Recommended',
                  screen: RecommendedScreen(),
                ),
                _SectionCard(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  screen: WishlistScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width banner opening the Year in Coffee story.
class _WrappedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final year = DateTime.now().year;
    final streak = currentStreak(state.triedCoffees);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WrappedScreen(),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: p.identityCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR $year IN COFFEE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          p.onIdentityCard.withValues(alpha: 0.75),
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'See your Wrapped',
                    style: AppType.serifStyle(
                      size: 24,
                      weight: FontWeight.w500,
                      color: p.onIdentityCard,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.triedCoffees.isEmpty
                        ? 'Log tastings to unlock it'
                        : '${state.triedCoffees.length} tastings'
                            '${streak > 0 ? ' · $streak-day streak' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          p.onIdentityCard.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.auto_awesome_outlined,
              size: 32,
              color: p.onIdentityCard.withValues(alpha: 0.85),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {  const _SectionCard({
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
        decoration: BoxDecoration(
          border: Border.all(color: p.line),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30, color: p.ink),
                if (badge != null)
                  Container(
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
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              label,
              style: AppType.serifFor(context, size: 19, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

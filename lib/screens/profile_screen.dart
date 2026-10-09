import 'package:flutter/material.dart';

import '../data/recommendations.dart';
import '../screens/information_screen.dart';
import '../screens/recommended_screen.dart';
import '../screens/tried_screen.dart';
import '../screens/wishlist_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_widgets.dart';

/// Profile: serif name header, taste summary, key stats, and a 2x2 grid
/// of separate section cards — Information, Coffees tried, Recommended,
/// Wishlist — each opening its own screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final tried = state.triedCoffees;
    final origins = {
      for (final t in tried)
        if (state.beanFor(t.beanId) != null)
          state.beanFor(t.beanId)!.origin,
    }.length;
    final avgScore = tried.isEmpty
        ? '–'
        : (tried.map((t) => t.rating).reduce((a, b) => a + b) /
                tried.length)
            .toStringAsFixed(1);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
          children: [
            // Header: the user's name.
            Text(
              'Marc-André',
              style: AppType.serifStyle(
                size: 38,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tasteIdentityLine(tried),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
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
                const SizedBox(width: 16),
                StatTile(
                  icon: Icons.star_border,
                  value: avgScore,
                  label: 'AVG SCORE',
                  iconColor: AppColors.starOrange,
                ),
              ],
            ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
          border: Border.all(color: AppColors.line),
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
                Icon(icon, size: 30, color: AppColors.ink),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.espresso,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              label,
              style: AppType.serifStyle(size: 19, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

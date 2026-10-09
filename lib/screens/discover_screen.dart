import 'package:flutter/material.dart';

import '../data/recommendations.dart';
import '../models/coffee_bean.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_detail_sheet.dart';

/// Home: a welcoming time-aware greeting, a Discoveries section,
/// and recommendations based on taste.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  List<CoffeeBean> _discoveries(AppState state) {
    // Beans not yet tried, local roasters first.
    final notTried = state.beans.where((b) => !state.hasTried(b.id)).toList();
    notTried.sort((a, b) {
      if (a.local != b.local) return a.local ? -1 : 1;
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    });
    return notTried.take(4).toList();
  }

  List<CoffeeBean> _recommended(AppState state) {
    final beanById = {for (final b in state.beans) b.id: b};
    return recommendBeans(
      beans: state.beans,
      tried: state.triedCoffees,
      beanById: beanById,
      roastPreference: state.roastPreference,
      surpriseMe: state.surpriseMe,
      decafOnly: state.decafOnly,
      limit: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final discoveries = _discoveries(state);
    final recommended = _recommended(state);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 64),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_greeting, Marc-André',
                    textAlign: TextAlign.center,
                    style: AppType.serifStyle(
                      size: 34,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'What are you brewing today?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            _Section(
              title: 'Discoveries',
              subtitle: 'New beans worth exploring',
              beans: discoveries,
            ),
            const SizedBox(height: 56),
            _Section(
              title: 'Recommended for you',
              subtitle: state.triedCoffees.isEmpty
                  ? 'Log a tasting to personalize these picks'
                  : 'Based on the coffees you have rated',
              beans: recommended,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.beans,
  });

  final String title;
  final String subtitle;
  final List<CoffeeBean> beans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (beans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Nothing here yet — check the catalogue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: beans.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final bean = beans[index];
                return SizedBox(
                  width: 172,
                  child: BeanGridCard(
                    bean: bean,
                    onDetails: () => showBeanDetailSheet(context, bean),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

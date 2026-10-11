import 'package:flutter/material.dart';

import '../data/recommendations.dart';
import '../state/app_state.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_detail_sheet.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/tuning_sheet.dart';

/// Profile → Recommended: beans picked for the user's palate,
/// with a tune-recommendations sheet.
class RecommendedScreen extends StatelessWidget {
  const RecommendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final beanById = {for (final b in state.beans) b.id: b};
    final recommended = recommendBeans(
      beans: state.beans,
      tried: state.triedCoffees,
      beanById: beanById,
      roastPreference: state.roastPreference,
      surpriseMe: state.surpriseMe,
      decafOnly: state.decafOnly,
      limit: 8,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Recommended')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        children: [
          Text(
            'Picked for your palate',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            state.triedCoffees.isEmpty
                ? 'Log a few tastings and these picks will sharpen'
                : 'Based on the coffees you have rated',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (recommended.isEmpty)
            const EmptyCard(
              text: 'You have tried everything — impressive!',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.5,
              ),
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final rec = recommended[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BeanGridCard(
                        bean: rec.bean,
                        onDetails: () =>
                            showBeanDetailSheet(context, rec.bean),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rec.reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showTuningSheet(context),
              icon: const Icon(Icons.tune, size: 18),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Tune recommendations'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

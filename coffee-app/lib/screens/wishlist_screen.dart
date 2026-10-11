import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_detail_sheet.dart';
import '../widgets/profile_widgets.dart';

/// Profile → Wishlist: beans saved to try later.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final beans = state.wishlistedBeans;

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: beans.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              children: const [
                EmptyCard(
                  text:
                      'Nothing saved yet — tap the heart on any bean to add it here',
                ),
              ],
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.56,
              ),
              itemCount: beans.length,
              itemBuilder: (context, index) {
                final bean = beans[index];
                return BeanGridCard(
                  bean: bean,
                  onDetails: () => showBeanDetailSheet(context, bean),
                );
              },
            ),
    );
  }
}

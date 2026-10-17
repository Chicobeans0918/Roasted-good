import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/sample_data.dart';
import '../models/coffee_bean.dart';
import '../models/coffee_shop.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'bean_card.dart';
import 'rating_stars.dart';
import 'tasting_form_sheet.dart';

/// Matches a bean's "where to buy" label against the shop directory
/// (case-insensitive). Returns null when there is no physical shop —
/// e.g. an online-only roaster like edika.com.
CoffeeShop? shopForWhereToBuy(List<CoffeeShop> shops, String? whereToBuy) {
  final label = whereToBuy?.trim();
  if (label == null || label.isEmpty) return null;
  for (final shop in shops) {
    if (shop.name.toLowerCase() == label.toLowerCase()) return shop;
  }
  return null;
}

/// Shows the shared bean detail bottom sheet.
Future<void> showBeanDetailSheet(BuildContext context, CoffeeBean bean) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BeanDetailSheet(
      bean: bean,
      onLogTasting: () {
        // Close this sheet, then open the tasting form on top.
        Navigator.of(context).pop();
        showTastingFormSheet(context, bean);
      },
    ),
  );
}

class BeanDetailSheet extends StatelessWidget {
  const BeanDetailSheet({
    super.key,
    required this.bean,
    required this.onLogTasting,
  });

  final CoffeeBean bean;
  final VoidCallback onLogTasting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final recipe =
        SampleData.recipes.where((r) => r.beanId == bean.id).firstOrNull;
    final wishlisted = state.isWishlisted(bean.id);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                BeanThumb(bean: bean, size: 72, borderRadius: 16),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bean.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${bean.origin} · ${bean.roastLevel} roast',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (bean.rating != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            RatingStars(rating: bean.rating!, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              bean.rating!.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('TASTING NOTES', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              bean.tastingNotes.join(' · '),
              style: theme.textTheme.bodyLarge,
            ),
            if (bean.whereToBuy != null) ...[
              const SizedBox(height: 24),
              Text('WHERE TO BUY', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              _WhereToBuyRow(bean: bean),
            ],
            const SizedBox(height: 24),
            if (recipe != null) ...[
              const SizedBox(height: 24),
              Text('BREW IT', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              Text(
                '${recipe.method} · ${recipe.ratio} · ${recipe.grind}\n'
                '${recipe.temperatureC} · ${recipe.brewTime}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogTasting,
                icon: const Icon(Icons.coffee_outlined, size: 18),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Log a tasting'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => state.toggleWishlist(bean.id),
                icon: Icon(
                  wishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    wishlisted ? 'Saved to wishlist' : 'Add to wishlist',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "where to buy" row: tappable when it leads somewhere.
/// A directory shop jumps to the Map tab focused on that shop;
/// a bare domain (e.g. edika.com) opens the roaster's site.
class _WhereToBuyRow extends StatelessWidget {
  const _WhereToBuyRow({required this.bean});

  final CoffeeBean bean;

  bool get _looksLikeUrl {
    final label = bean.whereToBuy ?? '';
    return label.contains('.') && !label.contains(' ');
  }

  Future<void> _onTap(BuildContext context) async {
    final state = AppState.of(context);
    final shop = shopForWhereToBuy(state.shops, bean.whereToBuy);
    if (shop != null) {
      // Close the sheet, then jump to the map focused on the shop.
      Navigator.of(context).pop();
      state.focusShopOnMap(shop.id);
      return;
    }
    if (_looksLikeUrl) {
      final raw = bean.whereToBuy!.trim();
      final uri = Uri.parse(
        raw.startsWith(RegExp('https?://')) ? raw : 'https://$raw',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final shop = shopForWhereToBuy(state.shops, bean.whereToBuy);
    final tappable = shop != null || _looksLikeUrl;

    final row = Row(
      children: [
        Icon(
          shop != null ? Icons.store_outlined : Icons.language_outlined,
          size: 18,
          color: p.muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            bean.whereToBuy!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tappable ? p.ink : null,
              decoration: tappable ? TextDecoration.underline : null,
              decorationColor: p.muted,
            ),
          ),
        ),
        if (tappable)
          Icon(
            shop != null ? Icons.map_outlined : Icons.open_in_new,
            size: 18,
            color: p.muted,
          ),
      ],
    );

    if (!tappable) return row;
    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      ),
    );
  }
}

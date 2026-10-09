import 'package:flutter/material.dart';

import '../models/coffee_bean.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'tasting_form_sheet.dart';

/// Roast-level tint used for bean image placeholders.
Color roastColor(String roastLevel) {
  switch (roastLevel.toLowerCase()) {
    case 'light':
      return const Color(0xFFC89B6A);
    case 'dark':
      return const Color(0xFF5B3A24);
    case 'medium':
    default:
      return const Color(0xFF967259);
  }
}

/// Rich brown gradient standing in for bean photography, tuned per roast.
List<Color> roastGradient(String roastLevel) {
  switch (roastLevel.toLowerCase()) {
    case 'light':
      return const [Color(0xFFD9AE77), Color(0xFF9C6B3F)];
    case 'dark':
      return const [Color(0xFF6B4226), Color(0xFF2E1C10)];
    case 'medium':
    default:
      return const [Color(0xFFA87C4F), Color(0xFF5B3A24)];
  }
}

/// Bean photo placeholder — a rich brown gradient tile.
class BeanThumb extends StatelessWidget {
  const BeanThumb({
    super.key,
    required this.bean,
    this.size = 52,
    this.borderRadius = 12,
  });

  final CoffeeBean bean;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final gradient = roastGradient(bean.roastLevel);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Catalogue-style bean card: photo tile, serif name, origin, roast,
/// orange star rating, "Details" outlined button + espresso "+" button.
/// Sized by its parent (grid cell or fixed-width carousel slot).
class BeanGridCard extends StatelessWidget {
  const BeanGridCard({
    super.key,
    required this.bean,
    required this.onDetails,
    this.onMarkTried,
  });

  final CoffeeBean bean;
  final VoidCallback onDetails;

  /// Opens the tasting-log form. Defaults to the shared tasting sheet.
  final VoidCallback? onMarkTried;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final wishlisted = state.isWishlisted(bean.id);
    final tried = state.hasTried(bean.id);
    final gradient = roastGradient(bean.roastLevel);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      // The card always fills its parent's height exactly (grid cell or
      // fixed-height carousel slot): the photo flexes, the text section
      // keeps its natural size. This can never overflow.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo tile with an optional "tried" badge.
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                  ),
                ),
                if (tried)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.espresso,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 13,
                            color: AppColors.cream,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'TRIED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.cream,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bean.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${bean.origin} · ${bean.roastLevel}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (bean.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bean.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_border,
                      size: 20,
                      color: AppColors.starOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (bean.rating ?? 0) > 0
                          ? bean.rating!.toStringAsFixed(1).replaceAll('.0', '')
                          : '–',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (bean.local) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDetails,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Details',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: onMarkTried ??
                            () => showTastingFormSheet(context, bean),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Mark as tried',
                          child: Icon(
                            Icons.coffee_outlined,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => state.toggleWishlist(bean.id),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Tooltip(
                          message: wishlisted
                              ? 'Remove from wishlist'
                              : 'Add to wishlist',
                          child: Icon(
                            wishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: wishlisted
                                ? AppColors.espresso
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal vertical bean row — transparent with a hairline divider.
/// Used for history lists.
class BeanRow extends StatelessWidget {
  const BeanRow({
    super.key,
    required this.bean,
    required this.onTap,
    this.trailing,
  });

  final CoffeeBean bean;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.line),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bean.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${bean.origin} · ${bean.roastLevel} roast',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

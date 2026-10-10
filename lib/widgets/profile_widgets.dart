import 'package:flutter/material.dart';

import '../models/coffee_bean.dart';
import '../models/tried_coffee.dart';
import '../theme/app_theme.dart';
import '../widgets/bean_detail_sheet.dart';
import '../widgets/rating_stars.dart';

/// Shared building blocks for the profile area screens.

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: p.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: iconColor ?? p.ink),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppType.serifFor(context, size: 26, weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Row(
      children: [
        Icon(icon, size: 22, color: p.ink),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }
}

/// Dark espresso taste identity card.
class TasteIdentityCard extends StatelessWidget {
  const TasteIdentityCard({
    super.key,
    required this.headline,
    required this.subline,
  });

  final String headline;
  final String subline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: p.identityCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: p.onIdentityCard.withValues(alpha: 0.75),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR TASTE IDENTITY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: p.onIdentityCard.withValues(alpha: 0.75),
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            style: AppType.serifStyle(
              size: 24,
              weight: FontWeight.w500,
              color: p.onIdentityCard,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: p.onIdentityCard.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flavour affinity bars in soft sage, derived from tasting notes of
/// highly-rated tastings.
class FlavourBars extends StatelessWidget {
  const FlavourBars({super.key, required this.flavours});

  /// (flavour, affinity 0–1) pairs.
  final List<(String, double)> flavours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    if (flavours.isEmpty) {
      return Text(
        'Log tastings to reveal your flavour affinities.',
        style: theme.textTheme.bodyMedium?.copyWith(color: p.muted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, value) in flavours) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: theme.textTheme.bodyMedium),
              Text(
                '${(value * 100).round()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: p.surfaceVariant.withValues(alpha: 0.4),
              valueColor:
                  AlwaysStoppedAnimation<Color>(p.sage),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

/// Card summarizing the user's rating style.
class RatingStyleCard extends StatelessWidget {
  const RatingStyleCard({super.key, required this.tried});

  final List<TriedCoffee> tried;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final highest = tried.isEmpty
        ? '–'
        : tried
            .map((t) => t.rating)
            .reduce((a, b) => a > b ? a : b)
            .toStringAsFixed(1)
            .replaceAll('.0', '');
    final liked = tried.where((t) => t.liked).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row(context, 'Highest given', highest, star: true),
          Divider(color: p.line, height: 28),
          _row(context, 'Tastings logged', '${tried.length}'),
          Divider(color: p.line, height: 28),
          _row(context, 'Liked', '$liked of ${tried.length}'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool star = false}) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Row(
          children: [
            if (star)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.star,
                  color: p.star,
                  size: 20,
                ),
              ),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}

/// One-line taste summary from the user's tastings, e.g.
/// "Light-roast lover · into Ethiopia".
String tasteIdentityLine(
  List<TriedCoffee> tried,
  CoffeeBean? Function(String id) beanFor,
) {
  if (tried.isEmpty) return 'Your palate is a blank slate — for now';
  final liked = [for (final t in tried) if (t.liked) t];
  final pool = liked.isNotEmpty ? liked : tried;
  final roasts = <String, int>{};
  final origins = <String, int>{};
  for (final t in pool) {
    final bean = beanFor(t.beanId);
    if (bean == null) continue;
    roasts.update(bean.roastLevel, (v) => v + 1, ifAbsent: () => 1);
    origins.update(bean.origin, (v) => v + 1, ifAbsent: () => 1);
  }
  String? top(Map<String, int> counts) => counts.isEmpty
      ? null
      : counts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
  final parts = <String>[];
  final roast = top(roasts);
  if (roast != null) parts.add('${roast.toLowerCase()}-roast lover');
  final origin = top(origins);
  if (origin != null) parts.add('into $origin');
  return parts.isEmpty
      ? 'Your palate is taking shape'
      : parts.join(' · ');
}

/// One bean with all of its tastings nested underneath, newest first.
class GroupedTastingCard extends StatelessWidget {
  const GroupedTastingCard({
    super.key,
    required this.bean,
    required this.tastings,
  });

  final CoffeeBean bean;
  final List<TriedCoffee> tastings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => showBeanDetailSheet(context, bean),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bean.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${bean.origin} · ${bean.roastLevel} roast · '
                          '${tastings.length} tasting${tastings.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: p.muted,
                  ),
                ],
              ),
            ),
          ),
          Divider(color: p.line, height: 1),
          for (var i = 0; i < tastings.length; i++) ...[
            _TastingRow(tasting: tastings[i]),
            if (i < tastings.length - 1)
              Divider(color: p.line, height: 1),
          ],
        ],
      ),
    );
  }
}

class _TastingRow extends StatelessWidget {
  const _TastingRow({required this.tasting});

  final TriedCoffee tasting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tasting.brewMethod,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RatingStars(rating: tasting.rating, size: 15),
              const SizedBox(width: 6),
              Text(
                tasting.rating.toStringAsFixed(1).replaceAll('.0', ''),
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Tooltip(
                message: tasting.liked ? 'Liked it' : 'Not for me',
                child: Icon(
                  tasting.liked
                      ? Icons.thumb_up
                      : Icons.thumb_down_outlined,
                  size: 17,
                  color:
                      tasting.liked ? p.accent : p.muted,
                ),
              ),
            ],
          ),
          if (tasting.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '“${tasting.note}”',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: p.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// #1 pick card: highest-rated tasting's bean.
class PickCard extends StatelessWidget {
  const PickCard({super.key, required this.bean, required this.rating});

  final CoffeeBean bean;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bean.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${bean.origin} · ${bean.roastLevel} roast',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 18,
                  color: p.star,
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1).replaceAll('.0', ''),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.onAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

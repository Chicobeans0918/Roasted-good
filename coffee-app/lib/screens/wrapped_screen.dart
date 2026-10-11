import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/streaks.dart';
import '../models/tried_coffee.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Year in Coffee: a swipeable, story-style carousel of the year's
/// coffee stats, computed from the tasting log. Ends with a shareable
/// summary card (copied to the clipboard).
class WrappedScreen extends StatefulWidget {
  const WrappedScreen({super.key});

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = AppState.of(context);
    final tried = state.triedCoffees;
    final year = DateTime.now().year;
    final pages = _buildPages(context, state, tried, year);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: p.ink,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Your $year in coffee',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < pages.length; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                          right: i < pages.length - 1 ? 6 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: i <= _page
                              ? p.ink
                              : p.line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _page == 0
                        ? null
                        : () => _controller.previousPage(
                              duration:
                                  const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                    child: const Text('Back'),
                  ),
                  TextButton(
                    onPressed: _page == pages.length - 1
                        ? null
                        : () => _controller.nextPage(
                              duration:
                                  const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages(
    BuildContext context,
    AppState state,
    List<TriedCoffee> tried,
    int year,
  ) {
    if (tried.isEmpty) {
      return [
        _WrappedPage(
          eyebrow: 'YOUR $year IN COFFEE',
          headline: 'No tastings yet',
          body: 'Log your first tasting to unlock your '
              'Year in Coffee.',
        ),
      ];
    }

    final topOrigin = _topOrigin(state, tried);
    final topBrew = _topBrew(tried);
    final avg = (tried.map((t) => t.rating).reduce((a, b) => a + b) /
            tried.length)
        .toStringAsFixed(1);
    final longest = longestStreak(tried);
    final topBean = _topBean(state, tried);

    return [
      _WrappedPage(
        eyebrow: 'YOUR $year IN COFFEE',
        headline: '${tried.length}',
        body: 'tastings logged. Here is your year, one sip at a time.',
      ),
      _WrappedPage(
        eyebrow: 'TOP ORIGIN',
        headline: topOrigin,
        body: 'kept calling you back this year.',
      ),
      _WrappedPage(
        eyebrow: 'SIGNATURE BREW',
        headline: topBrew,
        body: 'your most-logged brew method.',
      ),
      _WrappedPage(
        eyebrow: 'AVERAGE RATING',
        headline: avg,
        body: 'stars across every tasting.',
      ),
      _WrappedPage(
        eyebrow: 'LONGEST STREAK',
        headline: '$longest day${longest == 1 ? '' : 's'}',
        body: 'of coffee in a row. Respect.',
      ),
      _WrappedPage(
        eyebrow: 'TOP-RATED BEAN',
        headline: topBean,
        body: 'the highest you scored all year.',
      ),
      _SummaryPage(
        year: year,
        summary: _summaryText(
          year: year,
          tastings: tried.length,
          origin: topOrigin,
          brew: topBrew,
          avg: avg,
          streak: longest,
          bean: topBean,
        ),
      ),
    ];
  }

  String _topOrigin(AppState state, List<TriedCoffee> tried) {
    final counts = <String, int>{};
    for (final t in tried) {
      final bean = state.beanFor(t.beanId);
      if (bean == null) continue;
      counts.update(bean.origin, (v) => v + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return '—';
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String _topBrew(List<TriedCoffee> tried) {
    final counts = <String, int>{};
    for (final t in tried) {
      counts.update(t.brewMethod, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String _topBean(AppState state, List<TriedCoffee> tried) {
    TriedCoffee? best;
    for (final t in tried) {
      if (best == null ||
          t.rating > best.rating ||
          (t.rating == best.rating && t.date.isAfter(best.date))) {
        best = t;
      }
    }
    if (best == null) return '—';
    return state.beanFor(best.beanId)?.name ?? '—';
  }

  String _summaryText({
    required int year,
    required int tastings,
    required String origin,
    required String brew,
    required String avg,
    required int streak,
    required String bean,
  }) {
    return 'My $year in coffee ☕\n'
        '$tastings tastings · $avg average rating\n'
        'Top origin: $origin · Signature brew: $brew\n'
        'Longest streak: $streak day${streak == 1 ? '' : 's'}\n'
        'Top-rated bean: $bean\n'
        '— via Roasted';
  }
}

class _WrappedPage extends StatelessWidget {
  const _WrappedPage({
    required this.eyebrow,
    required this.headline,
    required this.body,
  });

  final String eyebrow;
  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            eyebrow,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: AppType.serifFor(
              context,
              size: 44,
              weight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: p.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPage extends StatelessWidget {
  const _SummaryPage({required this.year, required this.summary});

  final int year;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'SHARE YOUR YEAR',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: p.identityCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.onIdentityCard,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: summary));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Summary copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy_outlined, size: 18),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Copy summary'),
            ),
          ),
        ],
      ),
    );
  }
}

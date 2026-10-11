import 'package:flutter/material.dart';

import '../models/coffee_bean.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bean_card.dart';
import '../widgets/rating_stars.dart';
import '../widgets/tasting_form_sheet.dart';

/// Suggested brew method for a bean, derived from its roast level.
String recommendedBrewMethod(CoffeeBean bean) {
  switch (bean.roastLevel.toLowerCase()) {
    case 'light':
      return 'V60';
    case 'medium':
      return 'Drip';
    case 'medium-dark':
      return 'French press';
    case 'dark':
      return 'Moka pot';
    default:
      return 'V60';
  }
}

/// Scan-a-bag: viewfinder UI with a simulated scan. No camera is used —
/// tapping "Simulate scan" plays a short scanning animation, then reveals
/// a result card for a bean from the catalogue.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  bool _scanning = false;
  CoffeeBean? _result;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  CoffeeBean _pickBean(AppState state) {
    final rated = [
      for (final b in state.beans)
        if (b.rating != null) b,
    ];
    if (rated.isEmpty) return state.beans.first;
    rated.sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated.first;
  }

  Future<void> _simulateScan() async {
    final bean = _pickBean(AppState.of(context));
    setState(() {
      _scanning = true;
      _result = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _result = bean;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan a bag'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          children: [
            // Viewfinder.
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  color: p.surfaceVariant.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    // Corner brackets.
                    for (final corner in _Corner.values)
                      Positioned(
                        top: corner.isTop ? 28 : null,
                        bottom: corner.isTop ? null : 28,
                        left: corner.isLeft ? 28 : null,
                        right: corner.isLeft ? null : 28,
                        child: _CornerBracket(corner: corner),
                      ),
                    if (_scanning)
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, _) {
                          return Positioned(
                            top: 40 +
                                _scanController.value *
                                    220, // sweeps the frame
                            left: 40,
                            right: 40,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: p.star,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        p.star.withValues(alpha: 0.6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    if (!_scanning && _result == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Point at a coffee bag, then simulate the scan',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: p.muted,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (_result == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _scanning ? null : _simulateScan,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_scanning ? 'Scanning…' : 'Simulate scan'),
                  ),
                ),
              )
            else
              _ScanResultCard(bean: _result!),
          ],
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

extension on _Corner {
  bool get isTop => this == _Corner.topLeft || this == _Corner.topRight;
  bool get isLeft =>
      this == _Corner.topLeft || this == _Corner.bottomLeft;
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.corner});

  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _BracketPainter(color: p.ink, corner: corner),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({required this.color, required this.corner});

  final Color color;
  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (corner == _Corner.topLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, 0)
        ..lineTo(0, size.height);
    } else if (corner == _Corner.topRight) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height);
    } else if (corner == _Corner.bottomLeft) {
      path
        ..moveTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, 0);
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Result card: photo, name, community rating, tasting notes, recommended
/// brew method, plus "Log a tasting" and "Save to wishlist" actions.
class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.bean});

  final CoffeeBean bean;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final wishlisted = state.isWishlisted(bean.id);
    final brew = recommendedBrewMethod(bean);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (bean.tastingNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('TASTING NOTES', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final note in bean.tastingNotes)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          p.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.coffee_maker_outlined,
                size: 18,
                color: p.muted,
              ),
              const SizedBox(width: 8),
              Text(
                'Best brewed as $brew',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => showTastingFormSheet(context, bean),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Log a tasting'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                state.toggleWishlist(bean.id);
                final added = state.isWishlisted(bean.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      added
                          ? 'Saved to your wishlist'
                          : 'Removed from your wishlist',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(
                wishlisted
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 18,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  wishlisted ? 'Wishlisted' : 'Save to wishlist',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

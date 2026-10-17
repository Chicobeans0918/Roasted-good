import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

/// Scan-a-bag: live camera barcode scanner.
///
/// A scanned barcode resolves to a catalogue bean — first via the
/// roaster-provided [CoffeeBean.barcode], then via the user's own saved
/// links. When a barcode isn't recognized, the user can link it to a
/// bean once; the link is remembered (and synced when signed in), so
/// the next scan of that bag resolves instantly.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _handled = false;
  CoffeeBean? _result;
  String? _unknownBarcode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    _handled = true;
    _controller.stop();
    final bean = AppState.of(context).beanForBarcode(value);
    setState(() {
      if (bean != null) {
        _result = bean;
      } else {
        _unknownBarcode = value;
      }
    });
  }

  void _scanAgain() {
    setState(() {
      _handled = false;
      _result = null;
      _unknownBarcode = null;
    });
    _controller.start();
  }

  Future<void> _linkBarcode(String barcode) async {
    final beanId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BeanPickerSheet(barcode: barcode),
    );
    if (beanId == null || !mounted) return;
    final state = AppState.of(context);
    state.linkBarcode(barcode, beanId);
    setState(() {
      _result = state.beanFor(beanId);
      _unknownBarcode = null;
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) => Container(
                        color: p.surfaceVariant.withValues(alpha: 0.45),
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              'Camera unavailable — check that Roasted '
                              'has camera permission in Settings.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: p.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Corner brackets.
                    for (final corner in _Corner.values)
                      Positioned(
                        top: corner.isTop ? 28 : null,
                        bottom: corner.isTop ? null : 28,
                        left: corner.isLeft ? 28 : null,
                        right: corner.isLeft ? null : 28,
                        child: _CornerBracket(corner: corner),
                      ),
                    if (!_handled)
                      Positioned(
                        bottom: 28,
                        left: 0,
                        right: 0,
                        child: Text(
                          'Point at the barcode on a coffee bag',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            shadows: const [
                              Shadow(blurRadius: 8, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (_result != null) ...[
              _ScanResultCard(bean: _result!),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _scanAgain,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Scan another bag'),
                  ),
                ),
              ),
            ] else if (_unknownBarcode != null) ...[
              _UnknownBarcodeCard(
                barcode: _unknownBarcode!,
                onLink: () => _linkBarcode(_unknownBarcode!),
                onRetry: _scanAgain,
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _scanAgain,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Restart scanner'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

extension on _Corner {
  bool get isTop => this == _Corner.topLeft || this == _Corner.topRight;
  bool get isLeft => this == _Corner.topLeft || this == _Corner.bottomLeft;
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.corner});

  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _BracketPainter(color: Colors.white, corner: corner),
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

/// Shown when a scanned barcode isn't recognized yet: offers to link
/// it to a catalogue bean, or scan again.
class _UnknownBarcodeCard extends StatelessWidget {
  const _UnknownBarcodeCard({
    required this.barcode,
    required this.onLink,
    required this.onRetry,
  });

  final String barcode;
  final VoidCallback onLink;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "We don't know this bag yet",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Barcode $barcode',
            style: theme.textTheme.bodySmall?.copyWith(color: p.muted),
          ),
          const SizedBox(height: 12),
          Text(
            'Link it to one of your coffees once, and every future '
            'scan will recognize it instantly.',
            style: theme.textTheme.bodyMedium?.copyWith(color: p.muted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLink,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Link to a coffee'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Scan again'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for picking which catalogue bean a barcode belongs to.
class _BeanPickerSheet extends StatefulWidget {
  const _BeanPickerSheet({required this.barcode});

  final String barcode;

  @override
  State<_BeanPickerSheet> createState() => _BeanPickerSheetState();
}

class _BeanPickerSheetState extends State<_BeanPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final q = _query.toLowerCase();
    final beans = [
      for (final b in state.beans)
        if (q.isEmpty ||
            b.name.toLowerCase().contains(q) ||
            (b.roaster ?? '').toLowerCase().contains(q))
          b,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which coffee is this?',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Barcode ${widget.barcode}',
              style: theme.textTheme.bodySmall?.copyWith(color: p.muted),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search coffees…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: beans.length,
                itemBuilder: (context, i) {
                  final bean = beans[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: BeanThumb(bean: bean, size: 44),
                    title: Text(bean.name),
                    subtitle: bean.roaster == null
                        ? null
                        : Text(bean.roaster!),
                    onTap: () => Navigator.of(context).pop(bean.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                      color: p.surfaceVariant.withValues(alpha: 0.5),
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
                wishlisted ? Icons.favorite : Icons.favorite_border,
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

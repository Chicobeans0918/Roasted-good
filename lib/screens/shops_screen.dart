import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/coffee_bean.dart';
import '../models/coffee_shop.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_detail_sheet.dart';

/// Coffee shops and roasteries on a real interactive map
/// (Esri basemaps — free, no API key),
/// centered on Gatineau–Ottawa. The tile style follows the app theme.
///
/// Esri basemaps — no API key required.
/// Free keyless map tiles (Esri). Note the {z}/{y}/{x} order — Esri puts
/// the row before the column, unlike most tile servers.
String esriTileUrl({required bool dark}) => dark
    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}'
    : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';

/// Beans sold at [shop], matched by the bean's "where to buy" label.
/// The reverse of [shopForWhereToBuy]: powers the "coffees available"
/// list on the shop card.
List<CoffeeBean> beansForShop(List<CoffeeBean> beans, CoffeeShop shop) {
  final name = shop.name.toLowerCase();
  return beans
      .where((b) => (b.whereToBuy ?? '').toLowerCase() == name)
      .toList();
}

/// Bottom sheet listing the coffees available at [shop].
/// Each row opens the bean detail sheet.
Future<void> showShopBeansSheet(BuildContext context, CoffeeShop shop) {
  final p = context.palette;
  final theme = Theme.of(context);
  final beans = beansForShop(AppState.of(context).beans, shop);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(shop.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(shop.address, style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
            Text('COFFEES AVAILABLE', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final bean in beans)
                    BeanRow(
                      bean: bean,
                      trailing: BeanThumb(bean: bean, size: 40),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        showBeanDetailSheet(context, bean);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  final MapController _mapController = MapController();

  /// Gatineau–Ottawa midpoint, covering both cities.
  static const LatLng _regionCenter = LatLng(45.431, -75.72);

  /// Real GPS position once location permission is granted; null until then.
  Position? _position;
  StreamSubscription<Position>? _positionSub;

  /// When true, the map recenters on the user as they move.
  bool _following = false;

  /// Last map-focus request consumed from AppState (bean → shop links).
  String? _lastFocusId;

  String? _selectedShopId;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  /// If location was already granted in a previous session, start
  /// tracking silently. Otherwise the user opts in via the locate button
  /// (which triggers the iOS permission prompt in context).
  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startTracking(follow: true);
    }
  }

  /// Locate button: asks for permission if needed, then centers the map
  /// on the user and follows them.
  Future<void> _onLocatePressed() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turn on Location Services to see where you are.'),
        ),
      );
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is needed to show you on the map. '
            'You can enable it in Settings.',
          ),
        ),
      );
      return;
    }
    _startTracking(follow: true);
  }

  void _startTracking({required bool follow}) {
    _positionSub?.cancel();
    setState(() => _following = follow);
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
      if (_following) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          _mapController.camera.zoom,
        );
      }
    });
  }

  LatLng get _userLatLng => _position == null
      ? _regionCenter
      : LatLng(_position!.latitude, _position!.longitude);

  double _distanceKm(CoffeeShop shop) {
    if (shop.latitude == null || shop.longitude == null) return 0;
    const distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      _userLatLng,
      LatLng(shop.latitude!, shop.longitude!),
    );
  }

  void _selectShop(CoffeeShop shop) {
    setState(() => _selectedShopId = shop.id);
    if (shop.latitude != null && shop.longitude != null) {
      _mapController.move(LatLng(shop.latitude!, shop.longitude!), 14);
    }
  }

  /// Consumes a pending "focus this shop" request (from a bean's
  /// "where to buy" link) exactly once.
  void _consumeMapFocus(AppState state) {
    final focusId = state.mapFocusShopId;
    if (focusId == null || focusId == _lastFocusId) return;
    _lastFocusId = focusId;
    final shop = state.shops.where((s) => s.id == focusId).firstOrNull;
    if (shop == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _following = false);
      _selectShop(shop);
      state.clearMapFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    _consumeMapFocus(state);
    final shops = state.shops;
    final selected =
        shops.where((s) => s.id == _selectedShopId).firstOrNull;
    // Esri basemaps (no API key); style follows the theme.
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _regionCenter,
                      initialZoom: 12,
                      // A manual drag breaks follow mode — the user took over.
                      onPositionChanged: (pos, hasGesture) {
                        if (hasGesture && _following) {
                          setState(() => _following = false);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        // Esri basemaps (no API key);
                        // the style follows the app theme.
                        urlTemplate: esriTileUrl(dark: isDark),
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.beanquest.coffee_beans',
                      ),
                      MarkerLayer(
                        markers: [
                          // Real user location — only shown once we
                          // actually have a GPS fix (no more fake dot).
                          if (_position != null)
                            Marker(
                              point: LatLng(
                                _position!.latitude,
                                _position!.longitude,
                              ),
                              width: 32,
                              height: 32,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                          for (final shop in shops)
                            if (shop.latitude != null &&
                                shop.longitude != null)
                              Marker(
                                point: LatLng(
                                  shop.latitude!,
                                  shop.longitude!,
                                ),
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () => _selectShop(shop),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 34,
                                    color: shop.id == _selectedShopId
                                        ? p.accent
                                        : p.muted,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
                  if (selected != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Builder(builder: (cardContext) {
                        final available =
                            beansForShop(state.beans, selected);
                        return _ShopCard(
                          shop: selected,
                          distanceKm: _distanceKm(selected),
                          backgroundColor: p.surface,
                          onTap: () {},
                          beansCount: available.length,
                          onViewBeans: available.isEmpty
                              ? null
                              : () => showShopBeansSheet(
                                    cardContext,
                                    selected,
                                  ),
                        );
                      }),
                    ),
                  // Tile attribution (required by Esri).
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: Text(
                      '© Esri & contributors',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: p.muted,
                      ),
                    ),
                  ),
                  // Locate / follow-me button — top-left, clear of the
                  // scan-a-bag camera shortcut (top-right, from AppShell).
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Material(
                      color: p.surface,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        tooltip: _following
                            ? 'Following you — tap to stop'
                            : 'Show my location',
                        icon: Icon(
                          _following
                              ? Icons.my_location
                              : Icons.location_searching,
                          color: _following ? Colors.blue : p.ink,
                        ),
                        onPressed: _onLocatePressed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GATINEAU–OTTAWA ROASTERS',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(28, 4, 28, 48),
                itemCount: shops.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return _ShopCard(
                    shop: shop,
                    distanceKm: _distanceKm(shop),
                    highlighted: shop.id == _selectedShopId,
                    onTap: () => _selectShop(shop),
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

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.shop,
    required this.distanceKm,
    required this.onTap,
    this.highlighted = false,
    this.backgroundColor,
    this.beansCount = 0,
    this.onViewBeans,
  });

  final CoffeeShop shop;
  final double distanceKm;
  final VoidCallback onTap;
  final bool highlighted;
  final Color? backgroundColor;

  /// Number of catalogue coffees available at this shop; when > 0 and
  /// [onViewBeans] is set, the card shows a tappable "coffees" row.
  final int beansCount;
  final VoidCallback? onViewBeans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: highlighted
              ? Border.all(color: p.ink, width: 1.5)
              : Border.all(color: p.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: theme.textTheme.titleSmall),
                  Text(
                    shop.address,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (shop.approximate)
                    Text(
                      'Approximate location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (onViewBeans != null && beansCount > 0)
                    InkWell(
                      onTap: onViewBeans,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.coffee_outlined,
                              size: 16,
                              color: p.ink,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$beansCount coffees available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: p.ink,
                                decoration: TextDecoration.underline,
                                decorationColor: p.muted,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: p.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${distanceKm.toStringAsFixed(1)} km',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/coffee_shop.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Coffee shops and roasteries on a real interactive map
/// (CARTO minimal basemap, no POI clutter), centered on Gatineau–Ottawa.
///
/// Minimal CARTO basemap tile URL — light and dark variants follow the
/// app theme. Verified against the CARTO basemap tile scheme:
/// `light_all` / `dark_all` with subdomains a–d and `{r}` retina support.
String cartoTileUrl({required bool dark}) =>
    'https://{s}.basemaps.cartocdn.com/${dark ? 'dark_all' : 'light_all'}/{z}/{x}/{y}{r}.png';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  final MapController _mapController = MapController();

  /// Gatineau–Ottawa midpoint, covering both cities.
  static const LatLng _regionCenter = LatLng(45.431, -75.72);

  /// Sample "you are here" point (downtown Hull).
  static const LatLng _userLocation = LatLng(45.43, -75.716);

  String? _selectedShopId;

  double _distanceKm(CoffeeShop shop) {
    if (shop.latitude == null || shop.longitude == null) return 0;
    const distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      _userLocation,
      LatLng(shop.latitude!, shop.longitude!),
    );
  }

  void _selectShop(CoffeeShop shop) {
    setState(() => _selectedShopId = shop.id);
    if (shop.latitude != null && shop.longitude != null) {
      _mapController.move(LatLng(shop.latitude!, shop.longitude!), 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final shops = state.shops;
    final selected =
        shops.where((s) => s.id == _selectedShopId).firstOrNull;
    // Minimal CARTO basemap (no POI clutter); dark variant follows theme.
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
                    options: const MapOptions(
                      initialCenter: _regionCenter,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: cartoTileUrl(dark: isDark),
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.beanquest.coffee_beans',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userLocation,
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
                      child: _ShopCard(
                        shop: selected,
                        distanceKm: _distanceKm(selected),
                        backgroundColor: p.surface,
                        onTap: () {},
                      ),
                    ),
                  // Tile attribution (required by CARTO / OSM).
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: Text(
                      '© OpenStreetMap contributors © CARTO',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: p.muted,
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
  });

  final CoffeeShop shop;
  final double distanceKm;
  final VoidCallback onTap;
  final bool highlighted;
  final Color? backgroundColor;

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

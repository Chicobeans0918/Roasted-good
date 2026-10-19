import 'package:flutter/material.dart';

import '../screens/catalogue_screen.dart';
import '../screens/community_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/shops_screen.dart';
import '../screens/stats_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner.dart';

/// Bottom tab bar shell hosting the main sections.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const String routeName = '/home';

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<_Tab> _tabs = [
    _Tab(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      screen: DiscoverScreen(),
    ),
    _Tab(
      label: 'Catalogue',
      icon: Icons.coffee_outlined,
      activeIcon: Icons.coffee,
      screen: CatalogueScreen(),
    ),
    _Tab(
      label: 'Map',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      screen: ShopsScreen(),
    ),
    _Tab(
      label: 'Community',
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum,
      screen: CommunityScreen(),
    ),
    _Tab(
      label: 'Stats',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      screen: StatsScreen(),
    ),
    _Tab(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      screen: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = AppState.of(context);
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: state.tabIndex,
            children: [for (final tab in _tabs) tab.screen],
          ),
          // Scan-a-bag shortcut, top right of every main screen.
          Positioned(
            top: 4,
            right: 8,
            child: SafeArea(
              child: IconButton(
                tooltip: 'Scan a bag',
                icon: const Icon(Icons.photo_camera_outlined),
                color: p.ink,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ScanScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBanner(),
          Container(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border(
                top: BorderSide(color: p.line),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: state.tabIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: p.surface,
              selectedItemColor: p.ink,
              unselectedItemColor: p.muted,
              elevation: 0,
              selectedLabelStyle: const TextStyle(fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              onTap: (index) => state.setTabIndex(index),
              items: [
                for (final tab in _tabs)
                  BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    activeIcon: Icon(tab.activeIcon),
                    label: tab.label,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
}

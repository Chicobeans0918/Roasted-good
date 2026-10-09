import 'package:flutter/material.dart';

import '../screens/catalogue_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/shops_screen.dart';
import '../screens/stats_screen.dart';
import '../theme/app_theme.dart';

/// Bottom tab bar shell hosting the five main sections.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const String routeName = '/home';

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

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
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final tab in _tabs) tab.screen],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          border: Border(
            top: BorderSide(color: AppColors.line),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.cream,
          selectedItemColor: AppColors.ink,
          unselectedItemColor: AppColors.muted,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) => setState(() => _index = index),
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

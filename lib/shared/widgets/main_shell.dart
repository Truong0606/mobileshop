import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main scaffold with a Material 3 [NavigationBar] for bottom tab navigation.
///
/// This widget receives GoRouter's [StatefulNavigationShell] to manage
/// indexed-stack navigation across the four primary tabs.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  /// The navigation shell provided by [StatefulShellRoute.indexedStack].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabSelected,
        animationDuration: const Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      // Navigate to the initial location of the branch when tapping the
      // already-active item (i.e. pop to root of that tab).
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

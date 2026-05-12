import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';

/// Shell widget for the customer section with bottom navigation bar.
///
/// Uses [StatefulShellRoute.indexedStack] from go_router to preserve
/// the state of each tab when switching between them. This means
/// if a customer scrolls the home page, switches to bookings, then
/// comes back — the scroll position is preserved.
///
/// The bottom nav has 3 tabs:
/// 1. Home — Browse menu packages
/// 2. My Bookings — View/manage bookings
/// 3. Profile — User info & sign out
class CustomerShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(navigationShell.currentIndex)),
        actions: [
          // Show user avatar/name in app bar
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.name.split(' ').first,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Restaurant Packages';
      case 1:
        return 'My Bookings';
      case 2:
        return 'Profile';
      default:
        return AppConstants.appName;
    }
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // Navigate to the initial location of the branch when tapping
      // the already active tab (instead of doing nothing).
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../providers/auth_providers.dart';
import '../ui/common/screens/splash_screen.dart';
import '../ui/auth/login_screen.dart';
import '../ui/auth/register_screen.dart';
import '../ui/customer/customer_shell.dart';
import '../ui/admin/admin_shell.dart';

/// Application router configuration using go_router.
///
/// Route structure:
///   /splash              → Splash screen (initial loading)
///   /login               → Login screen
///   /register            → Registration screen
///   /customer/*          → Customer shell with nested navigation
///     /customer/home     → Browse menu packages
///     /customer/bookings → View bookings
///     /customer/profile  → Profile & settings
///   /admin/*             → Admin shell with nested navigation
///     /admin/packages    → Manage menu packages
///     /admin/bookings    → Manage reservations
///     /admin/profile     → Admin profile
///
/// Route guards:
/// - Unauthenticated users → redirected to /login
/// - Customer users trying /admin/* → redirected to /customer/home
/// - Admin users trying /customer/* → redirected to /admin/packages
/// - Authenticated users on /login or /register → redirected to their dashboard
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppConstants.splashPath,
    debugLogDiagnostics: true,

    // ── Redirect Logic (Route Guard) ──
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      final user = authState.valueOrNull;
      final location = state.matchedLocation;

      // While auth state is loading, stay on splash
      if (isLoading && location == AppConstants.splashPath) {
        return null; // allow splash
      }

      // If still on splash and auth is resolved, redirect
      if (location == AppConstants.splashPath) {
        if (!isAuthenticated) return AppConstants.loginPath;
        return user!.isAdmin
            ? AppConstants.adminPackagesPath
            : AppConstants.customerHomePath;
      }

      // Public routes — accessible without auth
      final publicRoutes = [
        AppConstants.loginPath,
        AppConstants.registerPath,
      ];

      // If not authenticated and trying to access a protected route
      if (!isAuthenticated && !publicRoutes.contains(location)) {
        return AppConstants.loginPath;
      }

      // If authenticated and trying to access login/register, redirect to dashboard
      if (isAuthenticated && publicRoutes.contains(location)) {
        return user!.isAdmin
            ? AppConstants.adminPackagesPath
            : AppConstants.customerHomePath;
      }

      // Role-based access control
      if (isAuthenticated && user != null) {
        final isAdminRoute = location.startsWith('/admin');
        final isCustomerRoute = location.startsWith('/customer');

        if (isAdminRoute && !user.isAdmin) {
          return AppConstants.customerHomePath;
        }

        if (isCustomerRoute && user.isAdmin) {
          return AppConstants.adminPackagesPath;
        }
      }

      return null; // no redirect needed
    },

    // ── Routes ──
    routes: [
      GoRoute(
        path: AppConstants.splashPath,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginPath,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.registerPath,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Customer Shell (StatefulShellRoute for bottom nav) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.customerHomePath,
                name: 'customer_home',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Home',
                  icon: Icons.home,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.customerBookingsPath,
                name: 'customer_bookings',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'My Bookings',
                  icon: Icons.calendar_month,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.customerProfilePath,
                name: 'customer_profile',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Profile',
                  icon: Icons.person,
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Admin Shell (StatefulShellRoute for bottom nav) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.adminPackagesPath,
                name: 'admin_packages',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Manage Packages',
                  icon: Icons.restaurant_menu,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.adminBookingsPath,
                name: 'admin_bookings',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Manage Bookings',
                  icon: Icons.book_online,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.adminProfilePath,
                name: 'admin_profile',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Admin Profile',
                  icon: Icons.admin_panel_settings,
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // ── Error Page ──
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.loginPath),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Temporary placeholder screen for routes not yet implemented.
/// Will be replaced with real screens in future sprints.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in next sprint',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
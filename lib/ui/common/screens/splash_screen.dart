import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Splash screen shown during app initialization.
///
/// The go_router redirect logic handles actual navigation away from this screen
/// once the auth state resolves. This widget is purely visual — a logo + spinner
/// to give the user immediate feedback while Firebase initializes.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Restaurant icon/logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                size: 64,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Savora',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Premium Dining Experiences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gold,
                  ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
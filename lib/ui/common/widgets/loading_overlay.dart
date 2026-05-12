import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Full-screen semi-transparent overlay with a centered spinner.
///
/// Use this to block user interaction during async operations
/// (e.g., sign in, register, booking submission).
///
/// Usage:
/// ```dart
/// LoadingOverlay(
///   isLoading: _isLoading,
///   child: YourScreen(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.navy,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please wait...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
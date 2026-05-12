import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Button variant determines visual style.
enum AppButtonVariant { primary, secondary, outlined, text }

/// Reusable styled button following the Navy/Gold theme.
///
/// Variants:
/// - [AppButtonVariant.primary] — Navy background, white text (default CTA)
/// - [AppButtonVariant.secondary] — Gold background, navy text (accent CTA)
/// - [AppButtonVariant.outlined] — Transparent bg, navy border (secondary action)
/// - [AppButtonVariant.text] — No bg/border (tertiary/links)
///
/// Supports a [loading] state that replaces the label with a spinner
/// and disables the button to prevent double-taps.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final IconData? icon;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    required this.variant,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.icon,
  });

  /// Convenience: Navy background, white text.
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.icon,
  }) : variant = AppButtonVariant.primary;

  /// Convenience: Gold background, navy text.
  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.icon,
  }) : variant = AppButtonVariant.secondary;

  /// Convenience: Transparent background, navy outline.
  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.icon,
  }) : variant = AppButtonVariant.outlined;

  /// Convenience: Text-only (no background or border).
  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  })  : variant = AppButtonVariant.text,
        expanded = false;

  bool get _isEnabled => onPressed != null && !loading;

  Widget _buildChild(Color progressColor) {
    if (loading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: progressColor,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: expanded ? double.infinity : null,
          child: ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.grey300,
              disabledForegroundColor: AppColors.grey500,
            ),
            child: _buildChild(AppColors.white),
          ),
        );
      case AppButtonVariant.secondary:
        return SizedBox(
          width: expanded ? double.infinity : null,
          child: ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDark,
              disabledBackgroundColor: AppColors.goldLight.withAlpha(128),
              disabledForegroundColor: AppColors.grey500,
            ),
            child: _buildChild(AppColors.navyDark),
          ),
        );
      case AppButtonVariant.outlined:
        return SizedBox(
          width: expanded ? double.infinity : null,
          child: OutlinedButton(
            onPressed: _isEnabled ? onPressed : null,
            child: _buildChild(AppColors.navy),
          ),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: _isEnabled ? onPressed : null,
          child: _buildChild(AppColors.goldDark),
        );
    }
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// A segmented toggle for selecting Customer or Admin role during registration.
///
/// Visually highlights the selected role with the gold accent color.
/// Returns the selected role string ('customer' or 'admin') via [onChanged].
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleOption(
                label: 'Customer',
                icon: Icons.person,
                description: 'Browse & book packages',
                isSelected: selectedRole == AppConstants.roleCustomer,
                onTap: () => onChanged(AppConstants.roleCustomer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleOption(
                label: 'Admin',
                icon: Icons.admin_panel_settings,
                description: 'Manage packages & bookings',
                isSelected: selectedRole == AppConstants.roleAdmin,
                onTap: () => onChanged(AppConstants.roleAdmin),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldMuted : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.goldDark : AppColors.grey500,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.navy : AppColors.grey700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.grey700 : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
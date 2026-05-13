import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../common/widgets/error_dialog.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.navy,
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 36, color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.goldMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Admin', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  confirmLabel: 'Sign Out',
                  isDestructive: true,
                );
                if (confirmed) {
                  await ref.read(authProvider.notifier).signOut();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
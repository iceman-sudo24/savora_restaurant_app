import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/menu_package_model.dart';
import '../../data/repositories/menu_repository.dart';
import '../../providers/menu_providers.dart';
import '../common/widgets/error_dialog.dart';

class ManagePackagesScreen extends ConsumerWidget {
  const ManagePackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(allMenuPackagesProvider);

    return Scaffold(
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navy)),
        error: (error, _) => Center(
          child: Text('Error loading packages: $error'),
        ),
        data: (packages) {
          if (packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No packages yet', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tap + to create your first package', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) => _AdminPackageTile(
              package: packages[index],
              onToggle: () async {
                final repo = ref.read(menuRepositoryProvider);
                if (packages[index].isActive) {
                  await repo.deactivatePackage(packages[index].id);
                } else {
                  await repo.activatePackage(packages[index].id);
                }
              },
              onDelete: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Deactivate Package',
                  message: 'This will hide "${packages[index].name}" from customers. Existing bookings will keep the package name.',
                  confirmLabel: 'Deactivate',
                  isDestructive: true,
                );
                if (confirmed) {
                  await ref.read(menuRepositoryProvider).deactivatePackage(packages[index].id);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/packages/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Package'),
      ),
    );
  }
}

class _AdminPackageTile extends StatelessWidget {
  final MenuPackageModel package;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AdminPackageTile({
    required this.package,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: package.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: package.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.grey100,
                      child: const Icon(Icons.restaurant, color: AppColors.grey400),
                    ),
                  )
                : Container(
                    color: AppColors.grey100,
                    child: const Icon(Icons.restaurant, color: AppColors.grey400),
                  ),
          ),
        ),
        title: Text(
          package.name,
          style: TextStyle(
            decoration: package.isActive ? null : TextDecoration.lineThrough,
            color: package.isActive ? null : AppColors.grey500,
          ),
        ),
        subtitle: Text(
          '${AppConstants.currencySymbol} ${package.basePrice.toStringAsFixed(2)} • ${package.items.length} items',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active/Inactive toggle
            Switch(
              value: package.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.gold,
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => context.push('/admin/packages/edit/${package.id}'),
            ),
            // Deactivate
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
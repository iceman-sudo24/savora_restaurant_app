import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/menu_package_model.dart';
import '../../providers/menu_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(activeMenuPackagesProvider);

    return packagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navy)),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Failed to load packages', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(activeMenuPackagesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (packages) {
        if (packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No packages available', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Check back later!', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(activeMenuPackagesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) => _PackageCard(package: packages[index]),
          ),
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final MenuPackageModel package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/customer/home/package/${package.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 180,
              width: double.infinity,
              child: package.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: package.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.grey100,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          package.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${AppConstants.currencySymbol} ${package.basePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (package.items.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: package.items.take(4).map((item) => Chip(
                        label: Text(item, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList()
                        ..addAll(package.items.length > 4
                            ? [Chip(
                                label: Text('+${package.items.length - 4}', style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )]
                            : []),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.navy.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: AppColors.grey400),
      ),
    );
  }
}
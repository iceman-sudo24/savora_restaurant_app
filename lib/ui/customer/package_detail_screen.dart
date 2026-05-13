import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/menu_providers.dart';

class PackageDetailScreen extends ConsumerWidget {
  final String packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(menuPackageByIdProvider(packageId));

    return Scaffold(
      body: packageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navy)),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Package not found')),
        ),
        data: (package) {
          if (package == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Not Found')),
              body: const Center(child: Text('This package is no longer available.')),
            );
          }

          return CustomScrollView(
            slivers: [
              // Collapsing app bar with image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: package.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: package.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              package.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${AppConstants.currencySymbol} ${package.basePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'per guest (base price)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text('About', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        package.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      // Items included
                      if (package.items.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Included Items', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ...package.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 20, color: AppColors.goldDark),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(item, style: Theme.of(context).textTheme.bodyLarge),
                                  ),
                                ],
                              ),
                            )),
                      ],

                      const SizedBox(height: 32),

                      // Book Now button (placeholder for Sprint 3)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Sprint 3: Navigate to booking form
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking flow coming in Sprint 3!')),
                            );
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.navy.withValues(alpha: 0.15),
      child: const Center(child: Icon(Icons.restaurant, size: 64, color: AppColors.grey400)),
    );
  }
}
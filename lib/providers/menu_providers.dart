import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/menu_package_model.dart';
import '../data/repositories/menu_repository.dart';

/// Active packages for customer-facing views. Real-time stream.
final activeMenuPackagesProvider = StreamProvider<List<MenuPackageModel>>((ref) {
  final repo = ref.read(menuRepositoryProvider);
  return repo.watchActivePackages();
});

/// All packages (including inactive) for admin view. Real-time stream.
final allMenuPackagesProvider = StreamProvider<List<MenuPackageModel>>((ref) {
  final repo = ref.read(menuRepositoryProvider);
  return repo.watchAllPackages();
});

/// Fetch a single package by ID. Auto-disposes when no longer watched.
final menuPackageByIdProvider = FutureProvider.family<MenuPackageModel?, String>((ref, id) {
  final repo = ref.read(menuRepositoryProvider);
  return repo.getPackage(id);
});
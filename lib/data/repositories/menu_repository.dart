import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/menu_package_model.dart';

class MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _packagesRef =>
      _firestore.collection(AppConstants.menuPackagesCollection);

  // ── Read ──

  Stream<List<MenuPackageModel>> watchActivePackages() {
    return _packagesRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuPackageModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<MenuPackageModel>> watchAllPackages() {
    return _packagesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuPackageModel.fromFirestore(doc))
            .toList());
  }

  Future<MenuPackageModel?> getPackage(String id) async {
    try {
      final doc = await _packagesRef.doc(id).get();
      if (!doc.exists) return null;
      return MenuPackageModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Create ──

  Future<String> createPackage(MenuPackageModel package) async {
    try {
      final docRef = await _packagesRef.add(package.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Update ──

  Future<void> updatePackage(MenuPackageModel package) async {
    try {
      await _packagesRef.doc(package.id).update(package.toJson());
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  // Soft-delete: preserves denormalized packageName in existing bookings
  Future<void> deactivatePackage(String id) async {
    try {
      await _packagesRef.doc(id).update({'isActive': false});
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> activatePackage(String id) async {
    try {
      await _packagesRef.doc(id).update({'isActive': true});
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppException.permissionDenied();
      default:
        return AppException.unknown(e);
    }
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a menu package that customers can browse and book.
/// Stored in Firestore under `menu_packages/{packageId}`.
///
/// We use `isActive` (soft-delete) instead of hard-deleting packages
/// so that existing bookings retain the denormalized `packageName`.
class MenuPackageModel {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String imageUrl;
  final List<String> items;
  final bool isActive;
  final DateTime createdAt;

  const MenuPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.imageUrl = '',
    this.items = const [],
    this.isActive = true,
    required this.createdAt,
  });

  factory MenuPackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuPackageModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
      items: List<String>.from(data['items'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'items': items,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MenuPackageModel copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    List<String>? items,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MenuPackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  @override
  String toString() => 'MenuPackageModel(id: $id, name: $name, price: $basePrice)';
}
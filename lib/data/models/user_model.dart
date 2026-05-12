import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the system.
/// Stored in Firestore under `users/{uid}`.
///
/// The [role] field determines access: 'customer' or 'admin'.
/// We use a sealed pattern with explicit serialization to avoid
/// accidentally leaking internal fields to/from Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'customer' or 'admin'
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // ── Convenience Getters ──
  bool get isCustomer => role == 'customer';
  bool get isAdmin => role == 'admin';

  // ── Serialization ──

  /// Create from Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data, doc.id);
  }

  /// Create from JSON map. [uid] defaults to the document ID if not in the map.
  factory UserModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return UserModel(
      uid: json['uid'] as String? ?? docId ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      createdAt: _parseTimestamp(json['createdAt']),
    );
  }

  /// Convert to JSON for Firestore write.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ── Copy With ──

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── Helpers ──

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, email: $email, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
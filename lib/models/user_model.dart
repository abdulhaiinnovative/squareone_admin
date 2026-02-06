import 'package:cloud_firestore/cloud_firestore.dart';

/// User model with role-based access control
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'head' or 'employee'
  final String status; // 'Online' or 'Offline'
  final bool availability;
  final String? departmentId;
  final String? createdBy; // ID of the head who created this user
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata; // Additional user data

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.availability,
    this.departmentId,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Factory constructor to create User from Firestore document
  factory User.fromFirestore(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? id,
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'employee', // Default to employee
      status: data['status'] ?? 'Offline',
      availability: data['availability'] ?? false,
      departmentId: data['departmentId'],
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert User to JSON/Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'availability': availability,
      'departmentId': departmentId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  /// Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    bool? availability,
    String? departmentId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      availability: availability ?? this.availability,
      departmentId: departmentId ?? this.departmentId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if user is a head
  bool isHead() => role.toLowerCase() == 'head';

  /// Check if user is an employee
  bool isEmployee() => role.toLowerCase() == 'employee';

  @override
  String toString() =>
      'User(id: $id, name: $name, role: $role, status: $status, availability: $availability)';
}

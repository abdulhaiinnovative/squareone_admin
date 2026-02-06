import 'package:cloud_firestore/cloud_firestore.dart';

/// Department model for organizing heads and employees
class Department {
  final String id;
  final String name;
  final String description;
  final List<String> headIds; // IDs of heads in this department
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.headIds,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Factory constructor to create Department from Firestore document
  factory Department.fromFirestore(String id, Map<String, dynamic> data) {
    return Department(
      id: id,
      name: data['name'] ?? 'Unknown',
      description: data['description'] ?? '',
      headIds: List<String>.from(data['headIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Department to JSON/Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'headIds': headIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  /// Add a head to the department
  Department addHead(String headId) {
    final updatedHeadIds = List<String>.from(headIds);
    if (!updatedHeadIds.contains(headId)) {
      updatedHeadIds.add(headId);
    }
    return copyWith(headIds: updatedHeadIds);
  }

  /// Remove a head from the department
  Department removeHead(String headId) {
    final updatedHeadIds = List<String>.from(headIds);
    updatedHeadIds.remove(headId);
    return copyWith(headIds: updatedHeadIds);
  }

  /// Create a copy of the department with updated fields
  Department copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? headIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      headIds: headIds ?? this.headIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'Department(id: $id, name: $name, headIds: ${headIds.length})';
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Shift model for managing user work schedules
class Shift {
  final String id;
  final String userId;
  final DateTime date;
  final String startTime; // Format: "HH:mm" (24-hour format)
  final String endTime; // Format: "HH:mm" (24-hour format)
  final String timezone; // e.g., "Asia/Karachi", "UTC", "America/New_York"
  final String? notes;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Shift({
    required this.id,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    this.notes,
    this.status = 'scheduled',
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create Shift from Firestore document
  factory Shift.fromFirestore(String id, Map<String, dynamic> data) {
    return Shift(
      id: id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '00:00',
      endTime: data['endTime'] ?? '00:00',
      timezone: data['timezone'] ?? 'UTC',
      notes: data['notes'],
      status: data['status'] ?? 'scheduled',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Shift to JSON/Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'timezone': timezone,
      'notes': notes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy of the shift with updated fields
  Shift copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? timezone,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timezone: timezone ?? this.timezone,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if shift is today
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get shift duration in minutes
  int getDurationInMinutes() {
    final start = _timeToMinutes(startTime);
    final end = _timeToMinutes(endTime);
    return end - start;
  }

  /// Convert time string "HH:mm" to minutes since midnight
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  @override
  String toString() =>
      'Shift(id: $id, userId: $userId, date: $date, startTime: $startTime, endTime: $endTime)';
}

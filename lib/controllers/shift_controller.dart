import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:squareone_admin/models/shift_model.dart';
import 'package:squareone_admin/models/user_model.dart';
import 'package:squareone_admin/helpers/availability_helper.dart';

/// GetX Controller for managing shifts and user availability
class ShiftController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = const Uuid();

  // Observables
  RxList<Shift> allShifts = <Shift>[].obs;
  RxList<Shift> todayShifts = <Shift>[].obs;
  RxMap<String, List<Shift>> userShifts = <String, List<Shift>>{}.obs;
  RxMap<String, String> userAvailabilityStatus = <String, String>{}.obs; // userId -> status
  RxMap<String, bool> userAvailability = <String, bool>{}.obs; // userId -> availability
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Real-time listeners
  StreamSubscription? _shiftsStreamSubscription;
  final Map<String, StreamSubscription> _userShiftListeners = {};

  @override
  void onInit() {
    super.onInit();
    _listenToAllShifts();
    _startAvailabilityCheckTimer();
  }

  /// Listen to all shifts in real-time
  void _listenToAllShifts() {
    _shiftsStreamSubscription = _firestore
        .collection('shifts')
        .where('status', isEqualTo: 'scheduled')
        .snapshots()
        .listen(
      (snapshot) {
        final shiftsList = <Shift>[];
        final userShiftsMap = <String, List<Shift>>{};

        for (var doc in snapshot.docs) {
          final shift = Shift.fromFirestore(doc.id, doc.data());
          shiftsList.add(shift);

          // Group shifts by user
          if (!userShiftsMap.containsKey(shift.userId)) {
            userShiftsMap[shift.userId] = [];
          }
          userShiftsMap[shift.userId]!.add(shift);
        }

        allShifts.value = shiftsList;
        userShifts.value = userShiftsMap;
        _filterTodayShifts();
        _updateAllUserAvailability();
      },
      onError: (error) {
        errorMessage.value = 'Error listening to shifts: $error';
        print(errorMessage.value);
      },
    );
  }

  /// Filter shifts for today
  void _filterTodayShifts() {
    final now = DateTime.now();
    todayShifts.value = allShifts.where((shift) {
      return shift.date.year == now.year &&
          shift.date.month == now.month &&
          shift.date.day == now.day;
    }).toList();
  }

  /// Update availability status for all users
  void _updateAllUserAvailability() {
    for (var entry in userShifts.entries) {
      final userId = entry.key;
      final shifts = entry.value;

      if (shifts.isNotEmpty) {
        // Get the first shift (assuming one shift per day)
        final shift = shifts.first;
        final isOnline = AvailabilityHelper.isUserOnline(
          shiftDate: shift.date,
          startTime: shift.startTime,
          endTime: shift.endTime,
          timezone: shift.timezone,
        );

        final status = AvailabilityHelper.getUserStatus(
          shiftDate: shift.date,
          startTime: shift.startTime,
          endTime: shift.endTime,
          timezone: shift.timezone,
        );

        userAvailability[userId] = isOnline;
        userAvailabilityStatus[userId] = status;
      }
    }
  }

  /// Start a timer to check availability every minute
  void _startAvailabilityCheckTimer() {
    Future.delayed(Duration.zero, () {
      Timer(const Duration(minutes: 1), () {
        _updateAllUserAvailability();
        _startAvailabilityCheckTimer();
      });
    });
  }

  /// Create a new shift
  Future<bool> createShift({
    required String userId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String timezone,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      // Validate time format
      if (!AvailabilityHelper.isValidTimeFormat(startTime) ||
          !AvailabilityHelper.isValidTimeFormat(endTime)) {
        throw Exception('Invalid time format. Use HH:mm');
      }

      // Validate timezone
      if (!AvailabilityHelper.isValidTimezone(timezone)) {
        throw Exception('Invalid timezone');
      }

      final shiftId = _uuid.v4();
      final shift = Shift(
        id: shiftId,
        userId: userId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        timezone: timezone,
        notes: notes,
        status: 'scheduled',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('shifts').doc(shiftId).set(shift.toFirestore());

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error creating shift: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Update an existing shift
  Future<bool> updateShift({
    required String shiftId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? timezone,
    String? notes,
    String? status,
  }) async {
    try {
      isLoading.value = true;

      final updateData = <String, dynamic>{};
      if (date != null) updateData['date'] = Timestamp.fromDate(date);
      if (startTime != null) {
        if (!AvailabilityHelper.isValidTimeFormat(startTime)) {
          throw Exception('Invalid time format. Use HH:mm');
        }
        updateData['startTime'] = startTime;
      }
      if (endTime != null) {
        if (!AvailabilityHelper.isValidTimeFormat(endTime)) {
          throw Exception('Invalid time format. Use HH:mm');
        }
        updateData['endTime'] = endTime;
      }
      if (timezone != null) {
        if (!AvailabilityHelper.isValidTimezone(timezone)) {
          throw Exception('Invalid timezone');
        }
        updateData['timezone'] = timezone;
      }
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;
      updateData['updatedAt'] = Timestamp.now();

      await _firestore.collection('shifts').doc(shiftId).update(updateData);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error updating shift: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Delete a shift
  Future<bool> deleteShift(String shiftId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('shifts').doc(shiftId).delete();

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error deleting shift: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Get shifts for a specific user
  Future<List<Shift>> getUserShifts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('shifts')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Shift.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      errorMessage.value = 'Error fetching user shifts: $e';
      print(errorMessage.value);
      return [];
    }
  }

  /// Get user's current shift (today's shift)
  Future<Shift?> getUserCurrentShift(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('shifts')
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(now.year, now.month, now.day)))
          .where('date',
              isLessThan: Timestamp.fromDate(
                  DateTime(now.year, now.month, now.day + 1)))
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Shift.fromFirestore(
          snapshot.docs.first.id, snapshot.docs.first.data());
    } catch (e) {
      errorMessage.value = 'Error fetching current shift: $e';
      print(errorMessage.value);
      return null;
    }
  }

  /// Get shifts for a date range
  Future<List<Shift>> getShiftsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      Query query = _firestore.collection('shifts');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: false);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Shift.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage.value = 'Error fetching shifts by date range: $e';
      print(errorMessage.value);
      return [];
    }
  }

  /// Get user's availability status
  String getUserAvailabilityStatus(String userId) {
    return userAvailabilityStatus[userId] ?? 'Offline';
  }

  /// Check if user is available
  bool isUserAvailable(String userId) {
    return userAvailability[userId] ?? false;
  }

  /// Get all users who are currently online
  List<String> getOnlineUsers() {
    return userAvailability.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Listen to a specific user's shifts
  void listenToUserShifts(String userId) {
    if (_userShiftListeners.containsKey(userId)) {
      return; // Already listening
    }

    _userShiftListeners[userId] = _firestore
        .collection('shifts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final shifts = <Shift>[];
      for (var doc in snapshot.docs) {
        shifts.add(Shift.fromFirestore(doc.id, doc.data()));
      }
      userShifts[userId] = shifts;
      _updateAllUserAvailability();
    });
  }

  /// Stop listening to a specific user's shifts
  void stopListeningToUserShifts(String userId) {
    _userShiftListeners[userId]?.cancel();
    _userShiftListeners.remove(userId);
  }

  @override
  void onClose() {
    _shiftsStreamSubscription?.cancel();
    for (var listener in _userShiftListeners.values) {
      listener.cancel();
    }
    _userShiftListeners.clear();
    super.onClose();
  }
}

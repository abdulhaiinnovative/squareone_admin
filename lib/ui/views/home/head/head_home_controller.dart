import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


/// Controller for Department Head Home Screen
/// Manages task assignment, employee availability, and task tracking
class HeadHomeController extends GetxController {
  GetStorage storage = GetStorage();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // User Info

  RxString headUid = ''.obs;
  RxString headName = ''.obs;
  RxString departmentName = ''.obs;

  // Task Statistics
  RxInt activeTasksCount = 0.obs;
  RxInt pendingApprovalsCount = 0.obs;
  RxInt completedTasksCount = 0.obs;
  RxInt onShiftEmployeesCount = 0.obs;

  // Employee List
  RxList<Map<String, dynamic>> departmentEmployees = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> onShiftEmployees = <Map<String, dynamic>>[].obs;

  // Tasks
  RxList<Map<String, dynamic>> activeTasks = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pendingApprovals = <Map<String, dynamic>>[].obs;

  // UI State
  RxBool isLoading = false.obs;
  RxString selectedEmployeeId = ''.obs;
  RxString selectedEmployeeName = ''.obs;
  RxBool expandEmployees = false.obs;
  RxBool expandTasks = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHeadInfo().then((_) {
      if (departmentName.value.isNotEmpty && departmentName.value != 'Unknown Department') {
        fetchDepartmentEmployees();
        fetchTaskStatistics();
      }
    });

    // Refresh data every 30 seconds
    // ever(isLoading, (_) => refreshAllData());
  }

  /// Fetch head's information from Firestore
  Future<void> fetchHeadInfo() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        headName.value = 'Not Logged In';
        departmentName.value = 'Unknown';
        return;
      }

      // Important: document ID UID hai, email nahi
      final uid = currentUser.uid;

      DocumentSnapshot doc = await firebaseFirestore
          .collection('personnel')
          .doc(uid)
          .get();

      if (doc.exists) {
        headUid.value = uid;
        headName.value = doc['name']?.toString().trim() ?? currentUser.email?.split('@')[0] ?? 'Head';
        departmentName.value = doc['department_id']?.toString().trim() ?? 'Unknown Department';
      } else {
        headUid.value = uid;
        headName.value = currentUser.email?.split('@')[0] ?? 'Head';
        departmentName.value = 'Not Found';
        print('No personnel document found for UID: $uid');
      }
    } catch (e) {
      print('Error fetching head info: $e');
      headName.value = 'Error';
      departmentName.value = 'Error';
    }
  }

  /// Fetch all employees in the department from personnel collection
  Future<void> fetchDepartmentEmployees({String? departmentId}) async {
    try {
      final department = (departmentId ?? departmentName.value).toString();
      if (department.isEmpty || department == 'Unknown Department' || department == 'Unknown' || department == 'Not Found') return;

      QuerySnapshot snapshot = await firebaseFirestore
          .collection('personnel')
          .where('department_id', isEqualTo: department)
          .where('role', isEqualTo: 'employee')
          .get();

      departmentEmployees.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'employee',
          'status': data['status'] ?? 'Offline',
          'availability': checkEmployeeOnlineStatus(data['shifts']),
          'shifts': data['shifts'] ?? [],
        };
      }).toList();

      // Filter employees on shift
      onShiftEmployees.value = departmentEmployees
          .where((emp) => emp['availability'] == true)
          .toList();

      onShiftEmployeesCount.value = onShiftEmployees.length;
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }
  /// Check if employee is currently online based on shifts array
  /// Returns true if today's date matches a shift date and current time is within shift hours
  /// Returns false otherwise
  bool checkEmployeeOnlineStatus(List<dynamic>? shiftsArray) {
    if (shiftsArray == null || shiftsArray.isEmpty) {
      return false;
    }

    try {
      DateTime now = DateTime.now();
      String todayDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Find today's shift
      for (var shift in shiftsArray) {
        if (shift is! Map<String, dynamic>) continue;

        String? shiftDate = shift['date'];
        String? startTime = shift['start_time'];
        String? endTime = shift['end_time'];
        // timezone field is stored for reference (PKT expected)
        // Future enhancement: can implement timezone conversion if needed

        // Check if shift date matches today
        if (shiftDate != todayDate) continue;

        // If both times are null or empty, skip this shift
        if (startTime == null || endTime == null) continue;

        try {
          // Parse start and end times (format: HH:MM:SS)
          List<String> startParts = startTime.split(':');
          List<String> endParts = endTime.split(':');

          int startHour = int.parse(startParts[0]);
          int startMinute = int.parse(startParts[1]);
          int startSecond =
              startParts.length > 2 ? int.parse(startParts[2]) : 0;

          int endHour = int.parse(endParts[0]);
          int endMinute = int.parse(endParts[1]);
          int endSecond = endParts.length > 2 ? int.parse(endParts[2]) : 0;

          DateTime shiftStart = DateTime(
            now.year,
            now.month,
            now.day,
            startHour,
            startMinute,
            startSecond,
          );

          DateTime shiftEnd = DateTime(
            now.year,
            now.month,
            now.day,
            endHour,
            endMinute,
            endSecond,
          );

          // Handle overnight shifts (e.g., 22:00 to 06:00)
          if (shiftEnd.isBefore(shiftStart)) {
            shiftEnd = shiftEnd.add(const Duration(days: 1));
          }

          // Check if current time falls within shift hours
          if (now.isAfter(shiftStart) && now.isBefore(shiftEnd)) {
            return true;
          }
        } catch (e) {
          print('Error parsing shift times: $e');
          continue;
        }
      }

      return false;
    } catch (e) {
      print('Error checking employee online status: $e');
      return false;
    }
  }

  /// Check if employee is currently on shift (legacy method - kept for backward compatibility)
  bool checkAvailability(String? shiftStart, String? shiftEnd) {
    if (shiftStart == null || shiftEnd == null || shiftStart == 'N/A' || shiftEnd == 'N/A') {
      return false;
    }

    try {
      DateTime now = DateTime.now();
      List<String> startTime = shiftStart.split(':');
      List<String> endTime = shiftEnd.split(':');

      DateTime shift_start = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startTime[0]),
        int.parse(startTime[1]),
      );

      DateTime shift_end = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endTime[0]),
        int.parse(endTime[1]),
      );

      // Handle overnight shifts
      if (shift_end.isBefore(shift_start)) {
        shift_end = shift_end.add(const Duration(days: 1));
      }

      return now.isAfter(shift_start) && now.isBefore(shift_end);
    } catch (e) {
      return false;
    }
  }

  /// Fetch task statistics
  Future<void> fetchTaskStatistics() async {
    try {
      String? department = departmentName.value;
      if (department.isEmpty) return;

      print('DEBUG: Fetching tasks for department: $department');

      // Active Tasks
      QuerySnapshot activeDocs = await firebaseFirestore
          .collection('Tickets')
          .where('department_id', isEqualTo: department)
          .where('status', whereIn: ['Open', 'In Progress', 'Assigned'])
          .get();
      activeTasksCount.value = activeDocs.docs.length;
      print('DEBUG: Found ${activeDocs.docs.length} active tasks');

      // Pending Approvals
      QuerySnapshot pendingDocs = await firebaseFirestore
          .collection('Tickets')
          .where('department_id', isEqualTo: department)
          .where('status', isEqualTo: 'Completed')
          .where('approved', isEqualTo: null)
          .get();
      pendingApprovalsCount.value = pendingDocs.docs.length;
      pendingApprovals.value = pendingDocs.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['ticket_title'] ?? 'No Title',
          'status': doc['status'] ?? 'Unknown',
          'assignee': (doc['assigned_to']?['name']) ?? 'Unassigned',
          'completedAt': doc['completion']?['completed_at'] ?? 'N/A',
        };
      }).toList();

      // Completed Tasks
      QuerySnapshot completedDocs = await firebaseFirestore
          .collection('Tickets')
          .where('department_id', isEqualTo: department)
          .where('status', isEqualTo: 'Completed')
          .get();
      completedTasksCount.value = completedDocs.docs.length;

      // Active Tasks List
      activeTasks.value = activeDocs.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['ticket_title'] ?? 'No Title',
          'status': doc['status'] ?? 'Open',
          'priority': doc['priority'] ?? 'Normal',
          'dueDate': doc['due_date'] ?? 'No date',
          'assignedTo': (doc['assigned_to']?['name']) ?? 'Unassigned',
        };
      }).toList();
      print('DEBUG: Mapped ${activeTasks.value.length} active tasks for display');
    } catch (e) {
      print('Error fetching task statistics: $e');
    }
  }

  /// Assign ticket to an employee using correct schema
  Future<void> assignTaskToEmployee({
    required String taskTitle,
    required String taskDescription,
    required String employeeId,
    required String employeeName,
  }) async {
    try {
      isLoading.value = true;

      final nowIso = DateTime.now().toIso8601String();

      // Create ticket document using the correct schema from dummy_data
      await firebaseFirestore.collection('tickets').add({
        'ticket_title': taskTitle,
        'ticket_description': taskDescription,
        'created_at': nowIso,
        'created_by': headUid.value,
        'created_by_role': 'head',
        'department_id': departmentName.value,
        'assigned_to': {
          'user_id': employeeId,
          'name': employeeName,
          'role': 'employee',
        },
        'assigned_by': {
          'user_id': headUid.value,
          'name': headName.value,
          'role': 'head',
          'assigned_at': nowIso,
        },
        'status': 'Assigned',
        'completion': {
          'completed_at': null,
          'images': [],
          'remarks': null,
        },
        'approved': null,
        'approved_by': null,
        'approved_at': null,
        'feedback': null,
        'feedback_rating': null,
        'subtickets': [],
        'last_updated_at': nowIso,
        'last_updated_by': headUid.value,
      });

      // Send notification to employee
      await firebaseFirestore.collection('notifications').add({
        'recipient': employeeId,
        'type': 'Ticket Assignment',
        'message': 'New ticket assigned: $taskTitle',
        'ticket_title': taskTitle,
        'sender': headUid.value,
        'timestamp': DateTime.now(),
        'read': false,
      });

      isLoading.value = false;
      Get.snackbar('Success', 'Ticket assigned to $employeeName successfully!',
          backgroundColor: Color(0xFF27BB4A),
          colorText: Colors.white);

      // Refresh data
      await fetchTaskStatistics();
      await fetchDepartmentEmployees();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to assign ticket: $e',
          backgroundColor: Color(0xFFC12934),
          colorText: Colors.white);
    }
  }

  /// Approve completed task
  Future<void> approveTask(String taskId) async {
    try {
      await firebaseFirestore.collection('tickets').doc(taskId).update({
        'Approval': 'Approved',
        'ApprovedAt': DateTime.now(),
        'Status': 'Completed',
      });

      Get.snackbar('Success', 'Task approved!',
          backgroundColor: Color(0xFF27BB4A),
          colorText: Colors.white);

      await fetchTaskStatistics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve task: $e',
          backgroundColor: Color(0xFFC12934),
          colorText: Colors.white);
    }
  }

  /// Reject completed task
  Future<void> rejectTask(String taskId, String reason) async {
    try {
      await firebaseFirestore.collection('tickets').doc(taskId).update({
        'Approval': 'Rejected',
        'RejectionReason': reason,
        'Status': 'In Progress',
      });

      Get.snackbar('Success', 'Task rejected and reopened!',
          backgroundColor: Color(0xFF27BB4A),
          colorText: Colors.white);

      await fetchTaskStatistics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject task: $e',
          backgroundColor: Color(0xFFC12934),
          colorText: Colors.white);
    }
  }

  /// Add feedback to a task
  Future<void> addFeedback({
    required String taskId,
    required String feedbackText,
    required double rating,
  }) async {
    try {
      await firebaseFirestore.collection('tickets').doc(taskId).update({
        'Feedback': FieldValue.arrayUnion([
          {
            'from': FirebaseAuth.instance.currentUser?.email,
            'rating': rating,
            'comment': feedbackText,
            'timestamp': DateTime.now(),
          }
        ])
      });

      Get.snackbar('Success', 'Feedback added successfully!',
          backgroundColor: Color(0xFF27BB4A),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add feedback: $e',
          backgroundColor: Color(0xFFC12934),
          colorText: Colors.white);
    }
  }
}

  /// Add new employee to Firebase with proper shift structure
//   Future<void> addEmployeeToFirebase({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     required String shiftDate,
//     required String shiftStart,
//     required String shiftEnd,
//   }) async {
//     try {
//       isLoading.value = true;
//
//       String? currentEmail = FirebaseAuth.instance.currentUser?.email;
//
//       // Create shift object in the required format
//       List<Map<String, dynamic>> shiftsArray = [
//         {
//           'date': shiftDate,
//           'start_time': shiftStart,
//           'end_time': shiftEnd,
//           'timezone': 'PKT',
//         }
//       ];
//
//       // Create employee document in personnel collection
//       await firebaseFirestore.collection('personnel').add({
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'password': password,
//         'role': 'employee',
//         'status': 'Offline',
//         'department_id': departmentName.value,
//         'added_by': currentEmail,
//         'shifts': shiftsArray,
//       });
//
//       isLoading.value = false;
//       Get.snackbar(
//         'Success',
//         'Employee $name added successfully!',
//         backgroundColor: Color(0xFF27BB4A),
//         colorText: Colors.white,
//       );
//
//       // Refresh employee list
//       await fetchDepartmentEmployees();
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar(
//         'Error',
//         'Failed to add employee: $e',
//         backgroundColor: Color(0xFFC12934),
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   /// Refresh all data
//   Future<void> refreshAllData() async {
//     await Future.wait([
//       fetchHeadInfo(),
//       fetchDepartmentEmployees(),
//       fetchTaskStatistics(),
//     ]);
//   }
// }

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

  @override
  void onInit() {
    super.onInit();
    fetchHeadInfo();
    fetchDepartmentEmployees();
    fetchTaskStatistics();
    // Refresh data every 30 seconds
    // ever(isLoading, (_) => refreshAllData());
  }

  /// Fetch head's information from Firestore
  Future<void> fetchHeadInfo() async {
    try {
      String? currentEmail = FirebaseAuth.instance.currentUser?.email;
      if (currentEmail != null) {
        DocumentSnapshot doc = await firebaseFirestore
            .collection('Depart Members')
            .doc(currentEmail)
            .get();

        if (doc.exists) {
          headName.value = doc['Name'] ?? 'Head';
          departmentName.value = doc['Department'] ?? 'Unknown Department';
        }
      }
    } catch (e) {
      print('Error fetching head info: $e');
    }
  }

  /// Fetch all employees in the department
  Future<void> fetchDepartmentEmployees() async {
    try {
      String? department = departmentName.value;
      if (department.isEmpty) return;

      QuerySnapshot snapshot = await firebaseFirestore
          .collection('Depart Members')
          .where('Department', isEqualTo: department)
          .where('role', isEqualTo: 'Employee')
          .get();

      departmentEmployees.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['Name'] ?? 'Unknown',
          'email': doc.id,
          'role': doc['role'] ?? 'Employee',
          'status': checkEmployeeOnlineStatus(doc['shifts']),
          'shiftStart': doc['shiftStart'] ?? 'N/A',
          'shiftEnd': doc['shiftEnd'] ?? 'N/A',
          'availability': checkEmployeeOnlineStatus(doc['shifts']),
          'shifts': doc['shifts'] ?? [],
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

      // Active Tasks
      QuerySnapshot activeDocs = await firebaseFirestore
          .collection('Tickets')
          .where('Department', isEqualTo: department)
          .where('Status', whereIn: ['Open', 'In Progress', 'Assigned'])
          .get();
      activeTasksCount.value = activeDocs.docs.length;

      // Pending Approvals
      QuerySnapshot pendingDocs = await firebaseFirestore
          .collection('Tickets')
          .where('Department', isEqualTo: department)
          .where('Status', isEqualTo: 'Completed')
          .where('Approval', isEqualTo: 'Pending')
          .get();
      pendingApprovalsCount.value = pendingDocs.docs.length;
      pendingApprovals.value = pendingDocs.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['Title'] ?? 'No Title',
          'status': doc['Status'] ?? 'Unknown',
          'assignee': doc['AssignedTo'] ?? 'Unassigned',
          'completedAt': doc['CompletedAt'] ?? 'N/A',
        };
      }).toList();

      // Completed Tasks
      QuerySnapshot completedDocs = await firebaseFirestore
          .collection('Tickets')
          .where('Department', isEqualTo: department)
          .where('Status', isEqualTo: 'Completed')
          .get();
      completedTasksCount.value = completedDocs.docs.length;

      // Active Tasks List
      activeTasks.value = activeDocs.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['Title'] ?? 'No Title',
          'status': doc['Status'] ?? 'Open',
          'priority': doc['Priority'] ?? 'Normal',
          'dueDate': doc['DueDate'] ?? 'No date',
          'assignedTo': doc['AssignedTo'] ?? 'Unassigned',
        };
      }).toList();
    } catch (e) {
      print('Error fetching task statistics: $e');
    }
  }

  /// Assign task to an employee
  Future<void> assignTaskToEmployee({
    required String taskTitle,
    required String category,
    required String employeeId,
    required String employeeName,
    String? dueDate,
    String? priority = 'Normal',
  }) async {
    try {
      isLoading.value = true;

      String? currentEmail = FirebaseAuth.instance.currentUser?.email;

      // Create ticket document
      await firebaseFirestore.collection('Tickets').add({
        'Title': taskTitle,
        'Category': category,
        'Department': departmentName.value,
        'AssignedBy': currentEmail,
        'AssignedTo': employeeName,
        'EmployeeId': employeeId,
        'Status': 'Assigned',
        'Priority': priority ?? 'Normal',
        'DueDate': dueDate ?? DateTime.now().toString(),
        'CreatedAt': DateTime.now(),
        'Approval': 'Pending',
        'Pictures': [],
        'Feedback': [],
      });

      // Send notification to employee
      await firebaseFirestore.collection('Notifications').add({
        'recipient': employeeId,
        'type': 'Task Assignment',
        'message': 'New task assigned: $taskTitle',
        'taskTitle': taskTitle,
        'sender': currentEmail,
        'timestamp': DateTime.now(),
        'read': false,
      });

      isLoading.value = false;
      Get.snackbar('Success', 'Task assigned to $employeeName successfully!',
          backgroundColor: Color(0xFF27BB4A),
          colorText: Colors.white);

      // Refresh data
      await fetchTaskStatistics();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to assign task: $e',
          backgroundColor: Color(0xFFC12934),
          colorText: Colors.white);
    }
  }

  /// Approve completed task
  Future<void> approveTask(String taskId) async {
    try {
      await firebaseFirestore.collection('Tickets').doc(taskId).update({
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
      await firebaseFirestore.collection('Tickets').doc(taskId).update({
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
      await firebaseFirestore.collection('Tickets').doc(taskId).update({
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

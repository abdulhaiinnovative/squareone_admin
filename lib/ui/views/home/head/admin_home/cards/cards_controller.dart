import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


/// Controller for Department Head Home Screen
/// Manages task assignment, employee availability, and task tracking
class CardsController extends GetxController {
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
  RxList<Map<String, dynamic>> completedTasks = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pendingApprovals = <Map<String, dynamic>>[].obs;

  // UI State
  RxBool isLoading = false.obs;
  RxString selectedEmployeeId = ''.obs;
  RxString selectedEmployeeName = ''.obs;
  RxBool expandEmployees = false.obs;
  RxBool expandTasks = false.obs;



  final headsList = <Map<String, dynamic>>[].obs;
  final departments = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // _loadHeadData();
    fetchHeads();
    fetchDepartments();
    fetchAllEmployees();
    // 2. Also listen for auth changes (safety net)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && headUid.value.isEmpty) {
        // _loadHeadData();
      }
    });

    // Refresh data every 30 seconds
    // ever(isLoading, (_) => refreshAllData());
  }
  // Future<void> _loadHeadData() async {
  //   try {
  //     await fetchHeadInfo();
  //
  //     // Force retry if department still invalid after fetch
  //     if (departmentName.value.isEmpty ||
  //         departmentName.value == 'Unknown Department' ||
  //         departmentName.value == 'Unknown' ||
  //         departmentName.value == 'Not Found' ||
  //         departmentName.value == 'Error') {
  //       print("Department still invalid after fetchHeadInfo → retrying in 1s");
  //       await Future.delayed(const Duration(seconds: 1));
  //       await fetchHeadInfo(); // try again
  //     }
  //
  //     // Now load employees & tasks — even if department looks suspicious
  //     print("Loading employees & tasks for dept: ${departmentName.value}");
  //     await fetchDepartmentEmployees();
  //     await fetchTaskStatistics();
  //
  //     // Final safety: if still empty after 2 seconds → retry once more
  //     if (departmentEmployees.isEmpty) {
  //       print("No employees found → final retry");
  //       await Future.delayed(const Duration(seconds: 2));
  //       await fetchDepartmentEmployees();
  //     }
  //   } catch (e) {
  //     print("Error in initial data load: $e");
  //   }
  // }



  /// Fetch departments from Firestore
  Future<void> fetchDepartments() async {
    try {
      isLoading.value = true;

      final snapshot =
      await FirebaseFirestore.instance.collection('departments').get();

      departments.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Optionally add the document ID
        data['id'] = doc.id;
        departments.add(data);
      }

      print("Departments fetched: ${departments.length}");
    } catch (e) {
      print("Error fetching departments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  RxInt headListCount = 0.obs;

  Future<void> fetchHeads() async {
    try {
      isLoading.value = true;

      final snapshot =
      await FirebaseFirestore.instance.collection('personnel').get();


      headsList.clear();

      for (var doc in snapshot.docs) {
        print(doc.data()); // 🔥 CHECK ROLE VALUE

        if (doc['role'].toString().toLowerCase().trim() == 'head') {
          headsList.add(doc.data());
        }
      }

      headListCount.value = headsList.length;

    } catch (e) {
      print("Error fetching heads: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches all employees (role == 'employee') from the 'personnel' collection
  /// Optionally filter by department_id
  Future<void> fetchAllEmployees({String? specificDepartmentId}) async {
    try {
      isLoading.value = true;
      print("Starting to fetch employees...");

      // Use provided department or fallback to current departmentName
      final department = (specificDepartmentId ?? departmentName.value).trim();

      // Safety check
      if (department.isEmpty ||
          department == 'Unknown Department' ||
          department == 'Unknown' ||
          department == 'Not Found' ||
          department == 'Error') {
        print("Skipping fetch - invalid department: '$department'");
        return;
      }

      print("Fetching employees for department: '$department'");

      QuerySnapshot snapshot = await firebaseFirestore
          .collection('personnel')
          .where('department_id', isEqualTo: department)
          .where('role', isEqualTo: 'employee') // ← only employees
          .get();

      print("Found ${snapshot.docs.length} employee documents");

      // Clear previous list
      departmentEmployees.clear();

      // Map to clean format
      departmentEmployees.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'uid': doc.id,
          'name': data['name']?.toString().trim() ?? 'Unknown Employee',
          'email': data['email']?.toString().trim() ?? '',
          'phone': data['phone']?.toString().trim() ?? '',
          'role': data['role']?.toString().trim() ?? 'employee',
          'department_id': data['department_id']?.toString().trim() ?? department,
          'status': data['status']?.toString().trim() ?? 'Offline',
          'availability': checkEmployeeOnlineStatus(data['shifts']),
          'shifts': data['shifts'] ?? [],
          // Add more fields if needed
          'createdAt': data['createdAt'],
        };
      }).toList();

      // Update on-shift employees
      onShiftEmployees.value = departmentEmployees
          .where((emp) => emp['availability'] == true)
          .toList();

      onShiftEmployeesCount.value = onShiftEmployees.length;

      print("Employees loaded: ${departmentEmployees.length}");
      print("On shift now: ${onShiftEmployees.length}");

      // Optional: sort by name
      departmentEmployees.sort((a, b) =>
          (a['name'] as String).compareTo(b['name'] as String));
    }
    catch (e) {
      print("Error while fetching employees: $e");
      Get.snackbar(
        'Error',
        'Failed to load employees: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
    finally {
      isLoading.value = false;
    }
  }


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
  bool checkEmployeeOnlineStatus(List<dynamic>? shiftsArray) {
    if (shiftsArray == null || shiftsArray.isEmpty) {
      return false;
    }

    try {
      DateTime now = DateTime.now();
      // String todayDate =
      //     '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Find today's shift
      for (var shift in shiftsArray) {
        if (shift is! Map<String, dynamic>) continue;

        String? shiftDate = shift['date'];
        String? startTimeRaw = shift['start_time']?.toString();
        String? endTimeRaw = shift['end_time']?.toString();
        // timezone field is stored for reference (PKT expected)
        // Future enhancement: can implement timezone conversion if needed

        // Check if shift date matches today
        // if (shiftDate != todayDate) continue;

        // If both times are null or empty, skip this shift
        if (startTimeRaw == null || endTimeRaw == null) continue;

        try {
          // Extract time portion (supports formats like "02:00", "02:00:00", or "2:00 AM")
          final timeRegex = RegExp(r"(\d{1,2}:\d{2}(?::\d{2})?)");
          final startMatch = timeRegex.firstMatch(startTimeRaw);
          final endMatch = timeRegex.firstMatch(endTimeRaw);
          final startTime = startMatch?.group(1);
          final endTime = endMatch?.group(1);

          if (startTime == null || endTime == null) continue;

          // Parse start and end times
          List<String> startParts = startTime.split(':');
          List<String> endParts = endTime.split(':');

          int startHour = int.parse(startParts[0]);
          int startMinute = int.parse(startParts[1]);
          int startSecond = startParts.length > 2 ? int.parse(startParts[2]) : 0;

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

          // Inclusive check: consider start and end moments as on-duty
          if ((!now.isBefore(shiftStart)) && (!now.isAfter(shiftEnd))) {
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


  RxList<Map<String, dynamic>> assignedTasks = <Map<String, dynamic>>[].obs;


  final String _ticketsCollection = 'tickets';  // ← yeh define kar diya


  Future<void> fetchTaskStatistics() async {
    try {
      String? department = departmentName.value;
      if (department.isEmpty) return;

      print('DEBUG: Fetching tasks for department: $department');


      // Active Tasks (Open + In Progress + Assigned)
      QuerySnapshot activeDocs = await firebaseFirestore
          .collection(_ticketsCollection)  // ← 'tickets' use karo
          .where('department_id', isEqualTo: department)
          .where('status', whereIn: ['Completed', 'In Progress', 'Assigned'])
          .get();

      activeTasksCount.value = activeDocs.docs.length;
      print('DEBUG: Found ${activeDocs.docs.length} active tasks');

      // Assigned tickets ko alag se filter kar ke store karo
      assignedTasks.value = activeDocs.docs
          .where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'Assigned';
      })
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['ticket_title'] ?? 'No Title',
          'description': data['ticket_description'] ?? '',
          'status': data['status'] ?? 'Assigned',
          'priority': data['priority'] ?? 'Normal',
          'dueDate': data['due_date'] ?? 'No date',
          'assignedTo': data['assigned_to']?['name'] ?? 'Unassigned',
          'assignedAt': data['assigned_by']?['assigned_at'] ?? 'N/A',
        };
      }).toList();

      print('DEBUG: Assigned tickets found = ${assignedTasks.length}');

      // Pending Approvals
      QuerySnapshot pendingDocs = await firebaseFirestore
          .collection(_ticketsCollection)
          .where('department_id', isEqualTo: department)
          .where('status', isEqualTo: 'Pending')
          .where('approved', isEqualTo: null)
          .get();

      pendingApprovalsCount.value = pendingDocs.docs.length;
      pendingApprovals.value = pendingDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['ticket_title'] ?? 'No Title',
          'status': data['status'] ?? 'Unknown',
          'assignee': data['assigned_to']?['name'] ?? 'Unassigned',
          'completedAt': data['completion']?['completed_at'] ?? 'N/A',
        };
      }).toList();

      // Completed count
      QuerySnapshot completedDocs = await firebaseFirestore
          .collection(_ticketsCollection)
          .where('department_id', isEqualTo: department)
          .where('status', isEqualTo: 'Completed')
          .get();

      completedTasksCount.value = completedDocs.docs.length;

      completedTasks.value = completedDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['ticket_title'] ?? 'No Title',
          'status': data['status'] ?? 'Completed',
          'priority': data['priority'] ?? 'Normal',
          'dueDate': data['due_date'] ?? 'No date',
          'assignedTo': data['assigned_to']?['name'] ?? 'Unassigned',
        };
      }).toList();


      activeTasks.value = activeDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['ticket_title'] ?? 'No Title',
          'status': data['status'] ?? 'Open',
          'priority': data['priority'] ?? 'Normal',
          'dueDate': data['due_date'] ?? 'No date',
          'assignedTo': data['assigned_to']?['name'] ?? 'Unassigned',
        };
      }).toList();

      print('DEBUG: Active tasks list length = ${activeTasks.length}');
    } catch (e) {
      print('Error fetching task statistics: $e');
    }
  }

  /// Assign ticket to an employee
  Future<void> assignTaskToEmployee({required String taskTitle, required String taskDescription, required String employeeId, required String employeeName,}) async {
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
  Future<void> addFeedback({required String taskId, required String feedbackText, required double rating,}) async {
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

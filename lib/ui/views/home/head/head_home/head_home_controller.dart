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

  RxInt totalEmployeesCount = 0.obs;

  // Departments
  RxList<String> departmentsList = <String>[].obs;
  RxInt departmentsCount = 0.obs;


  // User Info
  RxString headUid = ''.obs;
  RxString headName = ''.obs;
  RxString adminName = ''.obs;
  RxString adminRole = ''.obs;
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

  RxString currentUserRole = ''.obs;
  RxString currentUserName = ''.obs;


  @override
  void onInit() {
    super.onInit();
    _loadHeadData();
    fetchDepartmentStaff();

    // 2. Also listen for auth changes (safety net)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && headUid.value.isEmpty) {
        _loadHeadData();
      }
    });
  }

  Future<void> _loadHeadData() async {
    try {
      // 1️⃣ Pehle head/admin info load karo
      await fetchHeadInfo();

      // 2️⃣ Agar role head hai to department validate karo
      if (currentUserRole.value == 'head') {
        if (departmentName.value.isEmpty ||
            departmentName.value == 'Unknown Department' ||
            departmentName.value == 'Unknown' ||
            departmentName.value == 'Not Found' ||
            departmentName.value == 'Error') {

          print("Department invalid → retrying in 1s");
          await Future.delayed(const Duration(seconds: 1));
          await fetchHeadInfo();
        }
      }

      print("ROLE: ${currentUserRole.value}");
      print("DEPARTMENT: ${departmentName.value}");

      // 3️⃣ Role ke hisaab se staff load karo
      if (currentUserRole.value == 'admin') {
        print("Admin detected → Loading ALL departments");
        await fetchDepartmentStaff(allDepartments: true);
      } else if (currentUserRole.value == 'head') {
        print("Head detected → Loading own department staff");
        await fetchDepartmentStaff();
      } else {
        print("Employee detected → Loading department employees only");
        await fetchDepartmentEmployees();
      }

      // 4️⃣ Task stats load karo
      await fetchTaskStatistics();

      // 5️⃣ Final retry if empty
      if (departmentEmployees.isEmpty &&
          currentUserRole.value != 'admin') {
        print("No employees found → final retry");
        await Future.delayed(const Duration(seconds: 2));

        if (currentUserRole.value == 'head') {
          await fetchDepartmentStaff();
        } else {
          await fetchDepartmentEmployees();
        }
      }

    } catch (e) {
      print("Error in initial data load: $e");
    }
  }



  // Future<void> _loadHeadData() async {
  //   try {
  //     await fetchHeadInfo();
  //
  //     if (departmentName.value.isEmpty ||
  //         departmentName.value == 'Unknown Department' ||
  //         departmentName.value == 'Unknown' ||
  //         departmentName.value == 'Not Found' ||
  //         departmentName.value == 'Error') {
  //       print("Department still invalid after fetchHeadInfo → retrying in 1s");
  //       await Future.delayed(const Duration(seconds: 1));
  //       await fetchHeadInfo();
  //     }
  //
  //     print("Loading employees & tasks for dept: ${departmentName.value}");
  //     await fetchDepartmentEmployees();
  //     await fetchTaskStatistics();
  //
  //     if (departmentEmployees.isEmpty) {
  //       print("No employees found → final retry");
  //       await Future.delayed(const Duration(seconds: 2));
  //       await fetchDepartmentEmployees();
  //     }
  //   } catch (e) {
  //     print("Error in initial data load: $e");
  //   }
  // }

  Future<void> fetchHeadInfo() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        headName.value = 'Not Logged In';
        departmentName.value = 'Unknown';
        adminName.value = 'Admin';
        currentUserRole.value = 'guest';
        return;
      }

      final uid = currentUser.uid;

      DocumentSnapshot doc = await firebaseFirestore
          .collection('personnel')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        headUid.value = uid;


        headName.value =
        data['name']?.toString().trim().isNotEmpty == true
            ? data['name'].toString().trim()
            : currentUser.displayName ??
            currentUser.email?.split('@')[0] ??
            'Head';


        adminName.value = headName.value;

        departmentName.value =
        data.containsKey('department')
            ? data['department']?.toString().trim() ?? 'Unknown Department'
            : 'Unknown Department';

        currentUserRole.value =
            data['role'];

        currentUserName.value =
            data['name']?.toString().trim() ?? 'unknown';

        adminName.value = headName.value; // if head/admin themselves
        adminRole.value = currentUserRole.value; // track role separately
        print("Head Name: ${headName.value}");
        print("Department: ${departmentName.value}");
      } else {
        headUid.value = uid;
        headName.value =
            currentUser.displayName ??
                currentUser.email?.split('@')[0] ??
                'Head';

        adminName.value = headName.value;
        departmentName.value = 'Not Found';
        currentUserRole.value = 'no_document';
      }
    } catch (e) {
      print('Error fetching head info: $e');
      headName.value =
          FirebaseAuth.instance.currentUser?.displayName ??
              FirebaseAuth.instance.currentUser?.email?.split('@')[0] ??
              'Head';

      adminName.value = headName.value;
      departmentName.value = 'Error';
    }
  }


  Future<void> fetchDepartmentEmployees({String? departmentId}) async {
    try {
      final department = (departmentId ?? departmentName.value).toString();
      if (department.isEmpty || department == 'Unknown Department' || department == 'Unknown' || department == 'Not Found') return;

      QuerySnapshot snapshot = await firebaseFirestore
          .collection('personnel')
          .where('department', isEqualTo: department)
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
          'department': data['department'] ?? '',
          'availability': checkEmployeeOnlineStatus(data['shifts']),
          'shifts': data['shifts'] ?? [],
        };

      }).toList();


      onShiftEmployees.value = departmentEmployees
          .where((emp) => emp['availability'] == true)
          .toList();

      onShiftEmployeesCount.value = onShiftEmployees.length;
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  /// Fetch both employees and heads in the same department
  Future<void> fetchDepartmentStaff({bool allDepartments = false}) async {
    try {
      isLoading.value = true;

      Query query = firebaseFirestore
          .collection('personnel')
          .where('role', whereIn: ['employee', 'head']);

      // 👇 Agar specific department chahiye tabhi filter lagao
      if (!allDepartments) {
        final department = departmentName.value;

        if (department.isNotEmpty &&
            department != 'Unknown Department' &&
            department != 'Unknown' &&
            department != 'Not Found') {
          query = query.where('department', isEqualTo: department);
        }
      }

      QuerySnapshot snapshot = await query.get();

      departmentEmployees.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        totalEmployeesCount.value = departmentEmployees
            .where((e) => (e['role'] ?? '').toString().toLowerCase() == 'employee')
            .length;


        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'role': data['role'] ?? '',
          'department': data['department'] ?? '',
          'availability': checkEmployeeOnlineStatus(data['shifts']),
          'shifts': data['shifts'] ?? [],
        };
      }).toList();

      onShiftEmployees.value = departmentEmployees
          .where((emp) => emp['availability'] == true)
          .toList();

      onShiftEmployeesCount.value = onShiftEmployees.length;

      print("Fetched ${departmentEmployees.length} staff members");
    } catch (e) {
      print("Error fetching staff: $e");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchDepartments() async {
    try {
      QuerySnapshot snapshot =
      await firebaseFirestore.collection('departments').get();

      departmentsList.value =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();

      departmentsCount.value = departmentsList.length;

    } catch (e) {
      print("Error fetching departments: $e");
    }
  }



  bool checkEmployeeOnlineStatus(List<dynamic>? shiftsArray) {
    if (shiftsArray == null || shiftsArray.isEmpty) {
      return false;
    }

    try {
      DateTime now = DateTime.now();

      for (var shift in shiftsArray) {
        if (shift is! Map<String, dynamic>) continue;

        String? startTimeRaw = shift['start_time']?.toString();
        String? endTimeRaw = shift['end_time']?.toString();

        if (startTimeRaw == null || endTimeRaw == null) continue;

        try {
          final timeRegex = RegExp(r"(\d{1,2}:\d{2}(?::\d{2})?)");
          final startMatch = timeRegex.firstMatch(startTimeRaw);
          final endMatch = timeRegex.firstMatch(endTimeRaw);
          final startTime = startMatch?.group(1);
          final endTime = endMatch?.group(1);

          if (startTime == null || endTime == null) continue;

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

          if (shiftEnd.isBefore(shiftStart)) {
            shiftEnd = shiftEnd.add(const Duration(days: 1));
          }

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

      if (shift_end.isBefore(shift_start)) {
        shift_end = shift_end.add(const Duration(days: 1));
      }

      return now.isAfter(shift_start) && now.isBefore(shift_end);
    } catch (e) {
      return false;
    }
  }

  RxList<Map<String, dynamic>> assignedTasks = <Map<String, dynamic>>[].obs;

  final String _ticketsCollection = 'tickets';

  Future<void> fetchTaskStatistics() async {
    try {
      String? department = departmentName.value;
      if (department.isEmpty) return;

      QuerySnapshot activeDocs = await firebaseFirestore
          .collection(_ticketsCollection)
          .where('department', isEqualTo: department)
          .where('status', whereIn: ['Completed', 'In Progress', 'Assigned'])
          .get();

      activeTasksCount.value = activeDocs.docs.length;

      assignedTasks.value = activeDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'title': data['ticket_title'] ?? 'No Title',
          'description': data['ticket_description'] ?? '',
          'department': data['department'] ?? '',
          'status': data['status'] ?? 'Open',
          'priority': data['priority'] ?? 'Normal',
          'dueDate': data['due_date'] ?? 'No date',
          'assignedTo': data['assigned_to']?['name'] ?? 'Unassigned',
          'assignedToRole': data['assigned_to']?['role'] ?? 'N/A',
          'assignedBy': data['assigned_by']?['name'] ?? 'N/A',
          'assignedByRole': data['assigned_by']?['role'] ?? 'N/A',
          'assignedAt': data['assigned_by']?['assigned_at'] ?? 'N/A',
        };
      }).toList();

      // 🔹 Print all assigned tasks for debugging
      for (var task in assignedTasks) {
        print('--- TASK ID: ${task['id']} ---');
        print(task);
      }


      QuerySnapshot pendingDocs = await firebaseFirestore
          .collection(_ticketsCollection)
          .where('department', isEqualTo: department)
          .where('status', isEqualTo: 'Pending')
          .where('approved', isEqualTo: null)
          .get();

      pendingApprovalsCount.value = pendingDocs.docs.length;
      pendingApprovals.value = pendingDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['ticket_title'] ?? 'No Title',
          'description': data['ticket_description'] ?? '',
          'department': data['department'] ?? '',
          'status': data['status'] ?? 'Open',
          'priority': data['priority'] ?? 'Normal',
          'dueDate': data['due_date'] ?? 'No date',
          'assignedTo': data['assigned_to']?['name'] ?? 'Unassigned',
          'assignedToRole': data['assigned_to']?['role'] ?? 'N/A',
          'assignedBy': data['assigned_by']?['name'] ?? 'N/A',
          'assignedByRole': data['assigned_by']?['role'] ?? 'N/A',
          'assignedAt': data['assigned_by']?['assigned_at'] ?? 'N/A',
        };
      }).toList();

      QuerySnapshot completedDocs = await firebaseFirestore
          .collection(_ticketsCollection)
          .where('department', isEqualTo: department)
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
    } catch (e) {
      print('Error fetching task statistics: $e');
    }
  }

  Future<void> assignTaskToEmployee({
    required String taskTitle,
    required String taskDescription,
    required String employeeId,
    required String employeeName,
     String? department,
  }) async {

    final currentUser = FirebaseAuth.instance.currentUser;
    final query = await FirebaseFirestore.instance
        .collection('personnel')
        .where('email', isEqualTo: currentUser?.email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      Get.snackbar('Error', 'User data not found in Firestore');
      return;
    }

    final doc = query.docs.first;
    final currentUserRole = doc['role'] ?? 'unknown';
    final currentUserName = doc['name'] ?? 'Unknown';
    final currentUserId = doc['uid'] ?? currentUser!.uid;

    try {
      isLoading.value = true;

      final nowIso = DateTime.now().toIso8601String();

      await firebaseFirestore.collection('tickets').add({
        'ticket_title': taskTitle,
        'ticket_description': taskDescription,
        'created_at': nowIso,
        'created_by': currentUserId,
        'created_by_role': currentUserRole,
        'department': department,
        'assigned_to': {
          'user_id': employeeId,
          'name': employeeName,
          'role': 'employee',
        },
        'assigned_by': {
          'user_id': currentUserId,
          'name': currentUserName, // ← Use adminName here
          'role': currentUserRole,
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
        'last_updated_by': currentUserId,
      });

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

      await fetchTaskStatistics();
      await fetchDepartmentEmployees();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to assign ticket: $e',
          backgroundColor: Color(0xFFC12934),
          colorText: Colors.white);
    }
  }

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

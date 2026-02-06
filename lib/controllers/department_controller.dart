import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:squareone_admin/models/department_model.dart';
import 'package:squareone_admin/models/user_model.dart';

/// GetX Controller for managing departments
class DepartmentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = const Uuid();

  // Observables
  RxList<Department> allDepartments = <Department>[].obs;
  RxMap<String, Department> departmentsMap = <String, Department>{}.obs;
  Rx<Department?> selectedDepartment = Rx<Department?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Real-time listeners
  StreamSubscription? _departmentsStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToDepartments();
  }

  /// Listen to all departments in real-time
  void _listenToDepartments() {
    _departmentsStreamSubscription = _firestore
        .collection('departments')
        .snapshots()
        .listen(
      (snapshot) {
        final departmentsList = <Department>[];
        final departmentsMap = <String, Department>{};

        for (var doc in snapshot.docs) {
          final department = Department.fromFirestore(doc.id, doc.data());
          departmentsList.add(department);
          departmentsMap[department.id] = department;
        }

        allDepartments.value = departmentsList;
        this.departmentsMap.value = departmentsMap;
      },
      onError: (error) {
        errorMessage.value = 'Error listening to departments: $error';
        print(errorMessage.value);
      },
    );
  }

  /// Create a new department
  Future<bool> createDepartment({
    required String name,
    required String description,
    List<String>? headIds,
  }) async {
    try {
      isLoading.value = true;

      final departmentId = _uuid.v4();
      final department = Department(
        id: departmentId,
        name: name,
        description: description,
        headIds: headIds ?? [],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('departments')
          .doc(departmentId)
          .set(department.toFirestore());

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error creating department: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Update department information
  Future<bool> updateDepartment({
    required String departmentId,
    String? name,
    String? description,
    List<String>? headIds,
  }) async {
    try {
      isLoading.value = true;

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (headIds != null) updateData['headIds'] = headIds;
      updateData['updatedAt'] = Timestamp.now();

      await _firestore
          .collection('departments')
          .doc(departmentId)
          .update(updateData);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error updating department: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Add a head to a department
  Future<bool> addHeadToDepartment({
    required String departmentId,
    required String headId,
  }) async {
    try {
      final department = departmentsMap[departmentId];
      if (department == null) {
        throw Exception('Department not found');
      }

      if (department.headIds.contains(headId)) {
        // Head already in department
        return true;
      }

      final updatedHeadIds = List<String>.from(department.headIds)..add(headId);

      await _firestore.collection('departments').doc(departmentId).update({
        'headIds': updatedHeadIds,
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      errorMessage.value = 'Error adding head to department: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Remove a head from a department
  Future<bool> removeHeadFromDepartment({
    required String departmentId,
    required String headId,
  }) async {
    try {
      final department = departmentsMap[departmentId];
      if (department == null) {
        throw Exception('Department not found');
      }

      final updatedHeadIds = List<String>.from(department.headIds)
        ..remove(headId);

      await _firestore.collection('departments').doc(departmentId).update({
        'headIds': updatedHeadIds,
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      errorMessage.value = 'Error removing head from department: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Delete a department
  Future<bool> deleteDepartment(String departmentId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('departments').doc(departmentId).delete();

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error deleting department: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Get a specific department by ID
  Department? getDepartmentById(String departmentId) {
    return departmentsMap[departmentId];
  }

  /// Get all departments
  List<Department> getAllDepartments() => allDepartments;

  /// Select a department
  void selectDepartment(String departmentId) {
    selectedDepartment.value = departmentsMap[departmentId];
  }

  /// Clear selected department
  void clearSelectedDepartment() {
    selectedDepartment.value = null;
  }

  /// Get heads of a specific department
  Future<List<String>> getDepartmentHeadIds(String departmentId) async {
    try {
      final doc = await _firestore.collection('departments').doc(departmentId).get();
      if (doc.exists) {
        return List<String>.from(doc['headIds'] ?? []);
      }
      return [];
    } catch (e) {
      errorMessage.value = 'Error fetching department heads: $e';
      print(errorMessage.value);
      return [];
    }
  }

  /// Search departments by name
  List<Department> searchDepartments(String query) {
    final lowerQuery = query.toLowerCase();
    return allDepartments
        .where((dept) =>
            dept.name.toLowerCase().contains(lowerQuery) ||
            dept.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  void onClose() {
    _departmentsStreamSubscription?.cancel();
    super.onClose();
  }
}

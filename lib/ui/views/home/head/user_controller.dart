import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:squareone_admin/ui/views/home/head/models/user_model.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_model.dart';


/// GetX Controller for managing users (heads and employees)
class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static const Uuid _uuid = const Uuid();

  // Observables
  RxList<User> allUsers = <User>[].obs;
  RxList<User> heads = <User>[].obs;
  RxList<User> employees = <User>[].obs;
  RxMap<String, User> usersMap = <String, User>{}.obs;
  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Real-time listeners
  StreamSubscription? _usersStreamSubscription;
  StreamSubscription? _currentUserSubscription;

  @override
  void onInit() {
    super.onInit();
    _getCurrentUser();
    _listenToAllUsers();
  }

  /// Get current logged-in user's data from Firestore (personnel collection)
  Future<void> _getCurrentUser() async {
    try {
      final storage = GetStorage();
      
      // Try to get user from GetStorage (set during login)
      final userId = storage.read('user_id');
      
      if (userId != null) {
        // Fetch from personnel collection using saved user_id
        final doc = await _firestore.collection('personnel').doc(userId).get();
        if (doc.exists) {
          currentUser.value = User.fromFirestore(doc.id, doc.data()!);
          print('✓ Current user loaded from personnel: ${currentUser.value!.name} (Role: ${currentUser.value!.role})');
          return;
        }
      }
      
      // Fallback: if no user_id in storage, try using Firebase Auth UID
      final currentAuthUser = _auth.currentUser;
      if (currentAuthUser != null) {
        // Try personnel collection first
        final snapshot = await _firestore
            .collection('personnel')
            .where('email', isEqualTo: currentAuthUser.email)
            .limit(1)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          currentUser.value = User.fromFirestore(doc.id, doc.data());
          print('✓ Current user loaded from personnel by email: ${currentUser.value!.name}');
          return;
        }
        
        // Fallback to users collection
        final doc = await _firestore.collection('personnel').doc(currentAuthUser.uid).get();
        if (doc.exists) {
          currentUser.value = User.fromFirestore(doc.id, doc.data()!);
          print('✓ Current user loaded from users collection');
          return;
        }
      }
      
      print('⚠ Warning: Could not load current user data');
    } catch (e) {
      errorMessage.value = 'Error fetching current user: $e';
      print(errorMessage.value);
    }
  }

  /// Listen to all users in real-time
  void _listenToAllUsers() {
    _usersStreamSubscription = _firestore.collection('personnel').snapshots().listen(
      (snapshot) {
        final usersList = <User>[];
        final userMap = <String, User>{};

        for (var doc in snapshot.docs) {
          final user = User.fromFirestore(doc.id, doc.data());
          usersList.add(user);
          userMap[user.id] = user;
        }

        allUsers.value = usersList;
        usersMap.value = userMap;
        _filterUsersByRole();
      },
      onError: (error) {
        errorMessage.value = 'Error listening to users: $error';
        print(errorMessage.value);
      },
    );
  }

  /// Filter users by role
  void _filterUsersByRole() {
    heads.value = allUsers.where((user) => user.isHead()).toList();
    employees.value = allUsers.where((user) => user.isEmployee()).toList();
  }

  /// Create a new user (head or employee)
  /// Only heads can create other users
  Future<bool> createUser({
    required String name,
    required String email,
    required String phone,
    required String role, // 'head' or 'employee'
    required String password,
    String? departmentId,
  }) async {
    try {
      isLoading.value = true;

      // Verify current user is a head
      if (currentUser.value == null || !currentUser.value!.isHead()) {
        throw Exception('Only heads can create new users');
      }

      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Create user document in Firestore
      final user = User(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        role: role.toLowerCase(),
        status: 'Offline',
        availability: false,
        departmentId: departmentId,
        createdBy: currentUser.value!.id,
        createdAt: DateTime.now(),
      );

      // Save to users collection (for general user management)
      await _firestore.collection('personnel').doc(userId).set(user.toFirestore());

      // Also save to personnel collection (for login and authentication)
      // Using auto-generated document ID
      final personnelRef = await _firestore.collection('personnel').add({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password, // Store for reference (not used for auth)
        'role': role.toLowerCase(),
        'status': 'Offline',
        'availability': false,
        'departmentId': departmentId,
        'createdBy': currentUser.value!.id,
        'fcmToken': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✓ User created successfully: $email (userId: $userId, personnelDocId: ${personnelRef.id})');

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error creating user: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Update user information
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? departmentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      isLoading.value = true;

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (departmentId != null) updateData['departmentId'] = departmentId;
      if (metadata != null) updateData['metadata'] = metadata;
      updateData['updatedAt'] = Timestamp.now();

      await _firestore.collection('personnel').doc(userId).update(updateData);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error updating user: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Update user status (Online/Offline)
  Future<bool> updateUserStatus({
    required String userId,
    required String status,
  }) async {
    try {
      await _firestore.collection('personnel').doc(userId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      errorMessage.value = 'Error updating user status: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Update user availability
  Future<bool> updateUserAvailability({
    required String userId,
    required bool availability,
  }) async {
    try {
      await _firestore.collection('personnel').doc(userId).update({
        'availability': availability,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      errorMessage.value = 'Error updating user availability: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      // Delete user document
      await _firestore.collection('personnel').doc(userId).delete();

      // Delete associated shifts
      final shiftsSnapshot = await _firestore
          .collection('shifts')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in shiftsSnapshot.docs) {
        await doc.reference.delete();
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error deleting user: $e';
      print(errorMessage.value);
      return false;
    }
  }

  /// Get a specific user by ID
  User? getUserById(String userId) {
    return usersMap[userId];
  }

  /// Get all heads
  List<User> getAllHeads() => heads;

  /// Get all employees
  List<User> getAllEmployees() => employees;

  /// Get employees created by a specific head
  Future<List<User>> getEmployeesByHead(String headId) async {
    try {
      final snapshot = await _firestore
          .collection('personnel')
          .where('role', isEqualTo: 'employee')
          .where('createdBy', isEqualTo: headId)
          .get();

      return snapshot.docs
          .map((doc) => User.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      errorMessage.value = 'Error fetching employees: $e';
      print(errorMessage.value);
      return [];
    }
  }

  /// Get employees in a specific department
  Future<List<User>> getEmployeesByDepartment(String departmentId) async {
    try {
      final snapshot = await _firestore
          .collection('personnel')
          .where('role', isEqualTo: 'employee')
          .where('departmentId', isEqualTo: departmentId)
          .get();

      return snapshot.docs
          .map((doc) => User.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      errorMessage.value = 'Error fetching employees by department: $e';
      print(errorMessage.value);
      return [];
    }
  }

  /// Search users by name or email
  List<User> searchUsers(String query) {
    final lowerQuery = query.toLowerCase();
    return allUsers
        .where((user) =>
            user.name.toLowerCase().contains(lowerQuery) ||
            user.email.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  void onClose() {
    _usersStreamSubscription?.cancel();
    _currentUserSubscription?.cancel();
    super.onClose();
  }
}

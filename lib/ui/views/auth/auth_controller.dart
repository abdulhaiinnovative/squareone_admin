import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squareone_admin/ui/views/home/food_dept/food_dept_home_view.dart';
import 'package:squareone_admin/ui/views/home/marketing/marketing_home_view.dart';
import 'package:squareone_admin/dummy_data.dart';
import '../../../admin_home_screen.dart';
import '../home/admin/admin_home_view.dart';
import '../home/head/head_home_view.dart';
import '../home/maintainance/maintainance_home_view.dart';
import '../home/security/security_home_view.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  GetStorage storage = GetStorage();
  RxBool isloading = false.obs;

  void saveDataLocal() {
    storage.write('email', emailController.text);
    storage.write('password', passwordController.text);
  }

  void login() async {
    isloading.value = true;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    // ────────────────────────────────────────────────
    // Existing dummy/local login logic (unchanged)
    // ────────────────────────────────────────────────
    // List<MapEntry<String, Map<String, dynamic>>> matches = personnel.entries
    //     .where((e) {
    //   final eEmail = (e.value['email'] as String?)?.toLowerCase() ?? '';
    //   return eEmail == email;
    // }).toList();

    // if (matches.isEmpty) {
    //   // Try matching by local-part (before @) to be more forgiving for test emails
    //   try {
    //     final localPart = email.split('@').first;
    //     final alt = personnel.entries.where((e) {
    //       final eEmail = (e.value['email'] as String?)?.toLowerCase() ?? '';
    //       final role = (e.value['role'] as String?) ?? '';
    //       return eEmail.split('@').first == localPart && role == 'employee';
    //     }).toList();
    //     if (alt.isNotEmpty) {
    //       log('Local-login: falling back to local-part match for <$localPart>, matched ${alt.first.key}');
    //       matches.addAll(alt);
    //     }
    //   } catch (e) {
    //     // ignore
    //   }
    // }
    //
    // if (matches.isNotEmpty) {
    //   final entry = matches.first;
    //   final expected = (entry.value['password'] as String?) ?? '';
    //   log('Local-login: expectedPasswordLen=${expected.length}');
    //   if (password == expected) {
    //     // Correct local credentials — branch by role
    //     final role = (entry.value['role'] as String?) ?? '';
    //
    //     if (role.toLowerCase() == 'head' || role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin') {
    //       // Simulate admin login — you may want to persist differently
    //       // loginAsEmployeeById(entry.key); // still store current user map (commented as it was undefined)
    //       storage.write('employee_id', entry.key);
    //       isloading.value = false;
    //       Get.offAll(() => HeadHomeView());
    //       return;
    //     }
    //
    //     // Other roles (e.g., head) — currently not allowed to login in this app
    //     isloading.value = false;
    //     Get.snackbar('Login Failed', 'Role not permitted in this app');
    //     return;
    //   } else {
    //     log('Local-login: password mismatch for ${entry.key}');
    //     isloading.value = false;
    //     Get.snackbar('Login Failed', 'Invalid email or password for employee');
    //     return;
    //   }
    // }

    // ────────────────────────────────────────────────
    // New Firebase + personnel collection login logic
    // ────────────────────────────────────────────────
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Step 1: Authenticate with Firebase Auth
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Step 2: Query Firestore personnel collection by email
        QuerySnapshot querySnapshot = await firebaseFirestore
            .collection('personnel')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          await auth.signOut();
          Get.snackbar(
            'Login Failed',
            'User profile not found in personnel database. Please contact administrator.',
          );
          isloading.value = false;
          return;
        }

        // Step 3: Get user document and document ID (auto-generated)
        final userDoc = querySnapshot.docs.first;
        final userDocId = userDoc.id;
        final userData = userDoc.data() as Map<String, dynamic>;
        final userRole = userData['role']?.toString().toLowerCase() ?? '';
        final userName = userData['name'] ?? 'User';

        // Step 4: Verify role is "head"
        if (userRole != 'head') {
          await auth.signOut();
          Get.snackbar(
            'Access Denied',
            'Only department heads can access this application. Your role: $userRole',
            backgroundColor: const Color(0xFFC12934),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          isloading.value = false;
          return;
        }

        // Step 5: Update FCM token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await firebaseFirestore
              .collection('personnel')
              .doc(userDocId)
              .update({
            'fcmToken': fcmToken,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }

        // Step 6: Save local data
        saveDataLocal();
        storage.write('user_id', userDocId);
        storage.write('firebase_uid', userCredential.user!.uid);
        storage.write('user_name', userName);
        storage.write('user_role', userRole);
        storage.write('user_email', email);

        log('User logged in successfully: $email (Role: $userRole, DocID: $userDocId)');

        // Step 7: Success message & navigate to Head Home
        Get.snackbar(
          'Login Successful',
          'Welcome back, $userName!',
          backgroundColor: const Color(0xFF27BB4A),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Get.offAll(() => HeadHomeView());
      } on FirebaseAuthException catch (e) {
        log('Firebase Auth Error: ${e.code}');
        String errorMessage = _getAuthErrorMessage(e.code);
        Get.snackbar(
          'Login Failed',
          errorMessage,
          backgroundColor: const Color(0xFFC12934),
          colorText: Colors.white,
        );
      } catch (e) {
        log('Unexpected error during login: $e');
        Get.snackbar(
          'Login Error',
          'An unexpected error occurred. Please try again.',
          backgroundColor: const Color(0xFFC12934),
          colorText: Colors.white,
        );
      } finally {
        isloading.value = false;
      }
    } else {
      isloading.value = false;
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'Login failed. Please check your email and password.';
    }
  }

  void routeToHome() {
    firebaseFirestore
        .collection('Depart Members')
        .doc(emailController.text.toLowerCase())
        .get()
        .then((value) {
      print(value.data()!['Department']);
      storage.write('name', value['Name']);
      switch (value.data()!['Department']) {
        case 'Security':
        case 'CR':
          Get.offAll(() => SecurityHomeView());
          break;
        case 'Maintainance':
          Get.offAll(() => MaintainanceHomeView());
          break;
        case 'Operations':
        case 'Admin':
          Get.offAll(() => AdminHomeView());
          break;
        case 'Marketing':
          Get.offAll(() => MarketingHomeView());
          break;
        case 'Food Court':
          print("foodDept");
          Get.offAll(() => FoodDeptHomeView());
          break;
      }
    });
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await auth.signOut();
      storage.erase();
      emailController.clear();
      passwordController.clear();
      Get.snackbar('Logged Out', 'You have been successfully logged out.');
      log('User logged out successfully');
    } catch (e) {
      log('Error during logout: $e');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
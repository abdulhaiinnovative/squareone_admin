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
import '../home/head/admin_home/new_admin_home_view.dart';
import '../home/head/head_home/head_home_view.dart';
import '../home/maintainance/maintainance_home_view.dart';
import '../home/security/security_home_view.dart';
import 'auth_view.dart';

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

    if (email.isEmpty || password.isEmpty) {
      isloading.value = false;
      return;
    }

    try {
      // Firebase Auth login
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore personnel query
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('personnel')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await auth.signOut();
        Get.snackbar(
          'Login Failed',
          'User profile not found. Please contact administrator.',
        );
        isloading.value = false;
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final userDocId = userDoc.id;
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role']?.toString().toLowerCase() ?? '';
      final userName = userData['name'] ?? 'User';

      // Allow only admin or head
      if (userRole != 'admin' && userRole != 'head') {
        await auth.signOut();
        Get.snackbar(
          'Access Denied',
          'Only admins or department heads can access this app. Your role: $userRole',
          backgroundColor: const Color(0xFFC12934),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        isloading.value = false;
        return;
      }

      // Update FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await firebaseFirestore.collection('personnel').doc(userDocId).update({
          'fcmToken': fcmToken,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      // Save local data
      storage.write('user_id', userDocId);
      storage.write('firebase_uid', userCredential.user!.uid);
      storage.write('user_name', userName);
      storage.write('user_role', userRole);
      storage.write('user_email', email);

      Get.snackbar(
        'Login Successful',
        'Welcome back, $userName!',
        backgroundColor: const Color(0xFF27BB4A),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to correct home
      if (userRole == 'admin') {
        Get.offAll(() => NewAdminHomeView());
      } else if (userRole == 'head') {
        Get.offAll(() => HeadHomeView());
      }

    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login Failed',
        e.message ?? 'Login failed. Check credentials.',
        backgroundColor: const Color(0xFFC12934),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: const Color(0xFFC12934),
        colorText: Colors.white,
      );
    } finally {
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

      emailController.clear();
      passwordController.clear();
      await auth.signOut();
      storage.erase();
      emailController.clear();
      passwordController.clear();
      Get.snackbar('Logged Out', 'You have been successfully logged out.');
      log('User logged out successfully');
      Get.offAll(() => LoginView());
    } catch (e) {
      log('Error during logout: $e');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }

  @override
  void onClose() {
    //
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
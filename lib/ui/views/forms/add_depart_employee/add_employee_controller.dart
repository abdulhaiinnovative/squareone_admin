import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDeptEmployeeController extends GetxController {
  final isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final shiftDateController = TextEditingController();
  final shiftStartController = TextEditingController();
  final shiftEndController = TextEditingController();

  final selectedRole = 'employee'.obs;
  final departmentName = 'General'.obs; // baad mein dropdown se change kar sakte ho

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    shiftDateController.dispose();
    shiftStartController.dispose();
    shiftEndController.dispose();
    super.onClose();
  }

  // Date & Time Pickers (same as before)
  Future<void> pickShiftDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      shiftDateController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> pickShiftStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      shiftStartController.text =
      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> pickShiftEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );

    if (picked != null) {
      shiftEndController.text =
      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> addEmployee() async {
    // Basic validation
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        shiftDateController.text.trim().isEmpty ||
        shiftStartController.text.trim().isEmpty ||
        shiftEndController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    // Email format check (basic)
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    // Password length check (minimum 6 chars for Firebase Auth)
    if (passwordController.text.trim().length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final currentUserEmail = _auth.currentUser?.email ?? 'unknown';

      // Step 1: Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // Step 2: Prepare shift data
      final List<Map<String, dynamic>> shiftsArray = [
        {
          'date': shiftDateController.text.trim(),
          'start_time': shiftStartController.text.trim(),
          'end_time': shiftEndController.text.trim(),
          'timezone': 'PKT',
        }
      ];

      // Step 3: Save user data in Firestore (WITHOUT password)
      await _firestore.collection('personnel').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'role': selectedRole.value,
        'status': 'Offline',
        'department_id': departmentName.value,
        'added_by': currentUserEmail,
        'shifts': shiftsArray,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        '${selectedRole.value == 'head' ? 'Department Head' : 'Employee'} ${nameController.text.trim()} added successfully!',
        backgroundColor: const Color(0xFF27BB4A),
        colorText: Colors.white,
      );

      _clearFields();
      Get.back();

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      } else {
        errorMessage = e.message ?? 'Authentication failed';
      }

      Get.snackbar('Error', errorMessage, backgroundColor: Colors.redAccent);
      log('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      log('Error adding employee: $e');
      Get.snackbar('Error', 'Failed to add employee: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    shiftDateController.clear();
    shiftStartController.clear();
    shiftEndController.clear();
    selectedRole.value = 'employee';
  }
}
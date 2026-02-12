import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDeptForEmployeeController extends GetxController {
  final isLoading = false.obs;

  final departmentNameController = TextEditingController();
  // final emailController = TextEditingController();
  // final phoneController = TextEditingController();
  // final passwordController = TextEditingController();
  // final shiftDateController = TextEditingController();
  // final shiftStartController = TextEditingController();
  // final shiftEndController = TextEditingController();

  // final selectedRole = 'employee'.obs;
  final departmentName = ''.obs;

  /// Accept department id from caller (Head) so new employees are saved to correct department
  AddDeptForEmployeeController({String? department}) {
    if (department != null && department.isNotEmpty) {
      departmentName.value = department;
    } else {
      departmentName.value = 'General';
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onClose() {
    departmentNameController.dispose();
    // emailController.dispose();
    // phoneController.dispose();
    // passwordController.dispose();
    // shiftDateController.dispose();
    // shiftStartController.dispose();
    // shiftEndController.dispose();
    super.onClose();
  }

  // Date & Time Pickers (same as before)
  // Future<void> pickShiftDate(BuildContext context) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now().subtract(const Duration(days: 30)),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //   );
  //
  //
  //   if (picked != null) {
  //     shiftDateController.text =
  //     "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
  //   }
  // }
  //
  // Future<void> pickShiftStartTime(BuildContext context) async {
  //   final picked = await showTimePicker(
  //     context: context,
  //     initialTime: const TimeOfDay(hour: 9, minute: 0),
  //   );
  //
  //   if (picked != null) {
  //     shiftStartController.text =
  //     "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
  //   }
  // }
  //
  // Future<void> pickShiftEndTime(BuildContext context) async {
  //   final picked = await showTimePicker(
  //     context: context,
  //     initialTime: const TimeOfDay(hour: 17, minute: 0),
  //   );
  //
  //   if (picked != null) {
  //     shiftEndController.text =
  //     "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
  //   }
  // }

  Future<void> addDepartment() async {
    // Basic validation
    if (departmentNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }



    isLoading.value = true;

    try {
      // final email = emailController.text.trim();
      // final password = passwordController.text.trim();
      final currentUser = FirebaseAuth.instance.currentUser;

      final currentUserUid  = currentUser?.uid;          // ← best to use UID
      final currentUserEmail = currentUser?.email ?? 'unknown';



      // // Step 2: Prepare shift data
      // final List<Map<String, dynamic>> shiftsArray = [
      //   {
      //     'date': shiftDateController.text.trim(),
      //     'start_time': shiftStartController.text.trim(),
      //     'end_time': shiftEndController.text.trim(),
      //     'timezone': 'PKT',
      //   }


      // Step 3: Save user data in Firestore (WITHOUT password)
      await _firestore.collection('departments').add({
        'name': departmentNameController.text.trim(),
        'createdBy': currentUserUid,
        'createdAt': FieldValue.serverTimestamp(),
      });



      Get.snackbar(
        'Success',
        '${departmentNameController.value} added successfully!',
        backgroundColor: const Color(0xFF27BB4A),
        colorText: Colors.white,
      );

      _clearFields();
      Get.back();

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Something went wrong';


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
    departmentNameController.clear();
    // emailController.clear();
    // phoneController.clear();
    // passwordController.clear();
    // shiftDateController.clear();
    // shiftStartController.clear();
    // shiftEndController.clear();
    // selectedRole.value = 'employee';
  }
}
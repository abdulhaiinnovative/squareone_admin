import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../component/dialog.dart';
import '../../home/admin/admin_home_view.dart';

class AddDepartmentController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<DropdownMenuItem<String>> get outletItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          value: "Maintainance", child: Text("Maintainance")),
      const DropdownMenuItem(value: "Security", child: Text("Security")),
      const DropdownMenuItem(value: "Operations", child: Text("Operations")),
      const DropdownMenuItem(value: "Marketing", child: Text("Marketing")),
      const DropdownMenuItem(value: "CR", child: Text("CR")),
      const DropdownMenuItem(value: "Food Court", child: Text("Food Court")),
    ];
    return menuItems;
  }

  String? selectedOutlet;

  addDepart() {
    if (nameController.text.isNotEmpty &
        contactController.text.isNotEmpty &
        emailController.text.isNotEmpty &
        passwordController.text.isNotEmpty) {
      isLoading.value = true;
      return firebaseFirestore
          .collection('Depart Members')
          .doc(emailController.text)
          .set({
        'Name': nameController.text.trim(),
        'Contact Number': contactController.text.trim(),
        'Email': emailController.text.trim(),
        'Password': passwordController.text.trim(),
        "Department": selectedOutlet,
        'token': '',
      }).whenComplete(() {
        try {
          auth
              .createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim())
              .whenComplete(() {
            isLoading.value = false;
            contactController.clear();
            emailController.clear();
            passwordController.clear();
            getDialog(title: 'Success', desc: 'Member Added Successfully.')
                .then((value) => Get.offAll(() => AdminHomeView()));
          });
        } on FirebaseException catch (e) {
          log(e.toString());
          Get.snackbar('Operation Failed', '');
          isLoading.value = false;
        }
      });
    }
  }
}

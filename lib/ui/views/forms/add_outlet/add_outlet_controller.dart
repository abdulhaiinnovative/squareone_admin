import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../component/dialog.dart';
import '../../home/admin/admin_home_view.dart';

class AddOutletController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nameControler = TextEditingController();
  TextEditingController pocController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<DropdownMenuItem<String>> get outletItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          value: "Retail Outlet", child: Text("Retail Outlet")),
      const DropdownMenuItem(
          value: "Food Court Outlet", child: Text("Food Court Outlet")),
    ];
    return menuItems;
  }

  String? selectedOutlet;

  addOutlet() {
    if (nameControler.text.isNotEmpty &
        nameControler.text.isNotEmpty &
        pocController.text.isNotEmpty &
        contactController.text.isNotEmpty &
        emailController.text.isNotEmpty &
        passwordController.text.isNotEmpty) {
      isLoading.value = true;
      try {
        auth
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .whenComplete(() => firebaseFirestore
                    .collection('Outlets')
                    .doc(emailController.text)
                    .set({
                  'Outlet Name': nameControler.text.trim(),
                  'POC': pocController.text.trim(),
                  'Contact Number': contactController.text.trim(),
                  'Email': emailController.text.trim(),
                  'Password': passwordController.text.trim(),
                  "status": 'Active',
                  'token': '',
                  "outlet type": selectedOutlet
                }).whenComplete(() {
                  isLoading.value = false;
                  nameControler.clear();
                  contactController.clear();
                  pocController.clear();
                  emailController.clear();
                  passwordController.clear();
                  getDialog(
                          title: 'Success', desc: 'Outlet Added Successfully.')
                      .then((value) => Get.offAll(() => AdminHomeView()));
                }));
      } on FirebaseException catch (e) {
        isLoading.value = false;
        log(e.toString());
        Get.snackbar('Operation Failed', '');
      }
    }
  }
}

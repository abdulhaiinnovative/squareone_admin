import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squareone_admin/ui/views/home/food_dept/food_dept_home_view.dart';
import 'package:squareone_admin/ui/views/home/marketing/marketing_home_view.dart';

import '../home/admin/admin_home_view.dart';
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
    if (emailController.text.isNotEmpty & passwordController.text.isNotEmpty) {
      try {
        await auth
            .signInWithEmailAndPassword(
                email: emailController.text.toLowerCase(),
                password: passwordController.text.trim())
            .then((value) {
          FirebaseMessaging.instance.getToken().then((token) {
            if (token != null) {
              debugPrint(token);
              firebaseFirestore
                  .collection('Depart Members')
                  .doc(emailController.text.toLowerCase())
                  .update({
                'token': token,
              }).whenComplete(() {
                print(token);
                routeToHome();
                isloading.value = false;
              });
            } else {
              log('Failed to get FCM token');
              isloading.value = false;
            }
          }).catchError((error) {
            log('Error getting FCM token: $error');
            isloading.value = false;
          });
          saveDataLocal();
          routeToHome();
        });
      } on FirebaseAuthException catch (e) {
        log(e.toString());
        Get.snackbar(
            'Login Activity Failed', 'Check your email and password again. ');
        isloading.value = false;
      }
    }
  }

  routeToHome() {
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
        // break;
      }
    });
  }
}

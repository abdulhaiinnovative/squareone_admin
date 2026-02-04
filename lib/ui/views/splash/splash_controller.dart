import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squareone_admin/ui/views/home/food_dept/food_dept_home_view.dart';

import '../auth/auth_view.dart';
import '../home/admin/admin_home_view.dart';
import '../home/maintainance/maintainance_home_view.dart';
import '../home/marketing/marketing_home_view.dart';
import '../home/security/security_home_view.dart';

class SplashController extends GetxController {
  RxBool isloadin = false.obs;

  @override
  void onInit() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => const LoginView());

      getData();
    });
    // initInfo();
    // request();
    super.onInit();
  }

  GetStorage storage = GetStorage();

  getData() {
    var email = storage.read('email');
    var password = storage.read('password');

    if (email == '' || password == '') {
      Get.offAll(() => const LoginView());
    } else {
      if (email == null && password == null) {
        Get.offAll(() => const LoginView());
      } else {
        isloadin.value = true;
        try {
          isloadin.value = true;

          FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          if (FirebaseAuth.instance.currentUser!.uid.isNotEmpty) {
            routeToHome(email);
          }
        } on FirebaseAuthException catch (e) {
          log(e.toString());
          Get.offAll(() => const LoginView());
        }
      }
    }
  }

  routeToHome(email) {
    FirebaseFirestore.instance
        .collection('Depart Members')
        .doc(email)
        .get()
        .then((value) {
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
          // print("foodDept");
          Get.offAll(() => FoodDeptHomeView());
      }
    });
  }
}

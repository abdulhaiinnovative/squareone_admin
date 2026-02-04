import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../forms/add_notification/add_notifications_controller.dart';

class OutletController extends GetxController {
  RxBool isLoading = false.obs;
  void deleteUser(email, password, token) async {
    isLoading.value = true;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    debugPrint(FirebaseAuth.instance.currentUser!.email);
    FirebaseAuth.instance.currentUser!.delete().whenComplete(() async {
      GetStorage storage = GetStorage();
      String emailz = await storage.read('email');
      String passwordz = await storage.read('password');
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailz, password: passwordz);
      await FirebaseFirestore.instance.collection('Outlets').doc(email).update({
        'token': '',
        'status': "Deleted",
      });
      await sendMessage(
        token,
        'Your account has been suspended',
        'Account Suspended',
        'logout',
      ).whenComplete(() {
        isLoading.value = true;

        Get.back();
      });
    });
  }
}

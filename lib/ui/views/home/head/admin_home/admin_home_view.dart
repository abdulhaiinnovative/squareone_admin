import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../../../component/colors.dart';

class NewAdminHomeView extends StatelessWidget {
  NewAdminHomeView({super.key});
  final controller = Get.put<AdminHomeController>(AdminHomeController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.index.value == 0
          ? controller._onWillPop(context)
          : controller.index.value = 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetX<AdminHomeController>(
            builder: (controller) => newAdminPages[controller.index.value]),
        bottomNavigationBar: GetX<AdminHomeController>(
          init: Get.put<AdminHomeController>(AdminHomeController()),
          builder: (controller) => SalomonBottomBar(
            selectedItemColor: const Color.fromARGB(255, 23, 35, 44),
            items: headItems,
            currentIndex: controller.index.value,
            onTap: (i) => controller.indexChange(i),
          ),
        ),
      ),
    );
  }
}

class AdminHomeController extends GetxController {
  RxInt index = 0.obs;
  void indexChange(int i) {
    index.value = i;
  }

  String? accessToken; // Instead of: late String accessToken;

  _onWillPop(context) {
    return showDialog(
      builder: (builder) => AlertDialog(
        title: const Text('Are you sure?'),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: redColor),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: redColor),
            onPressed: () => exit(0),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      context: context,
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../../component/colors.dart';

// import 'package:square1_user/ui/constants/constants.dart';

class MaintainanceHomeView extends StatelessWidget {
  MaintainanceHomeView({super.key});
  final controller =
      Get.put<MaintainanceHomeController>(MaintainanceHomeController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.index.value == 0
          ? controller._onWillPop(context)
          : controller.index.value = 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetX<MaintainanceHomeController>(
            init: Get.put<MaintainanceHomeController>(
                MaintainanceHomeController()),
            builder: (controller) => maintainancePages[controller.index.value]),
        bottomNavigationBar: GetX<MaintainanceHomeController>(
          init:
              Get.put<MaintainanceHomeController>(MaintainanceHomeController()),
          builder: (controller) => SalomonBottomBar(
            selectedItemColor: const Color.fromARGB(255, 23, 35, 44),
            items: maintainanceItems,
            currentIndex: controller.index.value,
            onTap: (i) => controller.indexChange(i),
          ),
        ),
      ),
    );
  }
}

class MaintainanceHomeController extends GetxController {
  RxInt index = 0.obs;
  void indexChange(int i) {
    index.value = i;
  }

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

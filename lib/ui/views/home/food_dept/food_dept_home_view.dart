import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../../../component/colors.dart';

class FoodDeptHomeView extends StatelessWidget {
  FoodDeptHomeView({super.key});
  final controller = Get.put<FoodDeptController>(FoodDeptController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.index.value == 0
          ? controller._onWillPop(context)
          : controller.index.value = 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetX<FoodDeptController>(
            init: Get.put<FoodDeptController>(FoodDeptController()),
            builder: (controller) => foodDeptPages[controller.index.value]),
        bottomNavigationBar: GetX<FoodDeptController>(
          init: Get.put<FoodDeptController>(FoodDeptController()),
          builder: (controller) => SalomonBottomBar(
            selectedItemColor: const Color.fromARGB(255, 23, 35, 44),
            items: foodDeptItems,
            currentIndex: controller.index.value,
            onTap: (i) => controller.indexChange(i),
          ),
        ),
      ),
    );
  }
}

class FoodDeptController extends GetxController {
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

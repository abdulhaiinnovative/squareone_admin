// lib/ui/views/forms/add_dept_employee/add_dept_employee_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/dropdown_feild.dart';
import '../../../component/text_feilds.dart';
import 'add_depart_for_employee_controller.dart';


class AddDepartView extends StatelessWidget {
  const AddDepartView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Header Background Image
            Column(
              children: [
                Container(
                  width: width,
                  height: height / 4,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/home/DSC_8735.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.black.withOpacity(0.6),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: Text(
                        'Add Department',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // White Form Container
            Container(
              margin: EdgeInsets.only(top: height * 0.2),
              width: width,
              height: height / 1.3,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: GetBuilder<AddDeptForEmployeeController>(
                init: Get.put(AddDeptForEmployeeController()),
                builder: (controller) {
                  return SingleChildScrollView(
                    // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Name
                        textField('Department Name', controller.departmentNameController),



                        // Submit Button
                        Obx(
                              () => controller.isLoading.value
                              ? const Center(
                            child: CircularProgressIndicator(
                              color: redColor,
                            ),
                          )
                              : LoginButton(
                            width: width+100,
                            height: height,
                            function: controller.addDepartment,
                            text: 'Add Department',
                          ),
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
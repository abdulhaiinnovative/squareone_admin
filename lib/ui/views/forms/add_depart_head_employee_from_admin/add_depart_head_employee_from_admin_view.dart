// lib/ui/views/forms/add_dept_employee/add_dept_employee_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/dropdown_feild.dart';
import '../../../component/text_feilds.dart';
import 'add_depart_head_employee_from_admin_controller.dart';


class AddDepartHeadEmployeeFromAdminView extends StatelessWidget {
  const AddDepartHeadEmployeeFromAdminView({super.key});

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
                        'Add Employee',
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
              child: GetBuilder<AddDepartHeadEmployeeFromAdminController>(
                init: Get.put(AddDepartHeadEmployeeFromAdminController()),
                builder: (controller) {
                  return SingleChildScrollView(
                    // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Name
                        textField('Employee Name', controller.nameController),

                        // Email
                        textField(
                          'Email',
                          controller.emailController,
                          isEmail: true,
                        ),

                        // Phone Number
                        countFeild(
                          'Contact Number',
                          controller.phoneController,
                          11,
                          isKeyboard: true,
                        ),
                        // Password
                        PasswordFeild(
                          name: 'Password',
                          controller: controller.passwordController,
                        ),

                        // Role Selection
                        dropDown(
                          'Role',
                          items: ['employee', 'head']
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role == 'head' ? 'Department Head' : 'Employee',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedRole.value = value;
                            }
                          },
                        ),
                        dropDown(
                          'Department',
                          items: controller.departmentsList
                              .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedDepartment.value = value;
                            }
                          },
                        ),
                        // Obx(() {
                        //   if (controller.departmentsList.isEmpty) {
                        //     return const CircularProgressIndicator();
                        //   }
                        //
                        //   return DropdownButtonFormField<String>(
                        //     value: controller.selectedDepartment.value,
                        //     decoration: const InputDecoration(
                        //       labelText: 'Select Department',
                        //       border: OutlineInputBorder(),
                        //     ),
                        //     items: controller.departmentsList
                        //         .map((dept) => DropdownMenuItem(
                        //       value: dept,
                        //       child: Text(dept),
                        //     ))
                        //         .toList(),
                        //     onChanged: (value) {
                        //       if (value != null) {
                        //         controller.selectedDepartment.value = value;
                        //       }
                        //     },
                        //   );
                        // }),




                        // Shift Date
                        textField(
                          'Shift Date (YYYY-MM-DD)',
                          controller.shiftDateController,
                          readOnly: true,
                          onTap: () => controller.pickShiftDate(context),
                        ),


                        // Shift Start Time
                        textField(
                          'Shift Start Time (HH:MM)',
                          controller.shiftStartController,
                          readOnly: true,
                          onTap: () => controller.pickShiftStartTime(context),
                        ),


                        // Shift End Time
                        textField(
                          'Shift End Time (HH:MM)',
                          controller.shiftEndController,
                          readOnly: true,
                          onTap: () => controller.pickShiftEndTime(context),
                        ),


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
                            function: controller.addEmployee,
                            text: 'Add ${controller.selectedRole.value == 'head' ? 'Head' : 'Employee'}',
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
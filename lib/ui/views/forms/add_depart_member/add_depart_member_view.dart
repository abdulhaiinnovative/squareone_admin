import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/dropdown_feild.dart';
import 'package:squareone_admin/ui/component/text_feilds.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_member/add_depart_controller.dart';

class AddDepartmentView extends StatelessWidget {
  const AddDepartmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: width,
                  height: height / 4,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/home/DSC_8735.png'),
                          fit: BoxFit.cover)),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.black.withOpacity(0.6),
                    child: const Text(
                      '   Add Member',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(child: Container(color: Colors.white)),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.2),
              // width: width,
              width: width,
              height: height / 1.3,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                color: Colors.white,
              ),
              child: GetBuilder<AddDepartmentController>(
                  init: Get.put<AddDepartmentController>(
                      AddDepartmentController()),
                  builder: (controller) {
                    return SingleChildScrollView(
                      physics: const RangeMaintainingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          textField('Name', controller.nameController),
                          dropDown(
                            'Department Type',
                            items: controller.outletItems,
                            onChanged: (String? value) {
                              controller.selectedOutlet = value;
                            },
                          ),
                          countFeild('Contact Number',
                              controller.contactController, 11,
                              isKeyboard: true),
                          textField('Email', controller.emailController,
                              isEmail: true),
                          PasswordFeild(
                              name: 'Password',
                              controller: controller.passwordController),
                          Obx(
                            () => controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: redColor,
                                  )
                                : LoginButton(
                                    width: width + 100,
                                    height: height,
                                    function: () => controller.addDepart(),
                                    text: 'Add Department',
                                  ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

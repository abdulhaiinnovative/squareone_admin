import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/text_feilds.dart';
import 'package:squareone_admin/ui/views/forms/add_outlet/add_outlet_controller.dart';

import '../../../component/dropdown_feild.dart';

class AddOutletView extends StatelessWidget {
  const AddOutletView({super.key});

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
                      '   Add Outlet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(child: Container(color: Colors.white)),
              ],
            ),
            Positioned(
                top: height * 0.2,
                child: Container(
                  width: width,
                  height: height / 1.3,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: GetBuilder<AddOutletController>(
                      init: Get.put<AddOutletController>(AddOutletController()),
                      builder: (controller) {
                        return SingleChildScrollView(
                          physics: const RangeMaintainingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              textField(
                                  'Outlet Name', controller.nameControler),
                              textField('POC', controller.pocController),
                              countFeild('Contact Number',
                                  controller.contactController, 11,
                                  isKeyboard: true),
                              dropDown(
                                'Outlet Type',
                                items: controller.outletItems,
                                onChanged: (String? value) {
                                  controller.selectedOutlet = value;
                                },
                              ),
                              textField('Email', controller.emailController),
                              PasswordFeild(
                                name: 'Password',
                                controller: controller.passwordController,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom /
                                        1.4,
                              ),
                              Obx(
                                () => controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: redColor,
                                      )
                                    : LoginButton(
                                        width: width,
                                        height: height,
                                        function: () => controller.addOutlet(),
                                        text: 'Add Outlet',
                                      ),
                              )
                            ],
                          ),
                        );
                      }),
                )),
          ],
        ),
      ),
    );
  }
}

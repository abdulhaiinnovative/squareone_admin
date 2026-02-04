import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/buttons.dart';
import '../../component/colors.dart';
import '../../component/text_feilds.dart';
import 'auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width,
                  height: height / 3,
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      image: DecorationImage(
                          image: AssetImage('assets/home/DSC_8735.png'),
                          fit: BoxFit.cover)),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '\n\n   Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          '        Enter your details below to log in',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: height / 4,
              child: Container(
                  width: width,
                  height: height / 1.34,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: GetBuilder<LoginController>(
                      init: Get.put<LoginController>(LoginController()),
                      builder: (controller) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.09),
                            textField('Email', controller.emailController,
                                isEmail: true),
                            PasswordFeild(
                              name: 'Password',
                              controller: controller.passwordController,
                            ),
                            SizedBox(height: height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Forget Password?',
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF858597)),
                                ),
                                SizedBox(width: width / 14)
                              ],
                            ),
                            Obx(() => controller.isloading.value
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: redColor,
                                  ))
                                : LoginButton(
                                    width: width,
                                    height: height,
                                    function: () => controller.login(),
                                  )),
                          ],
                        );
                      })),
            ),
          ],
        ),
      ),
    );
  }
}

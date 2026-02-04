import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/splash/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<SplashController>(
          init: SplashController(),
          builder: (controller) {
            Get.put(SplashController());
            return Container(
              width: width,
              height: height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/splash/DSC_8729.png',
                    ),
                    fit: BoxFit.cover),
              ),
              child: Container(
                width: width,
                height: height,
                color: Colors.black.withOpacity(0.55),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Spacer(),
                    const Spacer(),
                    Container(
                      margin: EdgeInsets.only(left: width * 0.05),
                      height: height / 8,
                      alignment: Alignment.center,
                      width: width / 1.2,
                      child: Stack(
                        children: [
                          // AnimatedTextKit(
                          // animatedTexts: [
                          // TypewriterAnimatedText(
                          const Text(
                            'The Technology You\n    Need to Succeed.',
                            textAlign: TextAlign.center,
                            // speed: const Duration(milliseconds: 25),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w400),
                          ),
                          Positioned(
                            top: height * 0.04,
                            left: width * 0.02,
                            child: SizedBox(
                                width: 70,
                                child: SvgPicture.asset(
                                    'assets/splash/logo-strike.svg')),
                          ),
                        ],
                        // pause: const Duration(seconds: 1),
                        // totalRepeatCount: 1,
                      ),
                    ),
                    const Spacer(),
                    !controller.isloadin.value
                        // ignore: prefer_const_constructors
                        ? SizedBox(height: 0)
                        : const CircularProgressIndicator(
                            color: redColor,
                          ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

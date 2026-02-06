import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squareone_admin/firebase_options_dev.dart';
import 'package:squareone_admin/ui/env.dart';
import 'package:squareone_admin/ui/views/splash/splash_view.dart';
import 'package:squareone_admin/ui/views/home/head/user_controller.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';
import 'firebase_options.dart';

Future<void> backgroundHandler(RemoteMessage message) async {}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: AppEnv.isProd?
  DefaultFirebaseOptions.currentPlatform
  : DefaultFirebaseOptionsDev.currentPlatform);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  
  // Initialize GetX Controllers
  Get.put<UserController>(UserController(), permanent: true);
  Get.put<ShiftController>(ShiftController(), permanent: true);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: Color(0xFFB71C1C),
        fontFamily: 'Poppins',
      ),
      home: const SplashView(),
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
        );
      },
    );
  }
}


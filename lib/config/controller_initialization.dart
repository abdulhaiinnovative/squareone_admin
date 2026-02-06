import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/controllers/user_controller.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';
import 'package:squareone_admin/controllers/department_controller.dart';

/// Initialize all GetX controllers for the application
/// This should be called in main() before running the app
class ControllerInitialization {
  /// Initialize all controllers
  static Future<void> initializeControllers() async {
    try {
      // Initialize UserController
      Get.put<UserController>(
        UserController(),
        permanent: true,
      );

      // Initialize ShiftController
      Get.put<ShiftController>(
        ShiftController(),
        permanent: true,
      );

      // Initialize DepartmentController
      Get.put<DepartmentController>(
        DepartmentController(),
        permanent: true,
      );

      print('✓ All controllers initialized successfully');
    } catch (e) {
      print('✗ Error initializing controllers: $e');
      rethrow;
    }
  }

  /// Initialize Firebase Messaging
  static Future<void> initializeFirebaseMessaging() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  /// Initialize system UI overlays
  static void initializeSystemUI() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }

  /// Reset all controllers (useful for logout)
  static Future<void> resetControllers() async {
    try {
      Get.delete<UserController>();
      Get.delete<ShiftController>();
      Get.delete<DepartmentController>();
      print('✓ All controllers reset');
    } catch (e) {
      print('✗ Error resetting controllers: $e');
    }
  }

  /// Dispose all controllers
  static void disposeControllers() {
    try {
      Get.find<UserController>().onClose();
      Get.find<ShiftController>().onClose();
      Get.find<DepartmentController>().onClose();
      print('✓ All controllers disposed');
    } catch (e) {
      print('✗ Error disposing controllers: $e');
    }
  }
}

/// App Initialization Wrapper
/// Call this in main() to initialize everything
Future<void> initializeApp() async {
  try {
    // Initialize controllers
    await ControllerInitialization.initializeControllers();

    // Initialize Firebase Messaging
    await ControllerInitialization.initializeFirebaseMessaging();

    // Initialize System UI
    ControllerInitialization.initializeSystemUI();

    print('✓ App initialized successfully');
  } catch (e) {
    print('✗ Error during app initialization: $e');
    rethrow;
  }
}

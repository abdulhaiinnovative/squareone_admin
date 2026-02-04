import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationController extends GetxController {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  RxString permission = ''.obs;
  GetStorage storage = GetStorage();
  String email = '';
  @override
  void onReady() {
    email = storage.read('email');
    getNotifications();
  }

  getNotifications() {
    firebaseFirestore
        .collection('Depart Members')
        .doc(email)
        .get()
        .then((value) {
      permission.value = value.data()!['Department'];
    });
  }
}

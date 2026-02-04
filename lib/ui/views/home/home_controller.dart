import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  GetStorage storage = GetStorage();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String email = '';
  RxString name = ''.obs;
  @override
  void onInit() {
    // email = storage.read('email');
    firebaseFirestore
        .collection('Depart Members')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      name.value = value.data()!['Name'];
    });
    super.onInit();
  }
}

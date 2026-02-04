import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../splash/splash_view.dart';

class ProfileController extends GetxController {
  GetStorage storage = GetStorage();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  RxInt index = 0.obs;
  String email = '';
  RxString name = ''.obs;
  RxString depart = ''.obs;
  RxBool grant = false.obs;

  @override
  void onInit() {
    email = storage.read('email');
    firebaseFirestore
        .collection('Depart Members')
        .doc(email)
        .get()
        .then((value) {
      switch (value.data()!['Department']) {
        case 'Security':
        case 'CR':
        case 'Maintainance':
          index.value = 2;
          grant.value = false;
          break;
        case 'Marketing':
          index.value = 3;
          grant.value = false;
          break;
        case 'Food Court':
          index.value = 3;
          grant.value = false;
          break;
        case 'Operations':
        case 'Admin':
          index.value = 5;
          grant.value = false;
      }
      name.value = value.data()!['Name'];
      depart.value = value.data()!['Department'];
    });
    super.onInit();
  }

  signOut() async {
    await FirebaseFirestore.instance
        .collection('Depart Members')
        .doc(email)
        .update({'token': ""});
    FirebaseAuth.instance.signOut().whenComplete(() {
      GetStorage storage = GetStorage();
      storage.write('email', '');
      storage
          .write('password', '')
          .whenComplete(() => Get.offAll(() => const SplashView()));
    });
  }
}

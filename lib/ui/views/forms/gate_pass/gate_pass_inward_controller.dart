import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:squareone_admin/ui/views/home/admin/admin_home_view.dart';
import 'package:uuid/uuid.dart';

import '../../../component/dialog.dart';
import '../add_notification/add_notifications_controller.dart';

class GatePassInwardController extends GetxController {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  TextEditingController quantityController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  String name = "";
  TextEditingController contactController = TextEditingController();
  TextEditingController pocController = TextEditingController();
  Rx<TextEditingController> timeInput = TextEditingController().obs;
  Rx<TextEditingController> dateInput = TextEditingController().obs;
  RxString selectedPartiular = ''.obs;
  RxString selectedOutlet = ''.obs;
  String? selectedType;
  RxBool isloading = false.obs;
  final uuid = const Uuid();
  String outletToken = '';
  String outletUid = '';
  GetStorage storage = GetStorage();

  @override
  void onReady() {
    name = storage.read('name');
  }

  List<DropdownMenuItem<String>> get particularItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Stock", child: Text("Stock")),
      const DropdownMenuItem(value: "Material", child: Text("Material")),
      const DropdownMenuItem(value: "Other", child: Text("Other")),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get typeItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Cartons", child: Text("Cartons")),
      const DropdownMenuItem(value: "Loose", child: Text("Loose")),
      const DropdownMenuItem(value: "Bags", child: Text("Bags")),
    ];
    return menuItems;
  }

  pickTime(context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (pickedTime != null) {
      String formattedTime = DateFormat('h:mma')
          .format(DateFormat.jm().parse(pickedTime.format(context).toString()));

      timeInput.value.text = formattedTime;
    } else {}
  }

  pickDate(context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      dateInput.value.text = formattedDate;
    } else {}
  }

  createTicket({String collectionName = 'Gate-Pass-Inward'}) async {
    String ticketId = uuid.v4();
    await firebaseFirestore
        .collection('Outlets')
        .where('Outlet Name', isEqualTo: selectedOutlet.value)
        .get()
        .then((value) {
      outletUid = value.docs[0].data()['uid'];
      outletToken = value.docs[0].data()['token'];
    });

    if ((selectedType != null) &
        quantityController.text.isNotEmpty &
        contactController.text.isNotEmpty &
        timeInput.value.text.isNotEmpty &
        dateInput.value.text.isNotEmpty &
        pocController.text.isNotEmpty) {
      isloading.value = true;

      if ((selectedPartiular.value == 'Other') &
          itemController.text.isNotEmpty) {
        await firebaseFirestore
            .collection('Emergency Tickets')
            .doc(ticketId)
            .set({
          'Department': 'Security',
          'Outlet Name': selectedOutlet,
          'Item': itemController.text,
          'header': collectionName,
          'Partiular': selectedPartiular.value,
          'Type': selectedType,
          'Quantity': quantityController.text.trim(),
          'Contact': contactController.text.trim(),
          'Time': timeInput.value.text.trim(),
          'Date': dateInput.value.text.trim(),
          'POC': pocController.text.trim(),
          'Opened By': name,
          'Status': 'Urgent Approved',
          'User ID': outletUid,
          'Creation Time': Timestamp.now(),
          'Approval Time': Timestamp.now(),
          'Apprved By': name,
          'Ticket Number': ticketId,
        }).whenComplete(() async {
          sendMessage(outletToken, collectionName, 'Urgent Ticket Granted');

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('Depart Members')
              .where('Department', isNotEqualTo: 'Maintainance')
              .get();
          for (int i = 0; i < querySnapshot.docs.length; i++) {
            var a = querySnapshot.docs[i];
            await sendMessage(a.get('token'), "$collectionName Ticket",
                "Urgent ${selectedOutlet.value} Ticket");
          }

          quantityController.clear();
          itemController.clear();
          contactController.clear();
          timeInput.value.clear();
          dateInput.value.clear();
          isloading.value = false;
          getDialog(
                  title: 'Success',
                  desc: 'Your Ticket Has Been Created Successfully')
              .then((value) => Get.offAll(() => AdminHomeView()));
        });
      } else if (selectedPartiular.value != 'Other') {
        await firebaseFirestore
            .collection('Emergency Tickets')
            .doc(ticketId)
            .set({
          'Department': 'Security',
          'Outlet Name': selectedOutlet.value,
          'Item': itemController.text,
          'header': collectionName,
          'Partiular': selectedPartiular.value,
          'Type': selectedType,
          'Quantity': quantityController.text.trim(),
          'Contact': contactController.text.trim(),
          'Time': timeInput.value.text.trim(),
          'Date': dateInput.value.text.trim(),
          'POC': pocController.text.trim(),
          'Opened By': name,
          'Status': 'Urgent Approved',
          'User ID': outletUid,
          'Creation Time': Timestamp.now(),
          'Approval Time': Timestamp.now(),
          'Apprved By': name,
          'Ticket Number': ticketId,
        }).whenComplete(() async {
          sendMessage(outletToken, collectionName, 'Urgent Ticket Granted');
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('Depart Members')
              .where('Department', isNotEqualTo: 'Maintainance')
              .get();
          for (int i = 0; i < querySnapshot.docs.length; i++) {
            var a = querySnapshot.docs[i];
            await sendMessage(a.get('token'), "$collectionName Ticket",
                "Urgent ${selectedOutlet.value} Ticket");
          }

          quantityController.clear();
          itemController.clear();
          contactController.clear();
          timeInput.value.clear();
          dateInput.value.clear();
          isloading.value = false;
          getDialog(
                  title: 'Success',
                  desc: 'Your Ticket Has Been Created Successfully')
              .then((value) => Get.offAll(() => AdminHomeView()));
        });
      } else {
        isloading.value = false;

        Get.showSnackbar(const GetSnackBar(
          title: 'Fill All Feilds.',
          message: 'All feilds are mandatory',
          duration: Duration(seconds: 3),
        ));
      }
    } else {
      isloading.value = false;

      Get.showSnackbar(const GetSnackBar(
        title: 'Fill All Feilds.',
        message: 'All feilds are mandatory',
        duration: Duration(seconds: 2),
      ));
    }
  }
}

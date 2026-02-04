import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:squareone_admin/ui/component/text_feilds.dart';
import 'package:squareone_admin/ui/views/home/maintainance/maintainance_home_view.dart';

import '../../component/colors.dart';
import '../../component/dialog.dart';
import '../forms/add_notification/add_notifications_controller.dart';
import '../home/admin/admin_home_view.dart';
import '../home/marketing/marketing_home_view.dart';

class TicketController extends GetxController {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  RxString depart = ''.obs;
  RxBool isLoading = false.obs;
  GetStorage storage = GetStorage();
  String email = '';
  String name = '';
  RxBool showCloseButton = false.obs;
  RxString filter = ''.obs;
  RxString formattedDate = "".obs;
  RxBool showButton = false.obs;
  TextEditingController dissmissController = TextEditingController();

  RxList selectedItems = <String>[].obs;
  RxBool selectionMode = false.obs;
  void toggleSelection(String itemId) {
    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }
    if (selectedItems.isEmpty) {
      selectionMode.value = false;
    }
    debugPrint(selectedItems.toString());
  }

  void enableSelectionMode(String itemId) {
    selectionMode.value = true;
    selectedItems.add(itemId);
    debugPrint(selectedItems.toString());
  }

  void clearSelection() {
    selectedItems.clear();
    selectionMode.value = false;
  }

  @override
  void onReady() {
    email = storage.read('email');
    name = storage.read('name');
    getDepart(email);
  }

  getDepart(email) async {
    await firebaseFirestore
        .collection('Depart Members')
        .doc(email)
        .get()
        .then((value) {
      depart.value = value.data()!['Department'];
      print(depart.value);
      switch (value.data()!['Department']) {
        case 'Security':
        case 'CR':
        case 'Maintainance':
        case 'Marketing':
          showButton.value = false;
          showCloseButton.value = false;
          break;
        case 'Operations':
        case 'Admin':
          showButton = true.obs;
          showCloseButton.value = true;
          break;
      }
    });
  }

  approveTicket(uid, ticketId, header, outlet, ticketNoti, String reason) {
    if (depart.value == "Marketing") {
      approveMarketingTicket(outlet, ticketId, header, ticketNoti, reason);
    } else {
      isLoading.value = true;

      firebaseFirestore.collection('Tickets').doc(ticketId).update({
        'Status': 'Approved',
        'Approval Time': Timestamp.now(),
        'Approved By': name,
        'Reason': reason,
      }).whenComplete(() {
        FirebaseFirestore.instance
            .collection('Outlets')
            .where('uid', isEqualTo: uid)
            .get()
            .then((value) {
          for (var i in value.docs[0].get('token')) {
            sendMessage(i, '$header  Approved',
                'Your ticket has been approved.', ticketNoti);
          }
        });

        isLoading = false.obs;
        getDialog(title: 'Success', desc: 'Ticket Approved Successfully')
            .then((value) {
          switch (depart.value) {
            case "Maintainance":
              Get.offAll(() => MaintainanceHomeView());
              break;

            case 'Operations':
            case 'Admin':
              Get.offAll(() => AdminHomeView());
              break;
            case 'Marketing':
              Get.offAll(() => MarketingHomeView());
              break;
          }
        });
      });
    }
  }

  getDismissDialog(
      {width, height, uid, ticketId, header, ticketNoti, String reason = ''}) {
    Get.defaultDialog(
      title: '',
      titleStyle: const TextStyle(fontSize: 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          textField('Reason Of Dismissal', dissmissController),
          Padding(
            padding: EdgeInsets.only(left: width * 0.24, right: width * 0.24),
            child: ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(redColor)),
              onPressed: () {
                dissmissController.text.isNotEmpty
                    ? dismissTicket(uid, ticketId, header, ticketNoti, reason)
                    : null;
              },
              child: const Text(
                'Dismiss',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getApproveDialog(
      {width,
      height,
      uid,
      ticketId,
      header,
      outlet,
      ticketNoti,
      String reason = ''}) {
    TextEditingController approveReasonController = TextEditingController();
    Get.defaultDialog(
      title: '',
      titleStyle: const TextStyle(fontSize: 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          textField('Reason For Approval', approveReasonController),
          Padding(
            padding: EdgeInsets.only(left: width * 0.24, right: width * 0.24),
            child: ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green)),
              onPressed: () {
                if (approveReasonController.text.isNotEmpty) {
                  approveTicket(uid, ticketId, header, outlet, ticketNoti,
                      approveReasonController.text);
                }
              },
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  dismissTicket(uid, ticketId, header, ticketNoti, String reason) {
    isLoading.value = true;
    Get.back();

    firebaseFirestore.collection('Tickets').doc(ticketId).update({
      'Status': 'Dissmissed',
      'Dissmissal Time': Timestamp.now(),
      'Dismiss': dissmissController.text,
      'Dismissed By': name,
      'Reason': reason,
    }).whenComplete(() {
      FirebaseFirestore.instance
          .collection('Outlets')
          .where('uid', isEqualTo: uid)
          .get()
          .then((value) {
        for (var i in value.docs[0].get('token')) {
          sendMessage(i, '$header  Dismissed',
              'Your ticket has been dismissed.', ticketNoti);
        }
      });

      firebaseFirestore
          .collection('Depart Member')
          .where('Department', isEqualTo: "Operations")
          .get()
          .then((departToken) {
        for (int i = 0; i < departToken.docs.length; i++) {
          var a = departToken.docs[i];
          sendMessage(a.get('token'), '$header  Dismissed',
              '${a.get("Outlet Name")} ticket has been dismissed.', ticketNoti);
        }
      });
      firebaseFirestore
          .collection('Depart Member')
          .where('Department', isEqualTo: "Admin")
          .get()
          .then((adminToken) {
        for (int i = 0; i < adminToken.docs.length; i++) {
          var a = adminToken.docs[i];
          sendMessage(a.get('token'), '$header  Dismissed',
              '${a.get("Outlet Name")} ticket has been dismissed.', ticketNoti);
        }
      });
      dissmissController.clear();
      isLoading = false.obs;
      getDialog(title: 'Success', desc: 'Ticket Dismissed Successfully')
          .then((value) {
        switch (depart.value) {
          case "Maintainance":
            Get.offAll(() => MaintainanceHomeView());
            break;

          case 'Operations':
          case 'Admin':
            Get.offAll(() => AdminHomeView());
            break;
          case 'Marketing':
            Get.offAll(() => MarketingHomeView());
            break;
        }
      });
    });
  }

  approveMarketingTicket(outlet, ticketId, header, ticketNoti, String reason) {
    isLoading.value = true;

    firebaseFirestore.collection('Tickets').doc(ticketId).update({
      'Status': 'Artwork Approved',
      'Reason': reason,
    }).whenComplete(() {
      firebaseFirestore
          .collection('Depart Members')
          .where("Department", isEqualTo: "Operations")
          .get()
          .then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          var a = value.docs[i];
          sendMessage(a.get('token'), '$header  Approved',
                  '$outlet\'s Artwork has been approved.', ticketNoti)
              .whenComplete(() {
            isLoading = false.obs;
            getDialog(title: 'Success', desc: 'Artwork Approved Successfully')
                .then((value) {
              Get.offAll(() => MarketingHomeView());
            });
          });
        }
        firebaseFirestore
            .collection('Depart Members')
            .where("Department", isEqualTo: "Admin")
            .get()
            .then((value) {
          for (int i = 0; i < value.docs.length; i++) {
            var a = value.docs[i];
            sendMessage(a.get('token'), '$header  Approved',
                    '$outlet\'s Artwork has been approved.', ticketNoti)
                .whenComplete(() {
              isLoading = false.obs;
              getDialog(title: 'Success', desc: 'Artwork Approved Successfully')
                  .then((value) {
                Get.offAll(() => MarketingHomeView());
              });
            });
          }
        });
      });
    });
  }

  closeTicket(ticketId, name, header, uid, ticketNoti, String reason) {
    isLoading.value = true;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    firebaseFirestore.collection('Tickets').doc(ticketId).update({
      'Status': 'Closed',
      'Closing Time': Timestamp.now(),
      "Closed By": name,
      'Reason': reason,
    }).whenComplete(() {
      firebaseFirestore
          .collection('Outlets')
          .where('uid', isEqualTo: uid)
          .get()
          .then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          var a = value.docs[i];
          sendMessage(a.get('token'), '$header  closed',
              'Your ticket has been closed.', ticketNoti);
        }
      });
      isLoading = false.obs;
      getDialog(title: 'Success', desc: 'Ticket Closed Successfully')
          .then((value) {
        Get.back();
      });
    });
  }

  showPicker(context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    ).then((selectedDate) {
      if (selectedDate != null) {
        formattedDate.value = DateFormat('dd-MM-yyyy').format(selectedDate);
      }
    });
  }

}

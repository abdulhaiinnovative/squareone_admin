import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/views/outlets/carton_report.dart';
import 'package:squareone_admin/ui/views/outlets/outlet_controller.dart';

import '../../component/colors.dart';
import '../../component/profile_card.dart';
import '../../component/text_feilds.dart';

class OutletProfileView extends StatelessWidget {
  OutletProfileView({
    super.key,
    required this.email,
    required this.number,
    required this.name,
    required this.depart,
    required this.token,
    required this.password,
    required this.status,
  });
  final String email;
  final String number;
  final List token;
  final String password;
  final bool status;
  final String name;
  final String depart;
  final TextEditingController numCntroller = TextEditingController();
  final TextEditingController nameCntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Outlet Profile',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          status
              ? Container(
                  width: width * 0.11,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: redColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: GetX<OutletController>(
                        init: Get.put<OutletController>(OutletController()),
                        builder: (controller) {
                          return IconButton(
                            onPressed: () async {
                              controller.deleteUser(email, password, token);
                            },
                            icon: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.delete,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                          );
                        }),
                  ),
                )
              : const SizedBox(height: 0),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.1),
                radius: width * 0.18,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.7),
                  radius: width * 0.17,
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            const Center(
              child: Text(
                'Outlet Information',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            MyProfileCards(
              height: height,
              width: width,
              text: name,
              imgUrl: profileCardImages[0],
              function: () {},
            ),
            MyProfileCards(
                height: height,
                width: width,
                text: number,
                imgUrl: profileCardImages[1],
                function: () {
                  numCntroller.text.isEmpty
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                                backgroundColor: Colors.white,
                                children: [
                                  textField('New Number', numCntroller),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: width * 0.25,
                                          right: width * 0.25),
                                      child: ElevatedButton(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    redColor)),
                                        onPressed: () {
                                          numCntroller.text.isNotEmpty
                                              ? FirebaseFirestore.instance
                                                  .collection('Outlets')
                                                  .doc(email)
                                                  .update({
                                                    'Contact Number':
                                                        numCntroller.text,
                                                  })
                                                  .whenComplete(
                                                      () => Get.back())
                                                  .whenComplete(
                                                      () => Get.back())
                                              : null;
                                        },
                                        child: const Text('Update'),
                                      ))
                                ]);
                          })
                      : null;
                }),
            MyProfileCards(
              height: height,
              width: width,
              text: email,
              imgUrl: profileCardImages[2],
              function: () {},
            ),
            MyProfileCards(
              height: height,
              width: width,
              text: depart,
              imgUrl: profileCardImages[0],
              function: () {
                nameCntroller.text.isEmpty
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                              backgroundColor: Colors.white,
                              children: [
                                textField('New POC', nameCntroller),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: width * 0.25,
                                        right: width * 0.25),
                                    child: ElevatedButton(
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(redColor)),
                                      onPressed: () {
                                        nameCntroller.text.isNotEmpty
                                            ? FirebaseFirestore.instance
                                                .collection('Outlets')
                                                .doc(email)
                                                .update({
                                                  'POC': nameCntroller.text,
                                                })
                                                .whenComplete(() => Get.back())
                                                .whenComplete(() => Get.back())
                                            : null;
                                      },
                                      child: const Text('Update'),
                                    ))
                              ]);
                        })
                    : null;
              },
            ),
            MyProfileCards(
                text: 'Carton\'s Report',
                imgUrl: profileCardImages[3],
                function: () {
                  Get.to(() => CartonReport(outletName: name,));
                },
                height: height,
                width: width)
          ]),
        ),
      ),
    );
  }
}

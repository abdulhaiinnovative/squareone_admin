import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';

import '../../component/colors.dart';
import '../../component/profile_card.dart';
import '../../component/text_feilds.dart';

class DepartProfileView extends StatelessWidget {
  DepartProfileView(
      {super.key,
      required this.email,
      required this.number,
      required this.name,
      required this.depart});
  final String email;
  final String number;
  final String name;
  final String depart;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          'Member Profile',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            width: width * 0.11,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: redColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: IconButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('Depart Members')
                      .doc(email)
                      .delete()
                      .whenComplete(() => Get.back());
                },
                icon: const Icon(
                  Icons.delete,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
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
                'Member Information',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            MyProfileCards(
              height: height,
              width: width,
              text: depart,
              imgUrl: profileCardImages[0],
              function: () {},
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
                  controller.text.isEmpty
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                                backgroundColor: Colors.white,
                                children: [
                                  textField('New Number', controller),
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
                                          controller.text.isNotEmpty
                                              ? FirebaseFirestore.instance
                                                  .collection('Depart Members')
                                                  .doc(email)
                                                  .update({
                                                  'Contact Number':
                                                      controller.text,
                                                }).whenComplete(
                                                      () => Navigator.pop)
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
          ]),
        ),
      ),
    );
  }
}

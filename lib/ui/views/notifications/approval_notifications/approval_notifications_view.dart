import 'package:flutter/material.dart';

import '../../../component/notification_approve_tile_detail.dart';

class ApproveNotification extends StatelessWidget {
  const ApproveNotification(
      {super.key,
      required this.title,
      required this.description,
      required this.date});
  final String title;
  final String description;
  final String date;

  static const IconData time = IconData(0xee2d, fontFamily: 'MaterialIcons');

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "  Notification Approval",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ApproveNotificationInfo(
                  accessTimeOutlined: time,
                  size: size,
                  text: title,
                  desc: description,
                  date: date,
                ),
              ],
            ),
          )),
    );
  }
}

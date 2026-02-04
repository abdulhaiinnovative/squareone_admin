import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/notification_tile.dart';
import 'package:squareone_admin/ui/views/forms/add_notification/add_notification_view.dart';
import 'package:squareone_admin/ui/views/notifications/approval_notifications/approval_notifications_view.dart';
import 'package:squareone_admin/ui/views/notifications/notification_detail.dart';
import 'package:squareone_admin/ui/views/notifications/notifications_controller.dart';
import 'package:squareone_admin/ui/views/notifications/sent_notification/sent_notifications.dart';

import '../../component/buttons.dart';
import '../../component/colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    String docId = '';
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          ' Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              width: width,
              height: height * 0.11,
              child: GestureDetector(
                onTap: () => Get.to(
                  () => AddNotification(
                    isEdit: false,
                    docId: docId,
                  ),
                ),
                child: Card(
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('   Create Notification',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      AddButton(
                        height: height,
                        width: width,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          GetX<NotificationController>(
              init: Get.put<NotificationController>(NotificationController()),
              builder: (controller) {
                switch (controller.permission.value) {
                  case "Operations":
                  case "Admin":
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            width: width,
                            height: height * 0.11,
                            child: GestureDetector(
                              onTap: () =>
                                  Get.to(() => const SentNotifications()),
                              child: Card(
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 12,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('   Sent Notifications',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    ArrowButton(
                                      height: height,
                                      width: width,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          '\n     Pending Notifications',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    );

                  default:
                    return const SizedBox(
                      height: 0,
                    );
                }
              }),
          GetX<NotificationController>(
              init: Get.put<NotificationController>(NotificationController()),
              builder: (controller) {
                switch (controller.permission.value) {
                  case "Operations":
                  case "Admin":
                    return Expanded(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Approval-Notification')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                            return !asyncSnapshot.hasData
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: redColor),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: asyncSnapshot.data!.docs.length,
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final Timestamp timestamp = asyncSnapshot
                                          .data!
                                          .docs[index]['time'] as Timestamp;
                                      final DateTime dateTime =
                                          timestamp.toDate();

                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(() => ApproveNotification(
                                                title: asyncSnapshot.data!
                                                    .docs[index]['subject'],
                                                description: asyncSnapshot.data!
                                                    .docs[index]['description'],
                                                date:
                                                    '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                                              ));
                                        },
                                        child: NotificationsTile(
                                          width: width,
                                          height: height,
                                          text: asyncSnapshot.data!.docs[index]
                                              ['subject'],
                                          date:
                                              '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                                        ),
                                      );
                                    });
                          }),
                    );
                  case "Maintainance":
                  case "Marketing":
                  case "Security":
                  case 'CR':
                  case "Food Court":
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '\n     Sent Notifications',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(
                          height: height / 1.8,
                          width: width,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Notification')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                                return !asyncSnapshot.hasData
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: redColor))
                                    : ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount:
                                            asyncSnapshot.data!.docs.length,
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10, right: 10),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final Timestamp timestamp =
                                              asyncSnapshot.data!.docs[index]
                                                  ['time'] as Timestamp;
                                          final DateTime dateTime =
                                              timestamp.toDate();
                                          //  ));

                                          return GestureDetector(
                                            onTap: () {
                                              docId = asyncSnapshot
                                                  .data!.docs[index].id;
                                              Get.to(() => NotificationDetail(
                                                    title: asyncSnapshot.data!
                                                        .docs[index]['subject'],
                                                    description: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['description'],
                                                    date:
                                                        '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                                                    file: asyncSnapshot.data
                                                                ?.docs[index]
                                                            ['file'] ??
                                                        null,
                                                    docId: asyncSnapshot
                                                        .data!.docs[index].id,
                                                  ));
                                            },
                                            child: NotificationsTile(
                                              width: width,
                                              height: height,
                                              text: asyncSnapshot
                                                  .data!.docs[index]['subject'],
                                              date:
                                                  '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                                            ),
                                          );
                                        });
                              }),
                        ),
                      ],
                    );
                  default:
                    return Center(
                        child:
                            const CircularProgressIndicator(color: redColor));
                }
              })
        ],
      ),
    );
  }
}

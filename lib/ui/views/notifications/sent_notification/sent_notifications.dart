import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../component/colors.dart';
import '../../../component/notification_tile.dart';
import '../notification_detail.dart';

class SentNotifications extends StatelessWidget {
  const SentNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          ' Sent Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Notification')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          return !asyncSnapshot.hasData
              ? const Center(child: CircularProgressIndicator(color: redColor))
              : ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: asyncSnapshot.data!.docs.length,
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final Timestamp timestamp =
                        asyncSnapshot.data!.docs[index]['time'] as Timestamp;
                    final DateTime dateTime = timestamp.toDate();

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => NotificationDetail(
                            title: asyncSnapshot.data!.docs[index]['subject'],
                            description: asyncSnapshot.data!.docs[index]
                                ['description'],
                            date:
                                '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                            file:
                                asyncSnapshot.data?.docs[index]['file'] != null
                                    ? (asyncSnapshot.data?.docs[index]['file']
                                                as Map?)
                                            ?.cast<String, String>() ??
                                        null
                                    : null,
                            docId: asyncSnapshot.data!.docs[index].id,
                          ),
                        );
                      },
                      child: NotificationsTile(
                        width: width,
                        height: height,
                        text: asyncSnapshot.data!.docs[index]['subject'],
                        date:
                            '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

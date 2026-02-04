import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/views/forms/add_notification/add_notifications_controller.dart';

import 'buttons.dart';
import 'colors.dart';

class ApproveNotificationTile extends StatelessWidget {
  const ApproveNotificationTile({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
    required this.date,
    required this.body,
  }) : super(key: key);

  final double width;
  final double height;
  final String text;
  final String body;
  static const IconData time = IconData(0xee2d, fontFamily: 'MaterialIcons');

  final String date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width / 1.1,
      height: height / 6.8,
      child: Card(
                      surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const NotificationsButton(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.6,
                        child: Text(
                          text,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            time,
                            color: Color(0xFFB8B8D2),
                            size: 12,
                          ),
                          Text(
                            date.toString(),
                            style: const TextStyle(color: Color(0xFFB8B8D2)),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              GetBuilder<AddNotificationsController>(
                  init: Get.put<AddNotificationsController>(
                      AddNotificationsController()),
                  builder: (controller) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            controller.isSending.value = true;
                            controller.titleController.text = text;
                            controller.bodyController.text = body;
                            await controller.sendNotifications();
                            controller.isSending.value = false;
                            controller.delete(text);
                          },
                          child: Obx(() => !controller.isSending.value
                              ? const Text(
                                  'Approve',
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 14),
                                )
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: redColor,
                                  ),
                                )),
                        ),
                        GestureDetector(
                          onTap: () => controller.delete(text),
                          child: const Text(
                            '      Decline',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}

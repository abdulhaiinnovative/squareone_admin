import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/forms/add_notification/add_notifications_controller.dart';
import 'colors.dart';

class ApproveNotificationInfo extends StatelessWidget {
  const ApproveNotificationInfo({
    Key? key,
    required this.size,
    required this.accessTimeOutlined,
    required this.text,
    required this.desc,
    required this.date,
  }) : super(key: key);

  final Size size;
  final String text;
  final String desc;
  final String date;

  final IconData accessTimeOutlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width / 1.1,
      child: Card(
                      surfaceTintColor: Colors.transparent,

        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: redColor,
                              borderRadius: BorderRadius.circular(12)),
                          width: 48,
                          height: 48,
                          child: const Center(
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 25,
                            ),
                          )),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: size.width * 0.57,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                accessTimeOutlined,
                                color: const Color(0xFFB8B8D2),
                                size: 12,
                              ),
                              Text(
                                date.toString(),
                                style:
                                    const TextStyle(color: Color(0xFFB8B8D2)),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: size.width / 1.3,
                child: Text(desc, style: const TextStyle(fontSize: 13.5)),
              ),
              GetBuilder<AddNotificationsController>(
                  init: Get.put<AddNotificationsController>(
                      AddNotificationsController()),
                  builder: (controller) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            controller.isSending.value = true;
                            controller.titleController.text = text;
                            controller.bodyController.text = desc;
                            await controller.approveNotification();
                            controller.isSending.value = false;
                            await controller.delete(text);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
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
                        ),
                        GestureDetector(
                          onTap: () async {
                            await controller.delete(text);
                            Get.back();
                            // Get.offAll(() => const NotificationsView());
                          },
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

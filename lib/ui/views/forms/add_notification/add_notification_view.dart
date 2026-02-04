import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/dotted_border_button.dart';

import '../../../component/text_feilds.dart';
import 'add_notifications_controller.dart';

class AddNotification extends StatelessWidget {
  final bool isEdit;
  final String docId;
  const AddNotification({super.key, required this.isEdit, required this.docId});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: width,
                  height: height / 4,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/home/DSC_8735.png'),
                          fit: BoxFit.cover)),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\n   Notifications',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                            Text(
                              '      Custom Notifications for Client App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(child: Container(color: Colors.white)),
              ],
            ),
            Positioned(
              top: height * 0.2,
              child: Container(
                width: width,
                height: height / 1.1,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: Colors.white,
                ),
                child: GetBuilder<AddNotificationsController>(
                    init: Get.put<AddNotificationsController>(
                        AddNotificationsController()),
                    builder: (controller) {
                      return Column(
                        children: [
                          SizedBox(height: height * 0.02),
                          textField(
                            'Subject',
                            controller.titleController,
                          ),
                          descFeild(
                            'Description',
                            maxLines: 5,
                            controller.bodyController,
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    textAlign: TextAlign.start,
                                    'Attachment (Optional)',
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF858597)),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Obx(
                                    () => (controller.fileName?.value == null ||
                                            controller.fileName?.value == '')
                                        ? DottedButton(
                                            loading:
                                                controller.pickerLoading.value,
                                            text: 'Attach File',
                                            onPressed: controller.pickFile,
                                          )
                                        // : Text(
                                        //     controller.selectedFile.value!.path
                                        //         .split('/')
                                        //         .last,
                                        //     style: const TextStyle(
                                        //         fontSize: 14,
                                        //         color: Color(0xFF858597)),
                                        //   ),
                                        : Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Color(0xFF858597),
                                              ),
                                            ),
                                            constraints: BoxConstraints(
                                              maxWidth: width * 0.8,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    controller.fileName!.value,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF858597),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                InkWell(
                                                    onTap: () {
                                                      controller
                                                          .fileName!.value = '';
                                                      controller
                                                          .fileUrl!.value = '';
                                                      controller.selectedFile
                                                          .value = null;
                                                    },
                                                    child: Icon(Icons.cancel)),
                                              ],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 24, right: 24, top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: redColor,
                                        )
                                      : LoginButton(
                                          width: width,
                                          height: height,
                                          function: () => isEdit
                                              ? controller
                                                  .updateNotification(docId)
                                              : controller.sendNotifications(),
                                          text: 'Submit',
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

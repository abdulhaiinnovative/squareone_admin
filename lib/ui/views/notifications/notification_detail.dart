import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/dialog.dart';
import 'package:squareone_admin/ui/views/forms/add_notification/add_notification_view.dart';
import 'package:squareone_admin/ui/views/forms/add_notification/add_notifications_controller.dart';
import '../../component/notification_info.dart';

class NotificationDetail extends StatefulWidget {
  const NotificationDetail({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.file,
    required this.docId,
  });
  final String title, description, date, docId;

  final Map<String, String>? file;

  static const IconData time = IconData(0xee2d, fontFamily: 'MaterialIcons');

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  Future<void> downloadAndSaveFile(String url, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  final dio = Dio();
  try {
    final response = await dio.get(url, options: Options(responseType: ResponseType.bytes));
    final file = File(filePath);
    await file.writeAsBytes(response.data);
    await Share.shareXFiles([XFile(filePath)], text: 'Save this file');
  } catch (e) {
    print('Error downloading file: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GetBuilder<AddNotificationsController>(
      init: Get.put<AddNotificationsController>(AddNotificationsController()),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () {
                        controller.titleController.text = widget.title;
                        controller.bodyController.text = widget.description;
                        controller.fileName?.value = widget.file?['name'] ?? '';
                        controller.fileUrl?.value = widget.file?['url'] ?? '';
                        Get.to(
                          () => AddNotification(
                            isEdit: true,
                            docId: widget.docId,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.edit,
                        color: redColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () {
                        getDialog(
                          title: 'Delete',
                          desc:
                              'Are you sure you want to delete this notification?',
                          icon: Icons.delete,
                          actions: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(redColor),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("No"),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(redColor),
                              ),
                              onPressed: () {
                                controller.deleteNotification(widget.docId);
                                Get.back();
                              },
                              child: const Text(
                                "Yes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                      child: Icon(
                        Icons.delete,
                        color: redColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
            title: const Text(
              "  Notification Description",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  NotificationInfo(
                    size: size,
                    accessTimeOutlined: NotificationDetail.time,
                    text: widget.title,
                    desc: widget.description,
                    date: widget.date,
                    onTap: () {
                      widget.file == null
                          ? {}
                          : {
                              if (Platform.isAndroid)
                                {
                                  FileDownloader.downloadFile(
                                    url: widget.file!['url'] ?? '',
                                    name: widget.file!['name'] ?? '',
                                    onDownloadCompleted: (String? path) {
                                      Get.snackbar(
                                        'Download Completed',
                                        'File downloaded successfully at $path',
                                      );
                                    },
                                    onDownloadError: (String? error) {
                                      Get.snackbar(
                                        'Download Error',
                                        error ??
                                            'An error occurred while downloading the file.',
                                      );
                                    },
                                  ),
                                }
                              else if (Platform.isIOS)
                                {
                                  downloadAndSaveFile(
                                    widget.file!['url'] ?? '',
                                    widget.file!['name'] ?? '',
                                  ),
                                }
                              // flutterMediaDownloader.downloadMedia(context, widget.file!['url']??'')
                            };
                    },
                    file: widget.file,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:squareone_admin/ui/component/dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class AddNotificationsController extends GetxController {
  RxBool isSending = false.obs;
  RxBool isLoading = false.obs;
  RxBool pickerLoading = false.obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  RxString? fileName = ''.obs;
  RxString? fileUrl = ''.obs;
  RxBool isHeic = false.obs;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  GetStorage storage = GetStorage();
  String email = '';
  @override
  void onReady() {
    email = storage.read('email');
  }

  Rx<File?> selectedFile = Rx<File?>(null);
Future<void> pickFile() async {
  pickerLoading.value = true;
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String ext = file.path.split('.').last.toLowerCase();

      if (ext == 'heic') {
        try {
          final tempDir = await getTemporaryDirectory();
          String originalName = result.files.single.name;
          String basename = originalName.contains('.') 
              ? originalName.substring(0, originalName.lastIndexOf('.')) 
              : originalName;
          String newFilename = '${basename}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final outputPath = '${tempDir.path}/$newFilename';
          final convertedPath = await HeifConverter.convert(file.path, output: outputPath);
          file = File(convertedPath ?? outputPath); 
          isHeic.value = true;
        } catch (e) {
          log('HEIC conversion failed: $e');
          Get.snackbar('Error', 'Failed to convert HEIC image');
          pickerLoading.value = false;
          return;
        }
      }

      selectedFile.value = file;
      fileName!.value = file.path.split('/').last;
      log('File selected: ${file.path}');
    } else {
      log('No file selected');
    }
  } catch (e) {
    log('Error picking file: $e');
    Get.snackbar('Error', 'Failed to pick file');
  } finally {
    pickerLoading.value = false;
  }
}

  delete(subject) {
    firebaseFirestore.collection('Approval-Notification').doc(subject).delete();
  }

  approveNotification() async {
    isLoading.value = true;

    CollectionReference notification =
        FirebaseFirestore.instance.collection('Notification');
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Outlets").get();
    await notification.add({
      'subject': titleController.text,
      'description': bodyController.text,
      'time': DateTime.now(),
    });
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      for (var i in a.get('token')) {
        await sendMessage(i, bodyController.text, titleController.text);
      }
    }
    getDialog(title: 'Success', desc: 'Notification Added Sucessfully.')
        .then((value) {
      isLoading.value = false;
      titleController.clear();
      bodyController.clear();
    }).then((value) => Get.back());
  }

  Future<String?> uploadFileToFirebaseStorage(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/notificationFiles/$fileName');
      var uploadTask = await storageRef.putFile(file,SettableMetadata(contentType: 'image/jpeg'));
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      fileName = file.path.split('/').last;
      log('File uploaded successfully: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      log('Error uploading file: $e');
      Get.snackbar('Error', 'Failed to upload file');
      return null;
    }
  }

  sendNotifications() async {
    // Existing sendNotifications function code
    CollectionReference approvalNotification =
        FirebaseFirestore.instance.collection('Approval-Notification');

    CollectionReference notification =
        FirebaseFirestore.instance.collection('Notification');

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Outlets").get();
    if (titleController.text.isNotEmpty &&
        bodyController.text.isNotEmpty &&
        selectedFile.value == null) {
      isLoading.value = true;

      await firebaseFirestore
          .collection('Depart Members')
          .doc(email)
          .get()
          .then((value) async {
        switch (value.data()!['Department']) {
          case 'Admin':
          case "Operations":
            await notification.add({
              'subject': titleController.text,
              'description': bodyController.text,
              'time': DateTime.now(),
              'file': null,
            });
            for (int i = 0; i < querySnapshot.docs.length; i++) {
              var a = querySnapshot.docs[i];

              for (var i in a.get('token')) {
                await sendMessage(i, bodyController.text, titleController.text);
              }
            }
            getDialog(
                title: 'Success', desc: 'Notification Added Sucessfully.');

            titleController.clear();
            bodyController.clear();
            isLoading.value = false;
            break;
          case "Maintainance":
          case "Security":
            await approvalNotification.doc(titleController.text).set({
              'subject': titleController.text,
              'description': bodyController.text,
              'time': DateTime.now(),
              'file': null,
            }).whenComplete(() {
              getDialog(
                  title: 'Success', desc: 'Notification Added Sucessfully.');
              titleController.clear();
              bodyController.clear();
              isLoading.value = false;
            });
            break;
        }
      });
    } else if (titleController.text.isNotEmpty &&
        bodyController.text.isNotEmpty &&
        selectedFile.value != null) {
      isLoading.value = true;
      String? fileUrl = await uploadFileToFirebaseStorage(selectedFile.value!);
      if (fileUrl == null) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to upload file');
        return;
      }
      try {
        await firebaseFirestore
            .collection('Depart Members')
            .doc(email)
            .get()
            .then(
          (value) async {
            switch (value.data()!['Department']) {
              case 'Admin':
              case "Operations":
                await notification.add({
                  'subject': titleController.text,
                  'description': bodyController.text,
                  'file': {
                    'name': isHeic.value?'${selectedFile.value!.path.split('/').last}.jpg': '${selectedFile.value!.path.split('/').last}',
                    'url': fileUrl
                  },
                  'time': DateTime.now(),
                });

                for (int i = 0; i < querySnapshot.docs.length; i++) {
                  var a = querySnapshot.docs[i];
                  for (var i in a.get('token')) {
                    await sendMessage(
                        i, bodyController.text, titleController.text, '', {
                      'file': {
                        'name': isHeic.value?'${selectedFile.value!.path.split('/').last}.jpg': '${selectedFile.value!.path.split('/').last}',
                        'url': fileUrl
                      },
                    });
                  }
                }
                getDialog(
                    title: 'Success', desc: 'Notification Added Successfully.');
                titleController.clear();
                bodyController.clear();
                selectedFile.value = null;
                isLoading.value = false;
                break;
              case "Maintainance":
              case "Security":
                await approvalNotification.doc(titleController.text).set({
                  'subject': titleController.text,
                  'description': bodyController.text,
                  'file': {
                    'name': isHeic.value?'${selectedFile.value!.path.split('/').last}.jpg': '${selectedFile.value!.path.split('/').last}',
                    'url': fileUrl
                  },
                  'time': DateTime.now(),
                }).whenComplete(
                  () {
                    getDialog(
                        title: 'Success',
                        desc: 'Notification Added Successfully.');
                    titleController.clear();
                    bodyController.clear();
                    selectedFile.value = null;
                    isLoading.value = false;
                  },
                );
                break;
            }
          },
        );
      } catch (e) {
        log('Error processing notification: $e');
        Get.snackbar('Error', 'Failed to process notification');
        isLoading.value = false;
      } finally {
        isLoading.value = false;
      }
    }
  }

  updateNotification(String docId) async {
    CollectionReference approvalNotification =
        FirebaseFirestore.instance.collection('Approval-Notification');

    CollectionReference notification =
        FirebaseFirestore.instance.collection('Notification');

    if (titleController.text.isNotEmpty &&
        bodyController.text.isNotEmpty &&
        (fileUrl?.value != '' || fileUrl?.value == null) &&
        (fileName?.value != '' || fileName?.value == null)) {
      isLoading.value = true;

      await firebaseFirestore
          .collection('Depart Members')
          .doc(email)
          .get()
          .then((value) async {
        switch (value.data()!['Department']) {
          case 'Admin':
          case "Operations":
            await notification.doc(docId).update({
              'subject': titleController.text,
              'description': bodyController.text,
              'time': DateTime.now(),
              'file': {'name': isHeic.value?'${fileName!.value}.jpg':fileName!.value, 'url': fileUrl!.value},
            });
            // .then((value) async {
            //   for (int i = 0; i < querySnapshot.docs.length; i++) {
            //     var a = querySnapshot.docs[i];
            //     for (var i in a.get('token')) {
            //       await sendMessage(
            //           i, bodyController.text, titleController.text, '', {
            //         'file': {'name': fileName!.value, 'url': fileUrl!.value},
            //       });
            //     }
            //   }
            // });

            getDialog(
                title: 'Success', desc: 'Notification Updated Successfully.');

            titleController.clear();
            bodyController.clear();
            isLoading.value = false;
            break;
          case "Maintainance":
          case "Security":
            await approvalNotification.doc(docId).update({
              'subject': titleController.text,
              'description': bodyController.text,
              'time': DateTime.now(),
              'file': null,
            }).whenComplete(() {
              getDialog(
                  title: 'Success', desc: 'Notification Updated Successfully.');
              titleController.clear();
              bodyController.clear();
              isLoading.value = false;
            });
            break;
        }
      });
    } else if (titleController.text.isNotEmpty &&
        bodyController.text.isNotEmpty &&
        selectedFile.value != null) {
      isLoading.value = true;
      String? fileUrl = await uploadFileToFirebaseStorage(selectedFile.value!);
      if (fileUrl == null) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to upload file');
        return;
      }
      await firebaseFirestore
          .collection('Depart Members')
          .doc(email)
          .get()
          .then((value) async {
        switch (value.data()!['Department']) {
          case 'Admin':
          case "Operations":
            await notification.doc(docId).update({
              'subject': titleController.text,
              'description': bodyController.text,
              'time': DateTime.now(),
              'file': {
                'name': isHeic.value?'${selectedFile.value!.path.split('/').last}.jpg': '${selectedFile.value!.path.split('/').last}',
                'url': fileUrl
              },
            });
            // .then((value) async {
            //   for (int i = 0; i < querySnapshot.docs.length; i++) {
            //     var a = querySnapshot.docs[i];
            //     for (var i in a.get('token')) {
            //       await sendMessage(
            //           i, bodyController.text, titleController.text, '', {
            //         'file': {
            //           'name': selectedFile.value!.path.split('/').last,
            //           'url': fileUrl
            //         },
            //       });
            //     }
            //   }
            // });
            getDialog(
                title: 'Success', desc: 'Notification Updated Successfully.');

            titleController.clear();
            bodyController.clear();
            isLoading.value = false;
            break;
          case "Maintainance":
          case "Security":
            await approvalNotification.doc(docId).update({
              'subject': titleController.text,
              'description': bodyController.text,
              'time': DateTime.now(),
              'file': {
                'name': isHeic.value?'${selectedFile.value!.path.split('/').last}.jpg': '${selectedFile.value!.path.split('/').last}',
                'url': fileUrl
              },
            }).whenComplete(() {
              getDialog(
                  title: 'Success', desc: 'Notification Updated Successfully.');
              titleController.clear();
              bodyController.clear();
              isLoading.value = false;
            });
            break;
        }
      });
    } else if (titleController.text.isNotEmpty &&
        bodyController.text.isNotEmpty &&
        selectedFile.value == null &&
        (fileUrl?.value == '' || fileUrl?.value == null) &&
        (fileName?.value == '' || fileName?.value == null)) {
      isLoading.value = true;
      try {
        await firebaseFirestore
            .collection('Depart Members')
            .doc(email)
            .get()
            .then(
          (value) async {
            switch (value.data()!['Department']) {
              case 'Admin':
              case "Operations":
                await notification.doc(docId).update({
                  'subject': titleController.text,
                  'description': bodyController.text,
                  'file': null,
                  'time': DateTime.now(),
                });
                // .then((value) async {
                //   for (int i = 0; i < querySnapshot.docs.length; i++) {
                //     var a = querySnapshot.docs[i];
                //     for (var i in a.get('token')) {
                //       await sendMessage(
                //           i, bodyController.text, titleController.text);
                //     }
                //   }
                // });
                getDialog(
                    title: 'Success',
                    desc: 'Notification Updated Successfully.');
                titleController.clear();
                bodyController.clear();
                selectedFile.value = null;
                isLoading.value = false;
                break;
              case "Maintainance":
              case "Security":
                await approvalNotification.doc(docId).update({
                  'subject': titleController.text,
                  'description': bodyController.text,
                  'file': {
                    'name': isHeic.value?'${selectedFile.value!.path.split('/').last}.jpg': '${selectedFile.value!.path.split('/').last}',
                    'url': fileUrl
                  },
                  'time': DateTime.now(),
                }).whenComplete(
                  () {
                    getDialog(
                        title: 'Success',
                        desc: 'Notification Updated Successfully.');
                    titleController.clear();
                    bodyController.clear();
                    selectedFile.value = null;
                    isLoading.value = false;
                  },
                );
                break;
            }
          },
        );
      } catch (e) {
        log('Error updating notification: $e');
        Get.snackbar('Error', 'Failed to update notification');
        isLoading.value = false;
      } finally {
        isLoading.value = false;
      }
    }
  }

deleteNotification(String docId) async {
    isLoading.value = true;
    try {
     await firebaseFirestore.collection('Notification').doc(docId).delete();
     Get.back(); Get.snackbar('Success', 'Notification deleted successfully');
      isLoading.value = false;
     
    } catch (e) {
      log('Error deleting notification: $e');
      Get.snackbar('Error', 'Failed to delete notification');
    } finally {
      isLoading.value = false; 
    }
  }
}

// Future sendMessage(token, String body, String title, [String type = '']) async {
//   try {
//     await http
//         .post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
//             headers: <String, String>{
//               'Content-Type': 'application/json',
//               'Authorization':
//                   'key=AAAAho_3SsQ:APA91bGngkIZ1H9FxYoNAnA6i3ThKeppD_euKvl-VNmzQExO8aNXKhcmIZgEih5IT7RVO8dX1j0iKrQzzPFDItqdGO5N19YQbIX0CojExs6gyR1a0ISPiqOY6UPSJgKbkKKplnm45fuL',
//             },
//             body: jsonEncode(<String, dynamic>{
//               'priority': 'high',
//               'data': <String, dynamic>{
//                 'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//                 'status': 'done',
//                 'body': body,
//                 'title': title,
//                 "type": type,
//               },
//               'notification': <String, dynamic>{
//                 'title': title,
//                 'body': body,
//                 "android_channel_id": "high_importance_channel"
//               },
//               "to": token
//             }))
//         .then((value) => log(value.reasonPhrase.toString()));
//   } catch (e) {
//     Get.snackbar('Error', 'Operation couldn\'t be completed');
//   }
// }

late String accessToken;
Future<void> getAccessToken() async {
  final serviceAccountJson = {
  "type": "service_account",
  "project_id": "squareone-a6d26",
  "private_key_id": "fdc9d5c5ecba1917483eb202cb8ae7ed71bb1631",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCisuVddgC1mwyl\nv75FINGplUB9an9Hl6LPIVycwvet/0J9caG4PHsUPO2P18O4uAjwG/nvo8q/cAuV\nM2K4suxalaJD4/18kCFh/Uk3iMkHtNuSR/wFuI+aa+EUoRHCOPlhwf0S3K1Vjexc\ntXgnbXAEZw3vJ+cmruNoiYFm8/cygUuLlK7BDj0XVoQqCBEK4b7IYw+yXOtfcjpO\nGoNKui/85kF8XYzevrWu+jyRz63HlO8bkZ7oljJSuThoIi4tOe4uXGFoFjA23w7n\nZA4Fzvq5rqljaWooNWZ0Qvg1k9H9aH7nCOKZghipt5puRtkS5OrKi0qlfjAji/PB\novagjCAvAgMBAAECggEAA57smNRf9qqxMN0gDGTLFbWTHldo5rx6rJZm+7whC/fC\n0IzfVvzNlmk2tj1Mh0ddN46/1LP19qW1NEhU+ZxNw0RSPKWNxiBlBcu/veMm6it9\nuXctpijx1TNyamWdQg/HiQPqsGlF2EIU0Qle163JUOfEOR7Pt54rxG9O+G4UgcSy\nxX2f5Z4ytvjZfbTxEvnq8e2a5GidtW0LchIwYPvrXR5IYzvkISwS6djlJO2gZY8c\n10R/rsUaLpVeej8eUUtzWoGAdgRZAMjaGQ3hN89Qr9FTjhcKS3LYbsDClch0IoW4\n3OGeWgEKUpy7Jm1T3aroVbCMmEC6yKvbKhfUgYbUZQKBgQDS5bjyE5tdQ4E13erf\nmwhlDtyJ63MbReLG0v4PAVzteKdiZzMCrSsyZmw96ujdfISNI28jWSFbXS7sd6tg\nn5PTzeIT9Z/Kqiiy1MfySM5cU8dTGIuxKJcyhvWXbpX//SgDCr07fJ/Y7PqfYTEz\nvkzAcFWD7atefrg0aG1UaKk8EwKBgQDFfmJLgrE2216SNvmwLcQgRJ5WYilrV6ak\nhOqzy6M7fTLvUMuEp1D5gwmQdGQq6w0nMK5iD/oR5vZ+6Ix4AE5Qy+xPdluJxZtw\nAtERhlI8yLh+rWfKo/hxQUGPBR6oUYtG1aEA9X91xYFBwlDVVja/9/ALNOoRuiDr\nJnwAPGQW9QKBgQCF4Zea9Z93gVcRXyOvd7fIj7qpQ3L7KU5hcage1nqrtiBsc58K\nX+xAPo0QcYQKtvVes9Pl2Ls4SNt0+jMtT6CEoPqYOSGLgqH7hOC5ikaWjgjHU5m6\niU4SoWJfE7DdpVQ1OigPD3paN3aSnxyhAHmw4J8o9UQI5OEDRBfDsf1dSQKBgQDF\ncs/vUqC+iaAJavFDlN4KrM/o6YcjjKRMw56rVyLBbTCpVwvCek1YyAud4t/qkMm7\nrs4JuJN5poI262TU7OlfmiGOaHSoT2pSGF7RuIsrvjnGXLPyQvE2udlDlgjKm4w1\nq4umm8ttAaNzDUUnpWRjlQznB2YlhwM2VmmPCtG+qQKBgAFLjMjXFWgrGUz/mems\noW4L6g1QGqLHUxNsMcECmkyGkrPgcEznnHcZeX7ymYNXdkKvLKNmwQ9hiN2gV2c1\nEantQ+8jVw5LIit25vjfKaLO0RPIDc1P5+LaPNC3vq4Ko8SM1Nu0G3PNwWe2VO2x\nqnxabwcu2OMIeSCTl7lbYbYz\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-urcsr@squareone-a6d26.iam.gserviceaccount.com",
  "client_id": "102973876637661568533",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-urcsr%40squareone-a6d26.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};
  List<String> scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  try {
    var client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);
    var credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);
    client.close();
    accessToken = credentials.accessToken.data;
    debugPrint(accessToken);
  } catch (e) {
    debugPrint('Error getting access token: $e');
  }
}

Future<void> sendMessage(String token, String body, String title,
    [String type = '', dynamic additionalData]) async {
  try {
    String endpointCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/squareone-a6d26/messages:send';

    await getAccessToken();

    Map<String, dynamic> data = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'type': type,
          ...?additionalData,
        },
        'android': {
          'notification': {
            'channel_id': 'high_importance_channel',
          }
        }
      }
    };

    // Make the HTTP request to send the notification
    final http.Response response = await http.post(
      Uri.parse(endpointCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      log('Notification sent successfully');
    } else {
      log('Notification failed: ${response.body}');
    }
  } catch (e) {
    Get.snackbar('Error', 'Operation couldn\'t be completed');
    log('Error sending notification: $e');
  }
}

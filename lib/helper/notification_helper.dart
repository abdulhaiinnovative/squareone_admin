
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flutter_local_notifications;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squareone_admin/ui/views/tickets/details/gate_pass_detail.dart';
import '../ui/views/splash/splash_view.dart';
import '../ui/views/tickets/details/non_retail_activity.dart';
import '../ui/views/tickets/details/security.dart';
class PushNotificationService {
  Future<void> setupInteractedMessage() async {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (message.data['type'] == 'logout') {
          FirebaseAuth.instance.signOut().whenComplete(() {
            GetStorage storage = GetStorage();
            storage.remove('email');
            storage
                .remove('password')
                .whenComplete(() => Get.offAll(() => const SplashView()));
          });
        } else if (message.data['type'] != 'logout') {
          switch (message.data['type'].substring(0, 7)) {
            case "TicketG":
              Get.to(GateInwardDetails(
                  ticketId: message.data['type']
                      .substring(8, message.data['type'].toString().length)));
              break;
            case "TicketR":
              Get.to(NonRentalActivity(
                  ticketId: message.data['type']
                      .substring(8, message.data['type'].toString().length)));
              break;
            case "TicketM":
              Get.to(SecurityTicektDetails(
                  ticketId: message.data['type']
                      .substring(8, message.data['type'].toString().length)));
              break;
            default:
              Get.to(SplashView());
          }
        }
      },
    );
    enableIOSNotifications();
    await registerNotificationListeners();
  }

  Future<void> registerNotificationListeners() async {
    final AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
// We're receiving the payload as string that looks like this
// {buttontext: Button Text, subtitle: Subtitle, imageurl: , typevalue: 14, type: course_details}
// So the code below is used to convert string to map and read whatever property you want
        final List<String> str =
            details.payload!.replaceAll('{', '').replaceAll('}', '').split(',');
        final Map<String, dynamic> result = <String, dynamic>{};
        for (int i = 0; i < str.length; i++) {
          final List<String> s = str[i].split(':');
          result.putIfAbsent(s[0].trim(), () => s[1].trim());
        }
        // notificationRedirect(result[keyTypeValue], result[keyType]);
      },
    );
// onMessage is called when the app is in foreground and a notification is received
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      // consoleLog(message, key: 'firebase_message');
      final RemoteNotification? notification = message!.notification;
      final AndroidNotification? android = message.notification?.android;
// If `onMessage` is triggered with a notification, construct our own
// local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          flutter_local_notifications.NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });
  }

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  AndroidNotificationChannel androidNotificationChannel() =>
      const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.max,
      );
}


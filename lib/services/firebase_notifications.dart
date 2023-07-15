import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:overlay_support/overlay_support.dart';
import 'package:student_event_calendar/widgets/message_notification.dart';

class FirebaseNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void getDeviceToken() async {
    String? deviceToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Device Token: $deviceToken');
    }
  }

   void configure() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        // Handle the incoming message when the app is in the foreground
        if (kDebugMode) {
          print('Notification Title: ${message.notification!.title}');
          print('Notification Body: ${message.notification!.body}');
          print('Data Payload(onMessage): ${message.data}');
        }

        showOverlayNotification((context) {
          return MessageNotification(
            message: message.notification?.body ?? '', 
            title: message.notification?.title ?? '',
          );
        }, duration: const Duration(milliseconds: 3000));
      },
      onDone: () {
        if (kDebugMode) {
          print('Done listening');
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        // Handle the incoming message when the app is launched from a terminated state
        if (kDebugMode) {
          print('Notification Title: ${message.notification!.title}');
          print('Notification Body: ${message.notification!.body}');
          print('Data Payload(onMessage): ${message.data}');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('Done listening');
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(
      (RemoteMessage message) async {
        // Handle the incoming message when the app is in the background
          if (kDebugMode) {
          print('Notification Title: ${message.notification!.title}');
          print('Notification Body: ${message.notification!.body}');
          print('Data Payload(onMessage): ${message.data}');
        }
      },
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<String> sendPushNotification(String title, String body, String token) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    String message = 'Some error occured while sending push notification.';
    final data = {
      "notification": {"body": body, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": token
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=YOUR_SERVER_KEY',
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      message = 'Notification sent successfully';
    } else {
      message = 'Notification not sent';
    }
    return message;
  }
}

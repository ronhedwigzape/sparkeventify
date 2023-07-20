import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:overlay_support/overlay_support.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/widgets/popup_notification.dart';


// Place this on top to avoid Null Safety errors
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the incoming message when the app is in the background
  if (kDebugMode) {
    print('Notification Title: ${message.notification!.title}');
    print('Notification Body: ${message.notification!.body}');
    print('Data Payload(onMessage): ${message.data}');
  }
}

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
          return PopupNotification(
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
        if (message.notification != null) {
          if (kDebugMode) {
            print('Notification Title: ${message.notification!.title}');
            print('Notification Body: ${message.notification!.body}');
            print('Data Payload(onMessage): ${message.data}');
          }
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('Done listening');
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Optional: Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Send a push notification to a user
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

  Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;  // unique ID for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;  // unique ID for iOS
    }
    return '';
  }

  Future<void> registerDevice(String userId, String token) async {
    var deviceId = await getDeviceId();
    var userDocument = FirebaseFirestore.instance.collection('users').doc(userId);
    // Set the device token in the user document
    await userDocument.set({
      'deviceTokens': {
        deviceId: token
      }
    }, SetOptions(merge: true)); // The 'merge: true' option will ensure that the rest of the user document remains unaffected
  }

  Future<void> unregisterDevice(String userId) async {
    try {
      var userDocument = FirebaseFirestore.instance.collection('users').doc(userId);

      await userDocument.update({
        'deviceTokens': {}
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering device: $e');
      }
    }
  }


  Future<void> sendNotificationToUser(String userId, String title, String body, String message) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        if (kDebugMode) {
          print('User not found');
        }
        return;
      }

      var user = model.User.fromSnap(userDoc);

      if (user.deviceTokens != null) {
        for (var token in user.deviceTokens!.values) {
          try {
            await sendPushNotification(title, body, token);
          } catch (e) {
            if (kDebugMode) {
              print('Failed to send notification: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user: $e');
      }
    }
  }


}

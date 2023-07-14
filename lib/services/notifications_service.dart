import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
    'Authorization': 'key=YOUR_SERVER_KEY', // replace with your server key
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

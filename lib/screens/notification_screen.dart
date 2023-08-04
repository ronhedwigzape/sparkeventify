import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/global.dart';
import '../widgets/notification_card.dart';
import '../models/notification.dart' as model;
import '../models/user.dart' as model;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<List<model.Notification>> fetchNotifications() async {
    final snaps = await FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).get();
    final notifications = <model.Notification>[];
    for (final snap in snaps.docs) {
      final notification = model.Notification.fromSnap(snap);
      final senderSnap = await notification.sender!.get();
      notification.senderData = model.User.fromSnap(senderSnap);
      notifications.add(notification);
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder<List<model.Notification>>(
        future: fetchNotifications(),
        builder: (BuildContext context, AsyncSnapshot<List<model.Notification>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.2 : 0,
                vertical: width > webScreenSize ? 15 : 0),
              child: NotificationCard(snap: snapshot.data![index],
              )
            )
          );
        },
      ),
    );
  }
}

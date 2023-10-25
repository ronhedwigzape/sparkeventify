import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import '../utils/global.dart';
import '../widgets/notification_card.dart';
import '../models/notification.dart' as model;
import '../models/user.dart' as model;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

Future<List<model.Notification>> fetchNotifications() async {
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  // Only get notifications for the current user
  final snaps = await FirebaseFirestore.instance
      .collection('notifications')
      .where('recipient', isEqualTo: FirebaseFirestore.instance.doc('users/$currentUserID'))
      .orderBy('timestamp', descending: true)
      .get();
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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    return Scaffold(
      body: FutureBuilder<List<model.Notification>>(
        future: fetchNotifications(),
        builder: (BuildContext context, AsyncSnapshot<List<model.Notification>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CSPCSpinner());
          }
          else if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notification_important_rounded, size: 25.0, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                        const Flexible(
                          child: Text(
                            'You don’t have any notifications. Check back later.',
                            textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
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

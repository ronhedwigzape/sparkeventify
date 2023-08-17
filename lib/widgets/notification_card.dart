import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatefulWidget {
  const NotificationCard({Key? key, required this.snap}) : super(key: key);

  final dynamic snap;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  model.User? senderData; // Declare senderData variable
  model.User? recipientData; // Declare receiverData variable

  @override
  void initState() {
    super.initState();
    loadSenderData(); // Load senderData
    loadRecipientData(); // Load receiverData
  }

  void loadSenderData() {
    widget.snap.sender?.get().then((snapshot) {
      setState(() {
        senderData = model.User.fromSnap(snapshot);
      });
    });
  }

  void loadRecipientData() {
    widget.snap.recipient?.get().then((snapshot) {
      setState(() {
        recipientData = model.User.fromSnap(snapshot);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final recipientUid = recipientData?.uid; 

   return recipientUid == currentUserUid
    ? Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: darkModeOn ? secondaryDarkColor : lightColor,
          ),
          color: darkModeOn ? darkColor : lightColor,
        ),
        padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  senderData?.profile?.profileImage ??
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.snap.title}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                      text: TextSpan(
                        text: '${widget.snap.message ?? ''}',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: darkModeOn ? lightColor : darkColor,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timeago.format(widget.snap.timestamp.toDate()),
                    style: TextStyle(
                      color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.snap.unread,  //toggle this based on your unread logic
              child: CircleAvatar(
                radius: 5,
                backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
              ),
            )
          ],
        ),
      )
    : const SizedBox.shrink();
  }
}

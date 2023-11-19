import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/notification.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timezone/timezone.dart' as tz;

class NotificationCard extends StatefulWidget {
  const NotificationCard({Key? key, required this.snap}) : super(key: key);

  final model.Notification snap;

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

  void _manageNotification(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
          return SimpleDialog(
            title: Text('Manage Notification', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.mark_as_unread),
                    const SizedBox(width: 10),
                    Text('Mark as unread', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (widget.snap.id != null) {
                    await FirebaseNotificationService()
                        .markAsUnread(widget.snap.id!);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.cancel),
                    const SizedBox(width: 10),
                    Text('Cancel', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _viewNotification(BuildContext context) async {
    final manila = tz.getLocation('Asia/Manila');
    final localTime =
        tz.TZDateTime.from(widget.snap.timestamp!.toDate().toUtc(), manila);
    final darkModeOn = Provider.of<DarkModeProvider>(context, listen: false).darkMode;
    showDialog(
        context: context,
        builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: AlertDialog(
                title: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: darkColor,
                    backgroundImage: NetworkImage(
                      senderData?.profile?.profileImage ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Text(
                          'Notification from ${senderData?.profile?.fullName}', style: TextStyle(color: darkModeOn ? lightColor : darkColor)))
                ]),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Title',
                        style: TextStyle(color: darkModeSecondaryColor),
                      ),
                      const SizedBox(height: 5),
                      Flexible(child: Text('${widget.snap.title}', style: TextStyle(color: darkModeOn ? lightColor : darkColor))),
                      const SizedBox(height: 15),
                      const Text(
                        'Message',
                        style: TextStyle(color: darkModeSecondaryColor),
                      ),
                      const SizedBox(height: 5),
                      Flexible(child: Text('${widget.snap.message}', style: TextStyle(color: darkModeOn ? lightColor : darkColor))),
                      const SizedBox(height: 20),
                      Text(
                        'Received: ${DateFormat.yMMMd().format(localTime)} ${DateFormat.jm().format(localTime)}',
                        style: const TextStyle(color: darkModeTertiaryColor),
                      ),
                    ]),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final recipientUid = recipientData?.uid;

    return recipientUid == currentUserUid
        ? StreamBuilder<bool>(
            stream: widget.snap.id != null
                ? FirebaseNotificationService().getUnreadStatus(widget.snap.id!)
                : Stream<bool>.value(false),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == null) {
                return const SizedBox
                    .shrink(); // fixes the error on Null check operator used on a null value
              }
              return InkWell(
                onTap: () {
                  if (widget.snap.id != null) {
                    FirebaseNotificationService().markAsRead(widget.snap.id!);
                    _viewNotification(context);
                  }
                },
                onLongPress: snapshot.data == false ?  () {
                  if (widget.snap.id != null) {
                    _manageNotification(context);
                  }
                } : () {},
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: darkModeOn ? secondaryDarkColor : lightColor,
                    ),
                    color: darkModeOn
                        ? (snapshot.data!
                            ? darkColor
                            : Theme.of(context).canvasColor)
                        : (snapshot.data!
                            ? lightColor
                            : Theme.of(context).canvasColor),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: darkModeOn ? darkColor : lightColor,
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
                              style: TextStyle(
                                color: darkModeOn ? lightColor : darkColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: RichText(
                                text: TextSpan(
                                  text: widget.snap.message ?? '',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: darkModeOn ? lightColor : darkColor,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              timeago.format(widget.snap.timestamp!.toDate()),
                              style: TextStyle(
                                color: darkModeOn
                                    ? darkModeTertiaryColor
                                    : lightModeTertiaryColor,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: snapshot.data ?? false,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: darkModeOn
                              ? darkModePrimaryColor
                              : lightModePrimaryColor,
                        ),
                      )
                    ],
                  ),
                ),
              );
            })
        : const SizedBox.shrink();
  }
}

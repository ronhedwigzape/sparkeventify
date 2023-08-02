import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({Key? key, required this.snap}) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final snap;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return StreamBuilder<model.User>(
        stream: widget.snap.sender.snapshots().map<model.User>((snap) => model.User.fromSnap(snap)), // casting the mapped function with User type
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 380.0,
              child: Center(
                child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            model.User? senderData = snapshot.data;
            return Container(
              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? secondaryDarkColor : lightColor), color: darkModeOn ? darkColor : lightColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
                        child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: NetworkImage(senderData?.profile?.profileImage ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'), // Assuming 'senderImageUrl' is a field in your document
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${widget.snap.title}', // Assuming 'title' is a field in your document
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ]
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                      children: [
                                        const TextSpan(
                                          text: 'Description: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                          '${widget.snap.message ?? 'default_description'}',
                                        ),
                                      ])),
                            ),
                          ]),
                    )
                  ]),
            );
          }
        });
  }
}

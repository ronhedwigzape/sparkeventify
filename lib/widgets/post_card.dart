import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/event_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:timezone/timezone.dart' as tz;

class PostCard extends StatefulWidget {
  const PostCard({Key? key, required this.snap}) : super(key: key);
  final snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Future<model.User> userDetails;

  @override
  void initState() {
    super.initState();
    userDetails = FireStoreUserMethods().getUserByEventsCreatedBy(widget.snap.createdBy);
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return FutureBuilder<model.User>(
        future: userDetails,
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
            final author = snapshot.data?.profile?.fullName;
            final authorType = snapshot.data?.userType;
            final authorImage = snapshot.data?.profile?.profileImage;
            final datePublished = widget.snap.datePublished ?? DateTime.now().toUtc();
            final manila = tz.getLocation('Asia/Manila');
            final localTime = tz.TZDateTime.from(datePublished, manila);

            // For Staff View Only
            return FirebaseAuth.instance.currentUser?.uid == widget.snap.createdBy && authorType == 'Staff'
            ? Container(
              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? secondaryDarkColor : lightColor), color: darkModeOn ? darkColor : lightColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
                    child: Row(
                      children: <Widget>[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(authorImage ??
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                        backgroundColor: transparent,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                author ?? 'Unknown Author',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: DateFormat.yMMMd().format(localTime),
                                      style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                          fontSize: 12,
                                        ),
                                    ),
                                    const TextSpan( text: " "),
                                    TextSpan(
                                      text: DateFormat.jm().format(localTime),
                                      style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                          fontSize: 12
                                        ),
                                    ),              
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                        IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              title: Text(
                                  'Are you sure you want to delete this ${widget.snap.type == 'Academic' ? 'announcement' : 'event'} forever?',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: darkModeOn ? lightColor : darkColor
                                  )
                              ),
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () async {
                                          await FireStoreEventMethods().removeEvent(widget.snap.id);
                                            Navigator.of(context).pop();
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete_forever,
                                                color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                                            const SizedBox(width: 16),
                                            Text('Delete Forever',
                                                style: TextStyle(
                                                  color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                                                  fontWeight: FontWeight.bold,
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )
                        );

                      },
                        icon: const Icon(Icons.delete_forever, color: darkModeMaroonColor),
                        tooltip: 'Delete event',
                      ),
                      ]),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: (widget.snap.image == null ||
                              widget.snap.image == '')
                          ? Image.network(
                              'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.snap.image ??
                                  'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EventScreen(
                              snap: widget.snap,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.view_agenda, size: 18),
                      label: Text('View this ${widget.snap.type == 'Academic' ? 'announcement' : 'event'}'),
                    ),
                  ],
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
                                  '${widget.snap.description ?? 'default_description'}',
                            ),
                          ]),
                          overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                )
              ]),
            ) : 
          FutureBuilder<model.User?>(
          future: AuthMethods().getCurrentUserDetails(),
          builder: (BuildContext context, AsyncSnapshot<model.User?> snapshot) {
            final model.User? user = snapshot.data;
            String? userUid = user?.uid;
            String? userType = user?.userType;

            // For Admin View Only
            return FirebaseAuth.instance.currentUser?.uid == userUid && userType == 'Admin' ?
            Container(
              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? secondaryDarkColor : lightColor), color: darkModeOn ? darkColor : lightColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
                    child: Row(
                      children: <Widget>[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(authorImage ??
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                        backgroundColor: transparent,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                author ?? 'Unknown Author',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: DateFormat.yMMMd().format(localTime),
                                      style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                          fontSize: 12,
                                        ),
                                    ),
                                    const TextSpan( text: " "),
                                    TextSpan(
                                      text: DateFormat.jm().format(localTime),
                                      style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                          fontSize: 12
                                        ),
                                    ),              
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                        IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              title: Text(
                                  'Are you sure you want to delete this ${widget.snap.type == 'Academic' ? 'announcement' : 'event'} forever?',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: darkModeOn ? lightColor : darkColor
                                  )
                              ),
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () async {
                                          await FireStoreEventMethods().removeEvent(widget.snap.id);
                                            Navigator.of(context).pop();
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete_forever,
                                                color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                                            const SizedBox(width: 16),
                                            Text('Delete Forever',
                                                style: TextStyle(
                                                  color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                                                  fontWeight: FontWeight.bold,
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )
                        );

                      },
                        icon: const Icon(Icons.delete_forever, color: darkModeMaroonColor),
                        tooltip: 'Delete event',
                      ),
                      ]),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: (widget.snap.image == null ||
                              widget.snap.image == '')
                          ? Image.network(
                              'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.snap.image ??
                                  'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
             
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EventScreen(
                              snap: widget.snap,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.view_agenda, size: 18),
                      label: Text('View this ${widget.snap.type == 'Academic' ? 'announcement' : 'event'}'),
                    ),
                  ],
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
                                  '${widget.snap.description ?? 'default_description'}',
                            ),
                          ]),
                          overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                )
              ]),
            ) : const SizedBox.shrink(); 
          });
          }   
        }
      );
  }
}

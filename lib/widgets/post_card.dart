import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/event_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
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
    userDetails = FireStoreUserMethods().getUserDetailsByEventsCreatedBy(widget.snap['createdBy']);
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
            return const SizedBox(
              height: 380.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final author = snapshot.data?.profile?.fullName;
            final authorImage = snapshot.data?.profile?.profileImage;
            return Container(
              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor), color: darkModeOn ? darkColor : lightColor),
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
                              Text(
                                DateFormat.yMMMd().format(
                                  widget.snap['datePublished']?.toDate() ?? DateTime.now()
                                ),
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
                            ],
                          ),
                        ),
                      ),
                      kIsWeb
                    ? IconButton(
                        onPressed: () {
                        showDialog<dynamic>(
                          context: context,
                          builder: (context) => Dialog(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children: 
                              ['Delete',].map((e) => InkWell(
                                onTap: () async {
                                  FireStoreEventMethods()
                                    .removeEvent(widget
                                    .snap['id']);
                                    Navigator.of(context)
                                    .pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text(e)),
                                  )
                                ).toList(),
                              ),
                            )
                          );
                        },
                        icon: const Icon(Icons.more_vert))
                    : const SizedBox.shrink(),
                    ]),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: (widget.snap['image'] == null ||
                              widget.snap['image'] == '')
                          ? Image.network(
                              'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.snap['image'] ??
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
                      label: Text('View this ${widget.snap['type'] == 'Academic' ? 'announcement' : 'event'}'),
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
                                  '${widget.snap['description'] ?? 'default_description'}',
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
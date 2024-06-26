import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/edit_event_screen.dart';
import 'package:student_event_calendar/screens/move_event_screen.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import 'package:timezone/timezone.dart' as tz;

class PostCard extends StatefulWidget {
  const PostCard({Key? key, required this.snap}) : super(key: key);
  final Event snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Stream<model.User> userDetails;
  bool isLoadingCancel = false;
  final FirebaseNotificationService _firebaseNotificationService = FirebaseNotificationService();


  @override
  void initState() {
    super.initState();
    userDetails = FireStoreUserMethods().getUserByEventsCreatedByStream(widget.snap.createdBy!);
  }

  String formatParticipants(Map<String, dynamic>? participants) {
    List<String> formattedList = [];
    participants?.removeWhere((key, value) => (value as List).isEmpty);
    participants?.forEach((key, value) {
      String formattedString =
          '${key[0].toUpperCase()}${key.substring(1)}: ${(value as List).join(', ')}';
      formattedList.add(formattedString);
    });
    return formattedList.join('\n');
  }

  Future<void> setEventCancellation(Event event, String userType, DateTime startDate, DateTime endDate, DateTime startTime, DateTime endTime) async {
    if (!mounted || isLoadingCancel) return; // Guard clause to avoid re-entry or state updates when widget is not mounted

    setState(() {
      isLoadingCancel = true;
    });

    try {
      String response = await FireStoreEventMethods().updateEventStatus(
        event.id!,
        true,
        null,
        startDate,
        endDate,
        startTime,
        endTime
      );

      print('Update Event Response Cancelled: $response'); // Using print as a fallback if kDebugMode is not available
      
      if (response == 'Success') {
        onCancelSuccess(); // Consider implementing this to show success feedback to the user

        String senderId = FirebaseAuth.instance.currentUser!.uid;

        // Send notification to all participants
        if (event.participants != null) {
          for (var department in event.participants!['department'] ?? []) {
            for (var program in event.participants!['program'] ?? []) {
              await _firebaseNotificationService.sendNotificationToUsersInDepartmentAndProgram(
                senderId, department, program, 'Event Cancelled', 'The event "${event.title}" has been cancelled.'
              );
            }
          }
        }
      } else {
        onCancelFailure(response); // Consider implementing this to show error feedback to the user
      }
    } catch (e) {
      print(e); // Consider showing an error message to the user
      onCancelFailure('An error occurred while cancelling the event.'); // Provide a generic error message
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCancel = false;
        });
      }
    }
  }

  void onCancelSuccess() async {
    setState(() {
      isLoadingCancel = false;
    });
    if ((await AuthMethods().getCurrentUserType()) == 'Officer') {
      if (mounted) {
        showSnackBar('Update sent for approval successfully!', context);
      }
    } else {
      if (mounted) {
        showSnackBar('Event cancelled successfully!', context);
      }
    }
  }

  void onCancelFailure(String message) {
    setState(() {
      isLoadingCancel = false;
    });
    showSnackBar(message, context);
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return StreamBuilder<model.User>(
        stream: userDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 380.0,
              child: Center(
                child: CSPCFadeLoader(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final author = snapshot.data?.profile?.fullName;
            final authorType = snapshot.data?.userType;
            final authorImage = snapshot.data?.profile?.profileImage != null ? snapshot.data?.profile?.profileImage!.trim() : '';
            final datePublished = widget.snap.datePublished ?? DateTime.now().toUtc();
            final manila = tz.getLocation('Asia/Manila');
            final localTime = tz.TZDateTime.from(datePublished, manila);

            // For Staff and Officer View Only
            return FirebaseAuth.instance.currentUser?.uid == widget.snap.createdBy && (authorType == 'Staff' || authorType == 'Officer')
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
                        backgroundImage: authorImage != null && authorImage.isNotEmpty 
                          ? NetworkImage(authorImage)
                          : const NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
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
                                style: TextStyle(
                                  color: darkModeOn ? lightColor : darkColor,
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
                          builder: (context) {
                            return SimpleDialog(
                              title: Row(
                                children: [
                                  Icon(Icons.delete_forever,
                                    color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Delete Event',
                                    style: TextStyle(
                                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  child: Text(
                                    'Are you sure you want to delete "${widget.snap.title}"?',
                                    style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                    ),
                                ),
                                SimpleDialogOption(
                                  padding: const EdgeInsets.all(20),
                                  onPressed: () async {
                                    bool isConnected = await ConnectivityService().isConnected();
                                    if (isConnected) {
                                      mounted ? Navigator.of(context).pop() : '';
                                      await FireStoreEventMethods().trashEvent(widget.snap.id!);
                                    } else {
                                      // Show a message to the user
                                      mounted ? Navigator.of(context).pop() : '';
                                      mounted ? ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
                                          duration: const Duration(seconds: 5),
                                        ),
                                      ) : '';
                                    }
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.check_circle, 
                                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                                      const SizedBox(width: 10),
                                      Text('Yes', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.cancel, color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                                      const SizedBox(width: 10),
                                      Text('No', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton.icon(
                          onPressed: widget.snap.status != 'Past' ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditEventScreen(
                                  eventSnap: widget.snap,
                                ),
                              ),
                            );
                          } : null,
                          icon: const Icon(Icons.edit_calendar, size: 20, color: lightColor,),
                          label: Text('Update ${widget.snap.title}', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                darkModeOn ? 
                                (widget.snap.status != 'Past' ? darkModePrimaryColor : Colors.grey[400]!) : 
                                (widget.snap.status != 'Past' ? lightModePrimaryColor : Colors.grey[400]!)
                                ), 
                              foregroundColor: MaterialStateProperty.all<Color>(lightColor)
                            ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton.icon(
                          onPressed: widget.snap.status != 'Past' ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MoveEventScreen(
                                  eventSnap: widget.snap,
                                ),
                              ),
                            );
                          } : null,
                          icon: const Icon(Icons.edit_calendar, size: 20, color: lightColor,),
                          label: Text('Move ${widget.snap.title}', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                darkModeOn ? 
                                (widget.snap.status != 'Past' ? darkModeSecondaryColor : Colors.grey[400]!) : 
                                (widget.snap.status != 'Past' ? lightModeSecondaryColor : Colors.grey[400]!) 
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(lightColor)
                            ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton.icon(
                          onPressed: widget.snap.status != 'Past' ? () async {
                            // cancel event
                            setEventCancellation(
                              widget.snap, 
                              await AuthMethods().getCurrentUserType(), 
                              widget.snap.startDate!, 
                              widget.snap.endDate!, 
                              widget.snap.startTime!, 
                              widget.snap.endTime!
                            );
                          } : null,
                          icon: const Icon(Icons.edit_calendar, size: 20, color: lightColor,),
                          label: Text('Cancel ${widget.snap.title}', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                darkModeOn ? 
                                  (widget.snap.status != 'Past' ? darkModeMaroonColor : Colors.grey[400]!) : 
                                  (widget.snap.status != 'Past' ? lightModeMaroonColor : Colors.grey[400]!)
                                ),
                              foregroundColor: MaterialStateProperty.all<Color>(lightColor)
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                        size: kIsWeb ? 21 : 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(child: Text(widget.snap.venue ?? '', textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: kIsWeb ? 14 : 11, color: darkModeOn ? lightColor : darkColor),)),
                                    ],
                                  ), 
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.group,
                                        color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                        size: kIsWeb ? 21 : 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(child: Text(formatParticipants(widget.snap.participants), textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: kIsWeb ? 14 : 11, color: darkModeOn ? lightColor : darkColor),)),
                                    ],
                                  ), 
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                        size: kIsWeb ? 21 : 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(child: Text(widget.snap.description!, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: kIsWeb ? 14 : 11, color: darkModeOn ? lightColor : darkColor),)),
                                    ],
                                  ),    
                                                              
                              ]),
                          ),
                        ]),
                  ),
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
                        backgroundImage: authorImage != null && authorImage.isNotEmpty 
                          ? NetworkImage(authorImage)
                          : const NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
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
                                style: TextStyle(
                                  color: darkModeOn ? lightColor : darkColor,
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
                      Chip(
                        label: Text(
                          widget.snap.status!,
                          style: const TextStyle(
                            color: lightColor
                          ),
                        ),
                        backgroundColor: widget.snap.status == 'Cancelled'
                        ? (darkModeOn
                            ? darkModeMaroonColor
                            : lightModeMaroonColor)
                        : widget.snap.status == 'Upcoming'
                            ? (darkModeOn
                                ? darkModePrimaryColor
                                : lightModePrimaryColor)
                            : widget.snap.status == 'Moved'
                                ? (darkModeOn
                                    ? darkModeSecondaryColor
                                    : lightModeSecondaryColor)
                                : widget.snap.status == 'Past'
                                    ? black
                                    : (darkModeOn
                                        ? darkModeGrassColor
                                        : lightModeGrassColor),
                      ),
                      IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: Row(
                                children: [
                                  Icon(Icons.delete_forever,
                                    color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Delete Event',
                                    style: TextStyle(
                                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  child: Text(
                                    'Are you sure you want to delete "${widget.snap.title}"?',
                                    style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                    ),
                                ),
                                SimpleDialogOption(
                                  padding: const EdgeInsets.all(20),
                                  onPressed: () async {
                                    bool isConnected = await ConnectivityService().isConnected();
                                    if (isConnected) {
                                      mounted ? Navigator.of(context).pop() : '';
                                      await FireStoreEventMethods().trashEvent(widget.snap.id!);
                                    } else {
                                      // Show a message to the user
                                      mounted ? Navigator.of(context).pop() : '';
                                      mounted ? ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
                                          duration: const Duration(seconds: 5),
                                        ),
                                      ) : '';
                                    }
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.check_circle, 
                                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                                      const SizedBox(width: 10),
                                      Text('Yes', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.cancel, color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                                      const SizedBox(width: 10),
                                      Text('No', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton.icon(
                          onPressed: widget.snap.status != 'Past' ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditEventScreen(
                                  eventSnap: widget.snap,
                                ),
                              ),
                            );
                          } : null,
                          icon: const Icon(Icons.edit_calendar, size: 20, color: lightColor,),
                          label: Text('Update ${widget.snap.title}', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                darkModeOn ? 
                                (widget.snap.status != 'Past' ? darkModePrimaryColor : Colors.grey[400]!) : 
                                (widget.snap.status != 'Past' ? lightModePrimaryColor : Colors.grey[400]!)
                                ), 
                              foregroundColor: MaterialStateProperty.all<Color>(lightColor)
                            ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton.icon(
                          onPressed: widget.snap.status != 'Past' ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MoveEventScreen(
                                  eventSnap: widget.snap,
                                ),
                              ),
                            );
                          } : null,
                          icon: const Icon(Icons.edit_calendar, size: 20, color: lightColor,),
                          label: Text('Move ${widget.snap.title}', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                darkModeOn ? 
                                (widget.snap.status != 'Past' ? darkModeSecondaryColor : Colors.grey[400]!) : 
                                (widget.snap.status != 'Past' ? lightModeSecondaryColor : Colors.grey[400]!) 
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(lightColor)
                            ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton.icon(
                          onPressed: widget.snap.status != 'Past' ? () async {
                            // cancel event
                            setEventCancellation(
                              widget.snap, 
                              await AuthMethods().getCurrentUserType(), 
                              widget.snap.startDate!, 
                              widget.snap.endDate!, 
                              widget.snap.startTime!, 
                              widget.snap.endTime!
                            );
                          } : null,
                          icon: const Icon(Icons.edit_calendar, size: 20, color: lightColor,),
                          label: Text('Cancel ${widget.snap.title}', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                darkModeOn ? 
                                  (widget.snap.status != 'Past' ? darkModeMaroonColor : Colors.grey[400]!) : 
                                  (widget.snap.status != 'Past' ? lightModeMaroonColor : Colors.grey[400]!)
                                ),
                              foregroundColor: MaterialStateProperty.all<Color>(lightColor)
                            ),
                        ),
                      ),
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
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: darkModeOn
                                          ? darkModeSecondaryColor
                                          : lightModeSecondaryColor,
                                      size: kIsWeb ? 21 : 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(child: Text(widget.snap.venue ?? '', textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: kIsWeb ? 14 : 11, color: darkModeOn ? lightColor : darkColor,),)),
                                  ],
                                ), 
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: darkModeOn
                                          ? darkModeSecondaryColor
                                          : lightModeSecondaryColor,
                                      size: kIsWeb ? 21 : 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(child: Text(formatParticipants(widget.snap.participants), textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: kIsWeb ? 14 : 11, color: darkModeOn ? lightColor : darkColor,),)),
                                  ],
                                ), 
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: darkModeOn
                                          ? darkModeSecondaryColor
                                          : lightModeSecondaryColor,
                                      size: kIsWeb ? 21 : 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(child: Text(widget.snap.description!, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: kIsWeb ? 14 : 11, color: darkModeOn ? lightColor : darkColor,),)),
                                  ],
                                ),    
                                                            
                            ]),
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

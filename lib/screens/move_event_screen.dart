import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import '../providers/darkmode_provider.dart';
import '../utils/global.dart';

class MoveEventScreen extends StatefulWidget {
  const MoveEventScreen({Key? key, required this.eventSnap}) : super(key: key);

  final Event eventSnap;
  @override
  State<MoveEventScreen> createState() => MoveEventScreenState();
}

class MoveEventScreenState extends State<MoveEventScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final FirebaseNotificationService _firebaseNotificationService = FirebaseNotificationService();

  Future<model.User?> currentUser = AuthMethods().getCurrentUserDetails();
  bool _isLoadingMoved = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetConstants();
    _startDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.eventSnap.startDate!);
    _endDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.eventSnap.endDate!);
    _startTimeController.text =
        DateFormat('h:mm a').format(widget.eventSnap.startTime!);
    _endTimeController.text =
        DateFormat('h:mm a').format(widget.eventSnap.endTime!);
  }

  setEventMoved(String userType, Event event) async {
    setState(() {
      _isLoadingMoved = true;
    });
    try {
      String response = await FireStoreEventMethods()
          .updateEventStatus(
            widget.eventSnap.id!,
            null,
            true,
            event.startDate!,
            event.endDate!,
            event.startTime!,
            event.endTime!
          );

      if (kDebugMode) {
        print('Update Event Response Moved: $response');
      }
      if (response == 'Success') {
        onPostSuccess();
        setState(() {
          _isLoadingMoved = false;
        });

        String senderId = FirebaseAuth.instance.currentUser!.uid;

        // Construct the notification message with all details
        String notificationMessage = 'The event "${event.title}" has been rescheduled.\n\n'
          'New Start Date: ${DateFormat('EEEE, MMMM d, yyyy').format(event.startDate!)}\n'
          'New End Date: ${DateFormat('EEEE, MMMM d, yyyy').format(event.endDate!)}\n'
          'Start Time: ${DateFormat('h:mm a').format(event.startTime!)}\n'
          'End Time: ${DateFormat('h:mm a').format(event.endTime!)}\n'
          'Venue: ${event.venue ?? "to be announced"}\n'
          'Event Type: ${event.type ?? "not specified"}\n'
          'Details: ${event.description ?? "Please check the event details for more information."}\n\n'
          'Please update your calendars accordingly and stay tuned for further updates. We apologize for any inconvenience this may cause and look forward to your participation.';

        // Send a notification to all participants
        if (event.participants != null) {
          for (var participant in event.participants!['department']) {
            for (var participantProgram in event.participants!['program']) {
              await _firebaseNotificationService.sendNotificationToUsersInDepartmentAndProgram(
                senderId, participant, participantProgram, 'Event Rescheduled', notificationMessage
              );
            }
          }
        }
      } else {
        onPostFailure(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _update(String userType, bool isMoved, bool isCancelled) async {
    if (kDebugMode) {
      print('Post function started!');
    }

    // Show a SnackBar with a loading message
    showSnackBar('Updating event...', context);

    try {
      if (kDebugMode) {
        print('Trying to update event...');
      }
      // Check if all required parameters are not null
      if (_startDateController.text.isNotEmpty &&
          _endDateController.text.isNotEmpty &&
          _startTimeController.text.isNotEmpty &&
          _endTimeController.text.isNotEmpty) {
        // Get the date and time from the text controllers
        String pickedStartDate = _startDateController.text;
        String pickedEndDate = _endDateController.text;
        String pickedStartTime = _startTimeController.text;
        String pickedEndTime = _endTimeController.text;
        // Convert picked date (yyyy-mm-dd) to DateTime
        DateTime startDate = DateTime.parse(pickedStartDate);
        DateTime endDate = DateTime.parse(pickedEndDate);
        // Get only the date part as a DateTime object
        DateTime startDatePart =
            DateTime(startDate.year, startDate.month, startDate.day);
        DateTime endDatePart =
            DateTime(endDate.year, endDate.month, endDate.day);
        // Parse 12-hour format time string to DateTime
        DateFormat time12Format = DateFormat('h:mm a');
        DateTime startTime12 = time12Format.parse(pickedStartTime);
        DateTime endTime12 = time12Format.parse(pickedEndTime);

        Event event = Event(
          id: widget.eventSnap.id,
          title: widget.eventSnap.title,
          type: widget.eventSnap.type,
          venue: widget.eventSnap.venue,
          image: widget.eventSnap.image,
          document: widget.eventSnap.document,
          description: widget.eventSnap.description,
          createdBy: widget.eventSnap.createdBy,
          participants: widget.eventSnap.participants,
          startDate: startDatePart,
          endDate: endDatePart,
          startTime: startTime12,
          endTime: endTime12,
          approvalStatus: (userType == 'Admin' || userType == 'Staff') ? 'approved' : 'pending',
          status: widget.eventSnap.status, // TODO: change this
          dateUpdated: DateTime.now(),
          datePublished: widget.eventSnap.datePublished,
        );

        // Show a dialog to enter the user's password
        // ignore: use_build_context_synchronously
        String? password = await showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
            String? password;
            return AlertDialog(
              title: Text(
                'Enter your password',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
              ),
              content: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                onChanged: (value) => password = value,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isLoadingMoved = false;
                    });
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(password);
                  },
                ),
              ],
            );
          },
        );

        String? response;

        // If the password is not null, re-authenticate the user
        if (password != null) {
          User? user = FirebaseAuth.instance.currentUser;
          AuthCredential credential = EmailAuthProvider.credential(
            email: user!.email!,
            password: password,
          );

          // Re-authenticate the user
          try {
            await user.reauthenticateWithCredential(credential);

            // Update the event to the database
            response = await FireStoreEventMethods()
                .updateEvent(widget.eventSnap.id!, event, userType);

              // If the event status is moved 
              if (isMoved) {
                await setEventMoved(
                  userType, 
                  event
                );
              }

            // Print update status response
            if (kDebugMode) {
              print('Update Event Response: $response');
            }
            // Check if the response is a success or a failure
            if (response == 'Success') {
              onPostSuccess();
            } else {
              onPostFailure(response);
            }
          } catch (e) {
            // If the re-authentication fails, show an error message
            // ignore: use_build_context_synchronously
            showSnackBar('Incorrect password. Please try again.', context);
          }
        }

        return response;
      } else {
        if (kDebugMode) {
          print('Complete all required parameters!');
        }
        setState(() => _isLoadingMoved = false);
        // Show a snackbar if the image and document are not loaded
        mounted
            ? showSnackBar('Please complete the required fields.*', context)
            : '';
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void onPostSuccess() async {
    setState(() {
      _isLoadingMoved = false;
    });
    Navigator.pop(context);
    if ((await AuthMethods().getCurrentUserType()) == 'Officer') {
      if (mounted) {
        showSnackBar('Update sent for approval successfully!', context);
      }
    } else {
      if (mounted) {
        showSnackBar('Event moved successfully!', context);
      }
    }
    clearInputs();
  }

  void onPostFailure(String message) {
    setState(() {
      _isLoadingMoved = false;
    });
    showSnackBar(message, context);
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void clearInputs() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
    });
  }

  // Disposing after changing
  @override
  void dispose() {
    super.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
  }

    @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder<model.User?>(
      future: currentUser,
      builder: (context, AsyncSnapshot<model.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CSPCFadeLoader());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          model.User? currentUser = snapshot.data;
          return currentUser?.userType != 'Student'
              ? ScaffoldMessenger(
                  key: _scaffoldMessengerKey,
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text(
                          'Edit ${widget.eventSnap.type == 'Academic' ? 'Announcement' : 'Event'}',
                          style: TextStyle(
                            color: darkModeOn ? white : black,
                          ),
                        ),
                        backgroundColor: darkModeOn ? darkColor : lightColor,
                        iconTheme: IconThemeData(
                          color: darkModeOn ? white : black,
                        ),
                      ),
                      body: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: kIsWeb
                                    ? (width > webScreenSize ? width * 0.2 : 0)
                                    : 0),
                            child: Padding(
                              padding: const EdgeInsets.all(kIsWeb ? 8.0 : 2),
                              child: Card(
                                color: darkModeOn ? darkColor : lightColor,
                                child: Padding(
                                  padding: kIsWeb
                                      ? const EdgeInsets.all(30.0)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: darkModeOn
                                                    ? lightColor
                                                    : darkColor,
                                                size: kIsWeb ? 40 : 25,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Move "${widget.eventSnap.title}"',
                                                  style: TextStyle(
                                                    fontSize:
                                                        kIsWeb ? 32.0 : 24.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkModeOn
                                                        ? lightColor
                                                        : darkColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Instructions: Please edit the required* details correctly and then update the announcement.',
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: darkModeOn
                                                        ? darkModeTertiaryColor
                                                        : lightModeTertiaryColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30,),
                                      Flexible(
                                        child: Row(children: [
                                          Flexible(
                                            child: TextFieldInput(
                                              startTextEditingController:
                                                  _startDateController,
                                              endTextEditingController:
                                                  _endDateController,
                                              isDateRange: true,
                                              labelText: 'Event Date',
                                              textInputType:
                                                  TextInputType.datetime,
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Flexible(
                                            child: TextFieldInput(
                                              startTextEditingController:
                                                  _startTimeController,
                                              endTextEditingController:
                                                  _endTimeController,
                                              isTimeRange: true,
                                              labelText: 'Event Time',
                                              textInputType:
                                                  TextInputType.datetime,
                                            ),
                                          )
                                        ]),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text('Note: * indicates required field', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                                      const SizedBox(height: 5.0),
                                      Text('Event Status also updates when you update the event.', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                                      const SizedBox(height: 10.0),
                                      Center(
                                        child: InkWell(
                                          onTap: () async {
                                            bool isConnected = await ConnectivityService().isConnected();
                                            if (isConnected) {
                                              await _update(currentUser!.userType!, true, false);
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
                                          child: Container(
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0),
                                              decoration: ShapeDecoration(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5.0)),
                                                ),
                                                color: darkModeOn
                                                    ? darkModePrimaryColor
                                                    : lightModePrimaryColor,
                                              ),
                                              child: _isLoadingMoved
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              darkModeOn ? darkColor : lightColor),
                                                    ))
                                                  : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.update,
                                                        color: darkModeOn ? darkColor : lightColor,
                                                      ),
                                                      const SizedBox(width: 10.0),
                                                      Text(
                                                          'Move ${widget.eventSnap.type == 'Academic' ? 'announcement' : 'event'}',
                                                          style: TextStyle(
                                                            color: darkModeOn ? darkColor : lightColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    ],
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox();
        }
      },
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/event_image_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';

class PendingEventsScreen extends StatelessWidget {
  final FireStoreEventMethods _fireStoreEventMethods = FireStoreEventMethods();
  final FireStoreUserMethods _fireStoreUserMethods = FireStoreUserMethods();

  PendingEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: kIsWeb ? AppBar(title: const Text('Pending Events')) : const PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: SizedBox.shrink()),
      body: StreamBuilder<List<Event>>(
        stream: _fireStoreEventMethods.getPendingEvents(),
        builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: darkModeOn ? lightColor : darkColor)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Enjoy! No pending events for now.', style: TextStyle(color: darkModeOn ? lightColor : darkColor)));
          }

          List<Event> events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              Event event = events[index];
              return StreamBuilder(
                stream: _fireStoreUserMethods.getUserByEventsCreatedByStream(event.createdBy),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: darkModeOn ? lightColor : darkColor)));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No user found.', style: TextStyle(color: darkModeOn ? lightColor : darkColor)));
                  }

                  var user = snapshot.data;
                  Event displayEvent = event;
                  return Card(
                    child: Column(
                      children: [
                        if (displayEvent.image != null && displayEvent.image!.isNotEmpty)
                          TextButton(
                            child: Text('View Image'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventImageScreen(imageUrl: displayEvent.image!, title: displayEvent.title),
                                ),
                              );
                            },
                          ),
                        ListTile(
                          title: Text(displayEvent.title, style: TextStyle(fontSize: 20),),
                          subtitle: Text('Created by: ${user.profile.fullName}\nUser type: ${user.userType}\nStart date: ${displayEvent.startDate}\nEnd date: ${displayEvent.endDate}\nStart time: ${displayEvent.startTime}\nEnd time: ${displayEvent.endTime}\nDescription: ${displayEvent.description}\nVenue: ${displayEvent.venue}\nType: ${displayEvent.type}\nStatus: ${displayEvent.status}\nHas feedback: ${displayEvent.hasFeedback}\nApproval status: ${displayEvent.approvalStatus}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Approve Event', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                                        content: Text('Are you sure you want to approve this event? This event will be displayed in the calendar after approval.', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Approve'),
                                            onPressed: () async {
                                              bool success = await _fireStoreEventMethods.approveOrRejectEvent(event.id, true);
                                               if (Navigator.canPop(context)) {
                                                  Navigator.of(context).pop();
                                                }

                                              if (success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Event approved')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Reject Event', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                                        content: Text('Are you sure you want to reject this event? The event will also be deleted after rejection.', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Reject'),
                                            onPressed: () async {
                                              bool success = await _fireStoreEventMethods.approveOrRejectEvent(event.id, false);
                                              Navigator.of(context).pop();
                                              if (success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Event rejected')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
// import 'package:student_event_calendar/providers/dialog_provider.dart';
import 'package:student_event_calendar/resources/firestore_personal_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';

class PersonalEventsScreen extends StatefulWidget {
  const PersonalEventsScreen({super.key});

  @override
  State<PersonalEventsScreen> createState() => _PersonalEventsScreenState();
}

class _PersonalEventsScreenState extends State<PersonalEventsScreen> {
  final _fireStorePersonalEventMethods = FireStorePersonalEventMethods();

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    // var dialogShown = Provider.of<DialogProvider>(context);
    return Scaffold(
      body: StreamBuilder<List<PersonalEvent>>(
        stream: _fireStorePersonalEventMethods.getPersonalEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // TODO: Fix this
            // if (Provider.of<DialogProvider>(context).dialogShown == false) {
              Future.delayed(Duration.zero, () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('No personal events found'),
                  content: const Text('Would you like to create a new one?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        // Navigate to the personal event creation screen
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        /* TODO: fix this */
                        // dialogShown.setDialogShown(true);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ));
            // }
            
            return const Center(child: Text('No personal events found'));
          }

          // Snapshot contains the list of personal events
          List<PersonalEvent>? personalEvents = snapshot.data;

          return ListView.builder(
            itemCount: personalEvents?.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(personalEvents![index].title),
                  // ... Other ListTile properties like subtitle, trailing etc.
                ),
              );
            },
          );
        },
      ),
    );
  }
}

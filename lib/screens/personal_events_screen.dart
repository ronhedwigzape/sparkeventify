import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_personal_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/add_personal_event.dart';

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
    return Scaffold(
      body: StreamBuilder<List<PersonalEvent>>(
        stream: _fireStorePersonalEventMethods.getPersonalEvents(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
          }
          else if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
              Future.delayed(Duration.zero, () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('No personal events found'),
                  content: const Text('Would you like to create a new one?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Future.delayed(Duration.zero, () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPersonalEvent()));
                        });
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ));
            
            return const Center(child: Text('No personal events found'));
          }

          // Snapshot contains the list of personal events
          List<PersonalEvent>? personalEvents = snapshot.data;
          final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
          personalEvents = personalEvents!.where((event) => event.createdBy == 
          currentUserUid).toList();

          if (personalEvents.isEmpty) {
            Future.delayed(Duration.zero, () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No personal events found'),
                content: const Text('Would you like to create a new one?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Future.delayed(Duration.zero, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPersonalEvent()));
                      });
                    },
                  ),
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ));

            return const Center(child: Text('Create your first personal event!'));
          }

          return ListView.builder(
            itemCount: personalEvents.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(personalEvents![index].title),
                  /* Make customized personal event card here */
                  // ... Other ListTile properties like subtitle, trailing etc.
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
        child: const Icon(Icons.add, size: 24),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPersonalEvent(),
            ),
          );
        },
      ),
    );
  }
}

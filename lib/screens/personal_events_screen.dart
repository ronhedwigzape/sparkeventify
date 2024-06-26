import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_personal_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/add_personal_event.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import 'package:student_event_calendar/widgets/personal_event_note.dart';

class PersonalEventsScreen extends StatefulWidget {
  const PersonalEventsScreen({super.key});

  @override
  State<PersonalEventsScreen> createState() => _PersonalEventsScreenState();
}

class _PersonalEventsScreenState extends State<PersonalEventsScreen> {
  final _fireStorePersonalEventMethods = FireStorePersonalEventMethods();

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      body: StreamBuilder<List<PersonalEvent>>(
        stream: _fireStorePersonalEventMethods.getPersonalEvents(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CSPCFadeLoader());
          }
          else if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          if (!snapshot.hasData && snapshot.data!.isEmpty) {
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
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note),
                    const SizedBox(width: 10.0,),
                    Flexible(
                      child: Text(
                        'No personal events found',
                        style: TextStyle(
                          color: darkModeOn ? white : black
                        ),
                      )
                    ),
                  ],
                ),
                content: Text('Would you like to create a new one?', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                actions: <Widget>[
                  TextButton(
                    child: Text('Yes', style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),),
                    onPressed: () {
                      Future.delayed(Duration.zero, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPersonalEvent()));
                      });
                    },
                  ),
                  TextButton(
                    child: Text('No', style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ));

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 25.0, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                        const SizedBox(width: 10.0,),
                        Flexible(
                          child: Text(
                            'Create your first personal event!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor
                            ),
                          )),
                      ],
                    ),
                  ],
                ),
              ),
            ); 
          }

          // Sort the personalEvents list in descending order of dateUpdated
          personalEvents.sort((a, b) => b.dateUpdated!.compareTo(a.dateUpdated!));

          return Stack(
            children: [
              SmartRefresher(
                enablePullDown: true,
                header: const WaterDropHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemCount: personalEvents.length,
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  itemBuilder: (context, index) {
                    return PersonalEventNote(
                      personalEvent: personalEvents?[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
        child: const Icon(Icons.add, size: 24, color: white,),
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

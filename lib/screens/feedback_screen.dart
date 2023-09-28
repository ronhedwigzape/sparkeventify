import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/feedback_form.dart';
import '../providers/darkmode_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  final Future<Map<DateTime, List<Event>>> _events = FireStoreEventMethods().getEventsByDate();
  Set<Event> pastEvents = {};

  @override
  void initState() {
    super.initState();

    // Create then() method to wait for the _events Future to complete
    _events.then((events) {
      DateTime now = DateTime.now();

      // Get past events
      events.forEach((eventDate, events) {
        if (eventDate.isBefore(now)) {
          pastEvents.addAll(events);  // Add all events of days in past
        } else if (eventDate.day == now.day) {
          for (var event in events) {
            if (event.endDate.isBefore(now)) {
              pastEvents.add(event);  // Add events that ended today
            }
          }
        }
      });

      // Convert the Set to a List for sorting
      List<Event> pastEventsList = pastEvents.toList();

      // Sort past events by date
      pastEventsList.sort((a, b) => b.startDate.compareTo(a.startDate));

      // Update the Set with the sorted List
      setState(() {
        pastEvents = pastEventsList.toSet();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    DateTime now = DateTime.now();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
        image: !kIsWeb ? DecorationImage(
            image: AssetImage('assets/images/cspc_background.jpg'),
            opacity: 0.5,
            fit: BoxFit.fill,
          ) : null,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                ...pastEvents.map((event) {
                  DateTime endDate = event.endDate.isAfter(now) ? now.subtract(const Duration(days: 1)) : event.endDate;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Card( 
                      elevation: 1,
                      shadowColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          // Parallax image with opacity
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.2,
                              child: CachedNetworkImage(
                                imageUrl: event.image ?? 'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    child: Center(
                                      child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                                    ),
                                  ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          // Event details
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: SizedBox(
                                      width: 100 * 6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(event.title, style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,),
                                          Text(
                                            (event.startDate.day == endDate.day
                                                ? '${DateFormat('MMM dd, yyyy').format(event.startDate)}\n'
                                                : '${DateFormat('MMM dd, yyyy').format(event.startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}\n')
                                                + (event.startTime.hour == event.endTime.hour && event.startTime.minute == event.endTime.minute
                                                ? DateFormat.jm().format(event.startTime)
                                                : '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'),
                                            style: const TextStyle(
                                                height: 1.5,
                                                fontSize: 10
                                            ),
                                          ),
                                          FeedbackForm(eventId: event.id)
                                        ],                        
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        )
      ),
    );
  }
}

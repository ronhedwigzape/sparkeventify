import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import '../providers/darkmode_provider.dart';
import '../utils/colors.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents(this._events, {Key? key}) : super(key: key);

  final Map<DateTime, List<Event>> _events;

  @override
  UpcomingEventsState createState() => UpcomingEventsState();
}

class UpcomingEventsState extends State<UpcomingEvents> {
  Set<Event> upcomingEvents = {};

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    // Get upcoming events
    widget._events.forEach((eventDate, events) {
      if (eventDate.isAfter(now)) {
        upcomingEvents.addAll(events);  // Add all events of days in future
      } else if (eventDate.day == now.day) {
        for (var event in events) {
          if (event.endDate!.isAfter(now)) {
            upcomingEvents.add(event);  // Add ongoing events
          }
        }
      }
    });

    // Convert the Set to a List for sorting
    List<Event> upcomingEventsList = upcomingEvents.toList();

    // Sort upcoming events by date
    upcomingEventsList.sort((a, b) => a.startDate!.compareTo(b.startDate!));

    // Update the Set with the sorted List
    upcomingEvents = upcomingEventsList.toSet();
  }

  @override
  Widget build(BuildContext context) {

    String formatParticipants(Map<String, dynamic>? participants) {
      List<String> formattedList = [];
      participants?.removeWhere((key, value) => (value as List).isEmpty);
      participants?.forEach((key, value) {
        String formattedString =
            '${key[0].toUpperCase()}${key.substring(1)}: ${(value as List).join(', ')}';
        formattedList.add(formattedString);
      });
      return formattedList.join('\n\n');
    }

    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    DateTime now = DateTime.now();
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: kIsWeb ? 600 : double.infinity,
          child: Card(
            elevation: 2,
            color: darkModeOn ? darkColor : lightColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Upcoming Events!',
                    style: TextStyle(
                        color: darkModeOn ? lightColor : darkColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  ...(upcomingEvents.isEmpty) ? [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No upcoming events for now..', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                      ),
                    )]
                  : upcomingEvents.map((event) {
                    DateTime startDate = event.startDate!.isBefore(now) ? now.add(const Duration(days: 1)) : event.startDate!;
                    return Card(
                      elevation: 0,
                      color: darkModeOn ? darkColor : lightColor,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(140, 10, 80, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (event.image?.isEmpty ?? true)
                            ? Container(
                              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                  width: 300,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      height: kIsWeb ? 250.0 : 100,
                                      child: Center(
                                        child: CSPCFadeLoader()),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                            )
                            : CachedNetworkImage(
                                imageUrl: event.image!,
                                width: 300,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    height: kIsWeb ? 250.0 : 100,
                                    child: Center(
                                      child: CSPCFadeLoader()),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            const SizedBox(height: 10),

                            // Event Title
                            Text(
                              event.title!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkModeOn ? lightColor : darkColor,
                                height: 2
                              ),
                            ),

                            // Date and Time
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Flexible(
                                child: Text(
                                  (startDate.day == event.endDate!.day
                                      ? 'Remaining Date: ${DateFormat('MMM dd, yyyy').format(startDate)}'
                                      : 'Remaining Dates: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(event.endDate!)}') +
                                      (event.startTime!.hour == event.endTime!.hour && event.startTime!.minute == event.endTime!.minute
                                          ? '\nTime: ${DateFormat.jm().format(event.startTime!)}'
                                          : '\nTime: ${DateFormat.jm().format(event.startTime!)} - ${DateFormat.jm().format(event.endTime!)}'),
                                  style: TextStyle(
                                    color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,
                                    fontSize: 15,
                                    height: 2
                                  ),
                                ),
                              ),
                            ),
                            Text('Venue: ${event.venue}', style: TextStyle(fontSize: 15, height: 2, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor ),), 
                            Column(
                              children: [
                                Text(
                                  formatParticipants(event.participants),
                                  style: TextStyle(fontSize: 14, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

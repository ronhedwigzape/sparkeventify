import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
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
          if (event.endDate.isAfter(now)) {
            upcomingEvents.add(event);  // Add ongoing events
          }
        }
      }
    });

    // Convert the Set to a List for sorting
    List<Event> upcomingEventsList = upcomingEvents.toList();

    // Sort upcoming events by date
    upcomingEventsList.sort((a, b) => a.startDate.compareTo(b.startDate));

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
      return formattedList.join('\n');
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
                  const Text(
                    'Upcoming Events!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  ...(upcomingEvents.isEmpty) ? [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No upcoming events for now..', textAlign: TextAlign.center,),
                    )]
                  : upcomingEvents.map((event) {
                    DateTime startDate = event.startDate.isBefore(now) ? now.add(const Duration(days: 1)) : event.startDate;
                    return Card(
                      elevation: 0,
                      color: darkModeOn ? darkColor : lightColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            (event.image?.isEmpty ?? true)
                            ? Container(
                              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                  width: 300,
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      height: kIsWeb ? 250.0 : 100,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: darkModeOn
                                            ? darkModePrimaryColor
                                            : lightModePrimaryColor)),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                            )
                            : CachedNetworkImage(
                                imageUrl: event.image!,
                                width: 300,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    height: kIsWeb ? 250.0 : 100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: darkModeOn
                                        ? darkModePrimaryColor
                                        : lightModePrimaryColor)),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ListTile(
                              title: Center(child: Text('Event: ${event.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                              subtitle: Text(
                                (startDate.day == event.endDate.day
                                    ? 'Date: ${DateFormat('MMM dd, yyyy').format(startDate)}\n'
                                    : 'Date: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(event.endDate)}\n')
                                    + (event.startTime.hour == event.endTime.hour && event.startTime.minute == event.endTime.minute
                                    ? 'Time: ${DateFormat.jm().format(event.startTime)}'
                                    : 'Time: ${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(height: 2, fontSize: 15),
                              ),
                              isThreeLine: true,
                            ),
                            Text('Venue: ${event.venue}', style: TextStyle(fontSize: 14, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor ),), 
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

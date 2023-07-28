import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/utils/colors.dart';

import '../providers/darkmode_provider.dart';

class PastEvents extends StatefulWidget {
  const PastEvents(this._events, {Key? key}) : super(key: key);

  final Map<DateTime, List<Event>> _events;

  @override
  PastEventsState createState() => PastEventsState();
}

class PastEventsState extends State<PastEvents> {
  List<Event> pastEvents = [];

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    // Get past events
    widget._events.forEach(
            (eventDate, events) {
          if (eventDate.isBefore(now)) {
            pastEvents.addAll(events);  // Add all events of days in the past
          }
        }
    );

    // Sort past events by date in descending order
    pastEvents.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Center(
      child: SingleChildScrollView(
        child: Card(
          color: darkModeOn ? darkColor : lightColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Past Events',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                ...pastEvents.map((event) {
                  return ListTile(
                    title: Center(child: Text(event.title)),
                    subtitle: Center(
                        child: Text(
                          DateFormat('MMMM dd, yyyy').format(event.date),
                          style: TextStyle(color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor),)),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

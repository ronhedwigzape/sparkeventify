import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/event.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents(this._events, {Key? key}) : super(key: key);

  final Map<DateTime, List<Event>> _events;

  @override
  UpcomingEventsState createState() => UpcomingEventsState();
}

class UpcomingEventsState extends State<UpcomingEvents> {
  List<Event> upcomingEvents = [];

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    // Get upcoming events
    widget._events.forEach(
            (eventDate, events) {
          if (eventDate.isAfter(now)) {
            upcomingEvents.addAll(events);  // Add all events of days in future
          }
        }
    );

    // Sort upcoming events by date
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = upcomingEvents[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.date.toString()),
        );
      },
    );
  }
}

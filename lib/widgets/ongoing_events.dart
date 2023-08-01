import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/utils/colors.dart';
import '../providers/darkmode_provider.dart';

class OngoingEvents extends StatefulWidget {
  const OngoingEvents(this._events, {Key? key}) : super(key: key);

  final Map<DateTime, List<Event>> _events;

  @override
  OngoingEventsState createState() => OngoingEventsState();
}

class OngoingEventsState extends State<OngoingEvents> {
  Set<Event> ongoingEvents = {};

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    // Get ongoing events
    widget._events.forEach((eventDate, events) {
      events.forEach((event) {
        if (event.startDate.isBefore(now) && event.endDate.isAfter(now)) {
          ongoingEvents.add(event);  // Add all ongoing events
        }
      });
    });

    // Convert the Set to a List for sorting
    List<Event> ongoingEventsList = ongoingEvents.toList();

    // Sort ongoing events by start date
    ongoingEventsList.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Update the Set with the sorted List
    ongoingEvents = ongoingEventsList.toSet();
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
                  'Ongoing Events!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                ...ongoingEvents.map((event) {
                  return ListTile(
                    title: Center(child: Text(event.title, style: const TextStyle(fontSize: 16),)),
                    subtitle: Text(
                      (event.startDate.day == event.endDate.day
                          ? '${DateFormat('MMM dd, yyyy').format(event.startDate)}\n'
                          : '${DateFormat('MMM dd, yyyy').format(event.startDate)} - ${DateFormat('MMM dd, yyyy').format(event.endDate)}\n')
                          + (event.startTime.hour == event.endTime.hour && event.startTime.minute == event.endTime.minute
                          ? DateFormat.jm().format(event.startTime)
                          : '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          height: 2,
                          fontSize: 12
                      ),
                    ),
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

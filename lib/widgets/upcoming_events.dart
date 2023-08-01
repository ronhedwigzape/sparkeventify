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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    DateTime now = DateTime.now();
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
                  'Upcoming Events!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                ...upcomingEvents.map((event) {
                  DateTime startDate = event.startDate.isBefore(now) ? now.add(Duration(days: 1)) : event.startDate;
                  return ListTile(
                    title: Center(child: Text(event.title, style: const TextStyle(fontSize: 16),)),
                    subtitle: Text(
                      (startDate.day == event.endDate.day
                          ? '${DateFormat('MMM dd, yyyy').format(startDate)}\n'
                          : '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(event.endDate)}\n')
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

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
  Set<Event> pastEvents = {};

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    // Get past events
    widget._events.forEach((eventDate, events) {
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
    pastEvents = pastEventsList.toSet();
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
                  'Past Events!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                ...pastEvents.map((event) {
                  DateTime endDate = event.endDate.isAfter(now) ? now.subtract(const Duration(days: 1)) : event.endDate;
                  return ListTile(
                    title: Center(child: Text(event.title, style: const TextStyle(fontSize: 16),)),
                    subtitle: Text(
                      (event.startDate.day == endDate.day
                          ? '${DateFormat('MMM dd, yyyy').format(event.startDate)}\n'
                          : '${DateFormat('MMM dd, yyyy').format(event.startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}\n')
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

import 'dart:async';
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
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Defined update function
    void update() {
      DateTime now = DateTime.now();
      TimeOfDay nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Clear the list of ongoing events
      ongoingEvents.clear();

      // Get ongoing events
      widget._events.forEach((eventDate, events) {
        for (var event in events) {
          DateTime startDate = DateTime(
            event.startDate.year,
            event.startDate.month,
            event.startDate.day,
          );

          DateTime endDate = DateTime(
            event.endDate.year,
            event.endDate.month,
            event.endDate.day,
          );


          TimeOfDay endTime = TimeOfDay(
            hour: event.endTime.hour,
            minute: event.endTime.minute,
          );

          if ((now.isAfter(startDate) || now.isAtSameMomentAs(startDate)) && (now.isBefore(endDate) || now.isAtSameMomentAs(endDate))) {
            if (!(now.isAtSameMomentAs(endDate) && (nowTime.hour > endTime.hour || (nowTime.hour == endTime.hour && nowTime.minute > endTime.minute)))) {
              ongoingEvents.add(event);  // Add all ongoing events
            }
          }
        }
      });
    }

    // Call update function every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => update());

    // Call update function immediately on init
    update();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                      '${DateFormat('MMM dd, yyyy').format(now)}\n'
                      '${event.startTime.hour == event.endTime.hour && event.startTime.minute == event.endTime.minute
                          ? DateFormat.jm().format(event.startTime)
                          : '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'}',
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

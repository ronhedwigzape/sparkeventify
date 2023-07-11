import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/events.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendar extends StatefulWidget {
  const EventsCalendar({super.key});

  @override
  State<EventsCalendar> createState() => EventsCalendarState();
}

class EventsCalendarState extends State<EventsCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  final fireStoreEventMethods = FireStoreEventMethods();

  @override
  void initState() {
    super.initState();
    fireStoreEventMethods.getEvents().then((map) {
      setState(() {
        _events = map;
      });
      if (kDebugMode) {
        print(_events);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      eventLoader: (day) {
        return _events[day] ?? [];
      },
      firstDay: DateTime.utc(2015, 01, 01),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        debugPrint('Day selected: $selectedDay');
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _calendarFormat = CalendarFormat.month;
        });
        // TODO: Show events for the selected day
        if (_events[selectedDay] != null) {
          debugPrint('Events: ${_events[selectedDay]}');
          if (_events[selectedDay] != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // TODO: Show dialog if there are events for the selected day
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text('Simple Dialog'),
                  );
                },
              );
            });
          }
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/events.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendar extends StatefulWidget {
  const EventsCalendar({Key? key}) : super(key: key);

  @override
  State<EventsCalendar> createState() => EventsCalendarState();
}

class EventsCalendarState extends State<EventsCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Event>> _events = {};
  final fireStoreEventMethods = FireStoreEventMethods();
  late Future<Map<String, List<Event>>> eventsFuture;

  @override
  void initState() {
    super.initState();
    refreshEvents();
  }

  void refreshEvents() {
    eventsFuture = fireStoreEventMethods.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Event>>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong!"));
        } else {
          _events = snapshot.data!;
          return Column(
            children: [
              TableCalendar(
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
                  if (_events[selectedDay] != null &&
                      _events[selectedDay]!.isNotEmpty) {
                    
                    setState(() {
                      _selectedDay = selectedDay;
                      debugPrint('Day selected: $_selectedDay');
                      _focusedDay = focusedDay;
                      _calendarFormat = CalendarFormat.month;
                    });
                  } else {
                    debugPrint('No events for this day');
                    setState(() {
                      _selectedDay = null;
                      _focusedDay = focusedDay;
                      _calendarFormat = CalendarFormat.month;
                    });
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
              ),
              Expanded(
                child: _selectedDay == null
                    ? const Center(child: Text('No Events For This Day'))
                    : _events[_selectedDay!] != null
                        ? ListView.builder(
                            itemCount: _events[_selectedDay]?.length ?? 0,
                            itemBuilder: (context, index) {
                              final event = _events[_selectedDay]![index];
                              debugPrint('Event: $event');
                              return ListTile(
                                leading: Image.network(event.image!),
                                title: Text(event.title),
                                subtitle: Text(
                                    'Type: ${event.type}\nVenue: ${event.venue}\nDescription: ${event.description}'),
                              );
                            },
                          )
                        : const Center(child: Text('No Events Today')),
              ),
            ],
          );
        }
      },
    );
  }
}

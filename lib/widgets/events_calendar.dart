import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendar extends StatefulWidget {
  const EventsCalendar({Key? key}) : super(key: key);

  @override
  EventsCalendarState createState() => EventsCalendarState();
}

class EventsCalendarState extends State<EventsCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  final fireStoreEventMethods = FireStoreEventMethods();
  late Future<Map<DateTime, List<Event>>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = fireStoreEventMethods.getEventsByDate();
    print('Events: $eventsFuture');
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<Event>>>(
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
                  DateTime adjustedDay =
                      DateTime(day.year, day.month, day.day, 0, 0, 0);
                  return _getEventsForDay(adjustedDay);
                },
                firstDay: DateTime.utc(2015, 01, 01),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  DateTime adjustedSelectedDay = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                      0,
                      0,
                      0 // set the time to midnight
                      );
                  setState(() {
                    _selectedDay = adjustedSelectedDay;
                    _focusedDay = focusedDay;
                    _calendarFormat = CalendarFormat.month;
                  });
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
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    DateTime adjustedDay =
                        DateTime(day.year, day.month, day.day, 0, 0, 0);
                    if (_events.containsKey(adjustedDay)) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day.day.toString(),
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _selectedDay == null
                    // Returns if today has no events because this is the focused day
                    ? const Center(child: Text('No Events Today'))
                    // Returns if there is an event on the selected day
                    : _events[_selectedDay!] != null
                        ? ListView.builder(
                            itemCount: _events[_selectedDay]?.length ?? 0,
                            itemBuilder: (context, index) {
                              final event = _events[_selectedDay]![index];
                              final time = DateFormat('hh:mm a').format(event.time);
                              return ListTile(
                                leading: Image.network(event.image!),
                                title: Text(event.title),
                                subtitle: Text(
                                    'Type: ${event.type}\nVenue: ${event.venue}\nDescription: ${event.description}\nTime: $time'),
                              );
                            },
                          )
                        : const Center(child: Text('No Events For This Day')),
              ),
            ],
          );
        }
      },
    );
  }
}

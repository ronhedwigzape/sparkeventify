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
  final Map<DateTime, List<Event>> _upcomingEvents = {};
  final Map<DateTime, List<Event>> _pastEvents = {};

  @override
  void initState() {
    super.initState();
    eventsFuture = fireStoreEventMethods.getEventsByDate();
    DateTime currentDate = DateTime.now();
    _events.forEach((key, value) {
      if (key.isAfter(currentDate)) {
        _upcomingEvents.putIfAbsent(key, () => value);
      } else {
        _pastEvents.putIfAbsent(key, () => value);
      }
    });
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
                      DateTime(day.year, day.month, day.day, 0, 0, 0).toLocal();
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
                      ).toLocal();
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
                  defaultBuilder: (context, dateTime, focusedDay) {
                    DateTime adjustedDay = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0).toLocal();
                    if (_events.containsKey(adjustedDay)) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: lightIndigo,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: Text(
                          dateTime.day.toString(),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      child: Text(
                        dateTime.day.toString(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _selectedDay == null
                    // Returns if today has no events because this is the focused day
                    ? const Center(child: Text('No Events for today. Enjoy your day!', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),))
                    // Returns if there is an event on the selected day
                    : _events[_selectedDay!] != null
                        ? Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Events for this day', 
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: _events[_selectedDay]?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final event = _events[_selectedDay]![index];
                                    final time = DateFormat('hh:mm a').format(event.time);
                                    return Card( 
                                      margin: const EdgeInsets.all(8.0),  
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: ListTile(
                                          leading: Image.network(event.image!, width: 100.0,),
                                          title: Text(event.title),
                                          titleTextStyle: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          subtitle: Text('Type: ${event.type}\nVenue: ${event.venue}'
                                              '\nDescription: ${event.description}\nTime: $time'),
                                          ),
                                      ),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        )
                        // Returns if there is no event on the selected day
                        : const Center(child: Text('No Events For This Day. Please update later for future events!', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),)),
              ),
              // Upcoming and Past Events
              const Text('Upcoming Events'),
              Expanded(child: _eventListView(_upcomingEvents)),
              const Text('Past Events'),
              Expanded(child: _eventListView(_pastEvents)),
            ],
          );
        }
      },
    );
  }
}

// Returns a list of events
Widget _eventListView(Map<DateTime, List<Event>> eventMap) {
  return ListView.builder(
    itemCount: eventMap.values.length,
    itemBuilder: (context, index) {
      List<Event> eventList = eventMap.values.elementAt(index);
      return ListTile(
        title: Text(eventList[index].title),
        subtitle: Text('${eventList[index].date}'),
        trailing: Text(eventList[index].description),
      );
    }
  );
}

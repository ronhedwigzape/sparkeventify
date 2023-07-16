import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendarScreen extends StatefulWidget {
  const EventsCalendarScreen({Key? key}) : super(key: key);

  @override
  EventsCalendarScreenState createState() => EventsCalendarScreenState();
}

class EventsCalendarScreenState extends State<EventsCalendarScreen> {
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
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Calendar of Events and Announcements',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: TableCalendar(
                    eventLoader: (day) {
                      // Use `eventLoader` to return a list of events for the given day.
                      DateTime adjustedDay = DateTime(day.year, day.month, day.day, 0, 0, 0).toLocal(); // Set the time by midnight
                      return _getEventsForDay(adjustedDay);
                    },
                    firstDay: DateTime.utc(2015, 01, 01),
                    lastDay: DateTime.utc(2030, 3, 14), // Can be adjusted on the future
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      // Use `selectedDayPredicate` to determine which day is currently selected.
                      DateTime adjustedDay = DateTime(day.year, day.month, day.day, 0, 0, 0).toLocal(); // Set the time by midnight
                      return isSameDay(_selectedDay, adjustedDay);
                    },
                    rowHeight: 35,
                    daysOfWeekHeight: 30.0,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      decoration: BoxDecoration(
                        color: blueColor,
                      ),
                      weekdayStyle: TextStyle(color: lightGreyColor),
                      weekendStyle: TextStyle(color: secondaryColor)),
                    onDaySelected: (selectedDay, focusedDay) {
                      // Use `selectedDay` to retrieve the selected day.
                      DateTime adjustedSelectedDay = DateTime(
                              selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0)
                              .toLocal(); // Set the time by midnight
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
                        DateTime adjustedDay = DateTime(dateTime.year,
                                dateTime.month, dateTime.day, 0, 0, 0).toLocal();
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
                              style: const TextStyle(color: whiteColor),
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          child: Text(dateTime.day.toString(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _selectedDay == null
                // Returns none if no day is selected
                ? const Center(
                    child: kIsWeb
                        ? Text(
                          'No Day Selected. Please select a day to view events!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                          )
                        : Text('No Day Selected. Please select a day to view events!'))
                // Returns if there is an event on the selected day
                : _events[_selectedDay!] != null && kIsWeb
                    ? Row(
                        children: [
                          Flexible(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Events for this day',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: ListView.builder(
                                    itemCount: _events[_selectedDay]?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final event =_events[_selectedDay]![index];
                                      final time = DateFormat('hh:mm a').format(event.time);
                                      final date = DateFormat('MMMM dd, yyyy').format(event.date);
                                      return event.type == 'Non-academic'
                                      ? Card(
                                          margin: const EdgeInsets.all(8.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: ListTile(
                                              leading: (event.image?.isEmpty ?? true)
                                              ? Image.network(
                                                  'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                                  width: 70.0,
                                                )
                                              : Image.network(
                                                  event.image!,
                                                  width: 70.0,
                                                ),
                                              title: Text(event.title),
                                              titleTextStyle:
                                                const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              subtitle: Text(
                                                'Date: $date'
                                                '\nDescription: ${event.description}'
                                                '\nVenue: ${event.venue}'
                                                '\nTime: $time'),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Announcements for this day',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: ListView.builder(
                                      itemCount: _events[_selectedDay]?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final event = _events[_selectedDay]![index];
                                        final time = DateFormat('hh:mm a').format(event.time);
                                        final date = DateFormat('MMMM dd, yyyy').format(event.date);
                                        return event.type == 'Academic'
                                        ? Card(
                                          margin: const EdgeInsets.all(8.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: ListTile(
                                              leading: (event.image?.isEmpty ?? true)
                                              ? Image.network(
                                                  'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                                  width: 70.0,
                                                )
                                              : Image.network(
                                                  event.image!,
                                                  width: 70.0,
                                              ),
                                              title: Text(event.title),
                                              titleTextStyle: const TextStyle(fontSize: 20.0,fontWeight:FontWeight.bold,),
                                              subtitle: Text(
                                                'Date: $date'
                                                '\nDescription: ${event.description}'
                                                '\nVenue: ${event.venue}'
                                                '\nTime: $time'),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                      }
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _events[_selectedDay!] != null && !kIsWeb
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 7.0),
                              child: Center(
                                child: Text(
                                  'Events/Announcements for this day',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: ListView.builder(
                                itemCount: _events[_selectedDay]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final event = _events[_selectedDay]![index];
                                  final time = DateFormat('hh:mm a').format(event.time);
                                  final date = DateFormat('MMMM dd, yyyy').format(event.date);
                                  return Card(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: ListTile(
                                        leading: (event.image?.isEmpty ?? true)
                                        ? Image.network(
                                            'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                            width: 70.0,
                                          )
                                        : Image.network(
                                            event.image!,
                                            width: 70.0,
                                          ),
                                        title: Text(event.title),
                                        titleTextStyle: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        subtitle: Text(
                                          'Date: $date'
                                          '\nDescription: ${event.description}'
                                          '\nVenue: ${event.venue}'
                                          '\nTime: $time'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ) // Returns if there is no event on the selected day
                    : const Center(
                    child: kIsWeb
                    ? Text(
                      'No Events/Announcements For This Day. Please update later for future events!',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                      )
                    : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text('No Events/Announcements For This Day. Please update later for future events!'),
                      )
                    ),
              ),
            ],
          );
        }
      },
    );
  }
}

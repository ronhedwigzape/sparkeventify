import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/screens/report_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/event_dialog.dart';

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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return FutureBuilder<Map<DateTime, List<Event>>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong!"));
        } else {
          _events = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: kIsWeb ? Theme.of(context).cardColor : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(kIsWeb ? 20.0 : 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      kIsWeb ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            child: const Text('Generate Report'),
                            onPressed: () async {
                              List<Event> currentMonthEvents = [];
                              _events.forEach((eventDate, eventList) {
                                if (eventDate.month == _focusedDay.month) {
                                  currentMonthEvents.addAll(eventList);
                                }
                              });
                              // If a.date is earlier than b.date, it will return a negative number, and a will be placed before b in the sorted list
                              currentMonthEvents.sort((a, b) => a.date.compareTo(b.date));
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReportScreen(events: currentMonthEvents)),
                              );
                            },
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text('Calendar of Events',
                            style:
                                TextStyle(fontSize: kIsWeb ? 32.0 : 24.0, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: darkModeOn ? darkColor : lightColor)),
                          child: TableCalendar(
                            eventLoader: (day) {
                              // Use `eventLoader` to return a list of events for the given day.
                              DateTime adjustedDay =
                                  DateTime(day.year, day.month, day.day, 0, 0, 0)
                                      .toLocal(); // Set the time by midnight
                              return _getEventsForDay(adjustedDay);
                            },
                            firstDay: DateTime.utc(2015, 01, 01),
                            lastDay: DateTime.utc(2030, 3, 14),
                            // Can be adjusted on the future
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) {
                              // Use `selectedDayPredicate` to determine which day is currently selected.
                              DateTime adjustedDay =
                                  DateTime(day.year, day.month, day.day, 0, 0, 0)
                                      .toLocal(); // Set the time by midnight
                              return isSameDay(_selectedDay, adjustedDay);
                            },
                            rowHeight: 60,
                            daysOfWeekHeight: 50.0,
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              tableBorder: TableBorder(
                                verticalInside: BorderSide(
                                  color: darkModeOn ? darkColor : lightColor,
                                ),
                                horizontalInside: BorderSide(
                                  color: darkModeOn ? darkColor : lightColor,
                                ),
                              )
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                                decoration: BoxDecoration(
                                  color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                ),
                                weekdayStyle: const TextStyle(color: lightColor),
                                weekendStyle: TextStyle(color: darkModeOn ? darkBlueColor : lightModeIndigo)),
                            onDaySelected: (selectedDay, focusedDay) {
                              // Use `selectedDay` to retrieve the selected day.
                              DateTime adjustedSelectedDay = DateTime(selectedDay.year,
                                      selectedDay.month, selectedDay.day, 0, 0, 0)
                                  .toLocal(); // Set the time by midnight
                              setState(() {
                                _selectedDay = adjustedSelectedDay;
                                _focusedDay = focusedDay;
                                _calendarFormat = CalendarFormat.month;
                              });

                              // Check if there are any events for the selected day
                              List<Event> selectedDayEvents =
                                  _getEventsForDay(adjustedSelectedDay);

                              // If there are events, show the dialog
                              if (selectedDayEvents.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => EventDialog(selectedDayEvents, adjustedSelectedDay),
                                );
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
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, dateTime, focusedDay) {
                                DateTime adjustedDay = DateTime(dateTime.year,
                                        dateTime.month, dateTime.day, 0, 0, 0)
                                    .toLocal();
                                if (_events.containsKey(adjustedDay)) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: lightModeIndigo,
                                      shape: BoxShape.circle,
                                    ),
                                    margin: const EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      dateTime.day.toString(),
                                      style: TextStyle(color: darkModeOn ? darkColor : lightColor),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

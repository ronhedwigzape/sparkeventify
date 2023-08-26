import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/screens/report_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_dialog.dart';

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
  late Future<Map<DateTime, List<Event>>> events;
  String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    events = fireStoreEventMethods.getEventsByDate();
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
      future: events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
        } else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong!"));
        } else {
          _events = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: darkModeOn ? darkColor : lightColor,
                child: Padding(
                  padding: const EdgeInsets.all(kIsWeb ? 20.0 : 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      kIsWeb ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              List<Event> currentMonthEvents = [];
                              _events.forEach((eventDate, eventList) {
                                if (eventDate.month == _focusedDay.month) {
                                  currentMonthEvents.addAll(eventList);
                                }
                              });
                              // If a.date is earlier than b.date, it will return a negative number, and a will be placed before b in the sorted list
                              currentMonthEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReportScreen(events: currentMonthEvents, currentMonth: currentMonth,)),
                              );
                            },
                            child: Text('Generate Report for $currentMonth',
                              style: const TextStyle(color: lightModeIndigo),),
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event,
                                color: darkModeOn ? lightColor : darkColor,
                                size: 30,),
                              const SizedBox(width: 10),
                              Text('Calendar of Events',
                                  style:
                                  TextStyle(fontSize: kIsWeb ? 28.0 : 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: darkModeOn ? lightColor : darkColor,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                      padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor)),
                          child: TableCalendar(
                            eventLoader: (day) {
                              // Use `eventLoader` to return a list of events for the given day.
                              DateTime adjustedDay =
                              DateTime(day.year, day.month, day.day, 0, 0, 0)
                                  .toLocal(); // Set the time by midnight
                              return _events[adjustedDay] ?? [];
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
                              setState(() {
                                currentMonth = DateFormat('MMMM yyyy').format(focusedDay);
                              });
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

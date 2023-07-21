import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/user.dart' as model;

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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Calendar of Events',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: darkModeOn ? lightColor : darkColor)),
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
                    rowHeight: 50,
                    daysOfWeekHeight: 40.0,
                    daysOfWeekStyle: DaysOfWeekStyle(
                        decoration: BoxDecoration(
                          color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                        ),
                        weekdayStyle: const TextStyle(color: lightModeGreyColor),
                        weekendStyle: const TextStyle(color: darkBlueColor)),
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
                          builder: (context) {
                            return AlertDialog(
                              title: Center(
                                child: Text('Events for ${DateFormat('MMMM dd, yyyy').format(adjustedSelectedDay)}'),
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: selectedDayEvents.length,
                                  itemBuilder: (context, index) {
                                    var event = selectedDayEvents[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  event.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24.0
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                DateFormat.jm().format(event.time),  // assuming time is a string
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          StreamBuilder<model.User>(
                                            stream: FireStoreUserMethods().getUserDetailsByEventsCreatedBy(event.createdBy),  // assuming that this returns a Future<String>
                                            builder: (BuildContext context, AsyncSnapshot<model.User> snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Text('Fetching Data...');
                                              } else {
                                                if (snapshot.hasError) {
                                                  return Text('Error: ${snapshot.error}');
                                                } else {
                                                  return Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Created by ${snapshot.data?.profile?.fullName}',
                                                            style: const TextStyle(
                                                              color: lightModeSecondaryColor
                                                            ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      SizedBox(
                                                        width: 120,
                                                        child: Chip(
                                                          label: Padding(
                                                            padding: const EdgeInsets.all(1.0),
                                                            child: Text(
                                                              event.type,
                                                              style: const TextStyle(color: Colors.white, fontSize: 12),  // I reduced the fontSize here to make the chip smaller.
                                                            ),
                                                          ),
                                                          backgroundColor: event.type == 'Academic' ? (darkModeOn ? darkModeMaroonColor : lightModeMaroonColor) : (darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );  // Text widget
                                                }
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10.0),
                                          (event.image?.isEmpty ?? true)
                                              ? Image.network(
                                            'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                            width: double.infinity,
                                          )
                                              : Image.network(
                                            event.image!,
                                            width: double.infinity,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Column(
                                            children: [
                                              event.document == null || event.document == '' ?
                                              const SizedBox.shrink() :
                                              TextButton.icon(
                                                  onPressed: () => downloadAndOpenFile(event.document ?? '', event.title),
                                                  icon: const Icon(Icons.download_for_offline),
                                                  label: Text('Download and Open ${event.title} document')
                                              ),
                                              Text(
                                                  event.description,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 15.0,)
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
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
                              style: const TextStyle(color: lightColor),
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
          );
        }
      },
    );
  }
}

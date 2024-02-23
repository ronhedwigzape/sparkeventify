import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/report_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_background.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';
import 'package:student_event_calendar/widgets/ongoing_events.dart';
import 'package:student_event_calendar/widgets/upcoming_events.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_dialog.dart';
import 'package:timezone/timezone.dart' as tz;

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
  Stream<Map<DateTime, List<Event>>>? events; 
  String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  String? department;
  String? program;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int maxEventsPerDay = 1;

  @override
  void initState() {
    super.initState();
    final fireStoreUserMethods = FireStoreUserMethods();
    fireStoreUserMethods.getCurrentUserDataStream().listen((user) {
      setState(() {
        department = user?.profile!.department;
        program = user?.profile!.program;
      });
      events = user?.userType == 'Admin' || 
               user?.userType == 'SuperAdmin' || 
               user?.userType == 'Staff' 
      ? fireStoreEventMethods.getEventsByDate() 
      : fireStoreEventMethods.getEventsByDateByDepartmentByProgram(department!, program!);
    });
  }

  // Function to get the events for the day
  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Function to get current time
  Stream<DateTime> getCurrentTime() {
    return Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (int _) => DateTime.now(),
    );
  }

  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.month == date2.month && date1.year == date2.year;
  }

  // Function to refresh data from Firestore
  void _onRefresh() async {
    try {
      // Simulating network fetch. If this is just for UI delay, consider removing it.
      await Future.delayed(const Duration(milliseconds: 1000));

      final fireStoreUserMethods = FireStoreUserMethods();
      final user = await fireStoreUserMethods.getCurrentUserDataStream().first;

      setState(() {
        events = user?.userType == 'Admin' || user?.userType == 'SuperAdmin' || user?.userType == 'Staff' 
          ? fireStoreEventMethods.getEventsByDate() 
          : fireStoreEventMethods.getEventsByDateByDepartmentByProgram(department!, program!);
      });
    } catch (error) {
      // Handle the error appropriately
      print('Error fetching data: $error');
      // If you want to indicate a failure in refresh, uncomment the next line
      // _refreshController.refreshFailed();
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Stack(
      children: [
        // School background image 
        !kIsWeb ? Positioned.fill(
          child: CSPCBackground(height: MediaQuery.of(context).size.height),
        ) : const SizedBox.shrink(),
        // Gradient background effects
        !kIsWeb ? Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                darkModeOn ? darkColor.withOpacity(0.0) : lightColor.withOpacity(0.0),
                darkModeOn ? darkColor : lightColor,
              ],
              stops: const [
                0.0,
                1.0
              ]
            ),
          ),
        ) : const SizedBox.shrink(),
        GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: events != null 
          ? StreamBuilder<Map<DateTime, List<Event>>>(
            stream: events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CSPCSpinKitFadingCircle(isLogoVisible: false,));
              } else if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong!"));
              } else {
                _events = snapshot.data!;
                return Stack(
                  children: [
                    SmartRefresher(
                      enablePullDown: true,
                      header: const WaterDropHeader(),
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(kIsWeb ? 20.0 : 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                kIsWeb ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          List<Event> allEvents = [];
                                          _events.forEach((eventDate, eventList) {
                                            allEvents.addAll(eventList); // Add all events without filtering by month
                                          });
                                          // Sort events by start date if needed
                                          allEvents.sort((a, b) => a.startDate!.compareTo(b.startDate!));

                                          // Navigate to ReportScreen with all events
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ReportScreen(events: allEvents)),
                                          );
                                        },
                                        icon: const Icon(Icons.report, color: lightColor, size: 16,),
                                        label: Text('Generate Report Summary for $currentMonth'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor, 
                                          foregroundColor: lightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ) : StreamBuilder<model.User?>(
                                  stream: FireStoreUserMethods().getCurrentUserDataStream(),
                                  builder: (context, snapshot) {
                                    // Check for connection state and errors first
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const SizedBox.shrink();  
                                    }
                                    if (!snapshot.hasData || snapshot.hasError) {
                                      return const Text('Hi! User!');  // Error or no data handling
                                    }

                                    final model.User user = snapshot.data!;
                                    final firstName = user.profile?.firstName ?? 'User';  // Fallback to 'User' if null

                                    // Determine the appropriate greeting based on the hour of the day
                                    final hour = DateTime.now().hour;
                                    String greeting;
                                    if (hour >= 0 && hour < 12) { // 12 AM to 11:59 AM
                                      greeting = 'Good Morning 🌄';
                                    } else if (hour >= 12 && hour < 18) { // 12 PM to 5:59 PM
                                      greeting = 'Good Afternoon 🕛';
                                    } else if (hour >= 18 && hour < 22) { // 6 PM to 9:59 PM
                                      greeting = 'Good Evening 🌆';
                                    } else { // 10 PM to 11:59 PM
                                      greeting = 'Good Night 🌃';
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '$greeting, $firstName!', 
                                              style: const TextStyle(
                                                color: lightColor,
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.w900
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Center(
                                    child: 
                                    kIsWeb ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Flexible(
                                          child: Row(
                                            children: [
                                              Icon(Icons.event,
                                              color: lightColor,
                                              size: 30,),
                                              SizedBox(width: 10),
                                              Text('Calendar of Events',
                                                style:
                                                TextStyle(fontSize: kIsWeb ? 28.0 : 24.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: lightColor,
                                                )
                                              ),
                                            ],
                                          ) 
                                        ),
                                        Flexible(
                                          child: StreamBuilder<DateTime>(
                                            stream: getCurrentTime(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.active) {
                                                final now = snapshot.data!;
                                                final manila = tz.getLocation('Asia/Manila');
                                                final localTime = tz.TZDateTime.from(now, manila);
                                                final formattedDateNow = '${DateFormat('MMMM dd, yyyy').format(now)} ${DateFormat.jm().format(localTime)}';
                                                return RichText(
                                                  text: TextSpan(
                                                    text: 'Date & Time: ',
                                                    style: const TextStyle(color: lightColor),
                                                    children: <TextSpan>[
                                                      TextSpan(text: formattedDateNow, style: const TextStyle(fontWeight: FontWeight.bold, color: lightColor)),
                                                    ],
                                                  )
                                                );
                                              } else {
                                                return SizedBox(
                                                  width: 250, 
                                                  child: LinearProgressIndicator(
                                                    color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                                  ));
                                              }
                                            },
                                          )
                                        )
                                      ],
                                    ) : const SizedBox.shrink(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(!kIsWeb ? 6 : 10.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        !kIsWeb ? 0 : 20, 
                                        !kIsWeb ? 3 : 10, 
                                        0, 
                                        !kIsWeb ? 3 : 8),
                                      child: Row(
                                        children: [
                                          kIsWeb ? Text(
                                            'Legend:',
                                            style: TextStyle(
                                              color: darkModeOn ? lightColor : darkColor,),
                                          ) : const SizedBox.shrink(),
                                          const SizedBox(width: !kIsWeb ? 10 : 20,),
                                          ...eventColors.entries.map((entry) {
                                          return Flexible(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: !kIsWeb ? 8 : 10,
                                                  width: !kIsWeb ? 8 : 10,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: darkModeOn ? lightColor : darkColor,
                                                      ),
                                                    shape: BoxShape.circle,
                                                    color: entry.value,
                                                  ),
                                                ),
                                                const SizedBox(width: !kIsWeb ? 1.5 : 5),
                                                Flexible(
                                                  child: Text(
                                                    entry.key, 
                                                    style: TextStyle(
                                                      color: darkModeOn ? lightColor : darkColor,
                                                      fontSize: !kIsWeb ? 8 : null
                                                      ),),
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        ]
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: darkModeOn ? darkColor : lightColor,
                                        border: Border.all(
                                          color: darkModeOn ? lightColor : darkColor),
                                          borderRadius: BorderRadius.circular(10.0), ),
                                    child: TableCalendar(
                                      headerStyle: HeaderStyle(
                                        titleTextStyle: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                        formatButtonTextStyle: TextStyle(color: darkModeOn ? lightColor : darkColor), 
                                        formatButtonDecoration: BoxDecoration(
                                          border: Border.all(color: darkModeOn ? lightColor : darkColor), 
                                          borderRadius: BorderRadius.circular(5.0), 
                                        ),
                                      ),
                                      eventLoader: (day) {
                                        // Use `eventLoader` to return a list of events for the given day.
                                        DateTime adjustedDay =
                                        DateTime(day.year, day.month, day.day, 0, 0, 0)
                                            .toLocal(); // Set the time by midnight
                                        return _events[adjustedDay] ?? [];
                                      },
                                      firstDay: DateTime.utc(2015, 01, 01), // can adjust the first day on the past
                                      lastDay: DateTime.utc(2030, 3, 14),  // can adjust the last day on the future
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
                                      rowHeight: kIsWeb ? 90 : 60,
                                      daysOfWeekHeight: kIsWeb ? 60 : 50,
                                      calendarStyle: CalendarStyle(
                                        markersMaxCount: 10,
                                        todayDecoration: BoxDecoration(
                                          color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        todayTextStyle: const TextStyle(
                                          fontSize: 14, 
                                          color: white,
                                        ),
                                        tableBorder: TableBorder(
                                          verticalInside: BorderSide(
                                            color: darkModeOn ? lightColor : darkColor,
                                          ),
                                          horizontalInside: BorderSide(
                                            color: darkModeOn ? lightColor : darkColor,
                                          ),
                                        ),
                                        outsideTextStyle: TextStyle(color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor),
                                      ),
                                      daysOfWeekStyle: DaysOfWeekStyle(
                                          decoration: BoxDecoration(
                                            color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                          ),
                                          weekdayStyle: const TextStyle(color: lightColor),
                                          weekendStyle: const TextStyle(color: light)),
                            
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

                                      calendarBuilders: kIsWeb ? CalendarBuilders(
                                        defaultBuilder: (context, dateTime, focusedDay) {
                                          DateTime adjustedDay = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0).toLocal();
                                          bool hasEvents = _events.containsKey(adjustedDay);

                                          if (_events.containsKey(adjustedDay)) {
                                            return Container(
                                              decoration: const BoxDecoration(
                                                color: lightModeIndigo,
                                                shape: BoxShape.circle,
                                              ),
                                              margin: const EdgeInsets.all(20.0),
                                              alignment: Alignment.center,
                                              child: Text(
                                                dateTime.day.toString(),
                                                style: TextStyle(
                                                  color: darkModeOn ? (hasEvents ? darkColor : lightColor) : (hasEvents ? lightColor : darkColor), 
                                                  fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          }

                                          return Stack(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(4.0),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  dateTime.day.toString(),
                                                  style: TextStyle(
                                                    color: darkModeOn ? (hasEvents ? darkColor : lightColor) : (hasEvents ? lightColor : darkColor),
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        todayBuilder: (context, date, _) {
                                          return Container(
                                            margin: const EdgeInsets.all(20.0),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(
                                                color: darkModeOn ? darkColor : lightColor,
                                                fontWeight: FontWeight.w900
                                              ),
                                            ),
                                          );
                                        },
                                        markerBuilder: (context, date, events) {
                                          return Positioned(
                                            bottom: 1,
                                            child: Row(
                                              children: events.expand<Widget>((event) {
                                                // Ensure the participants and department are not null
                                                var departments = (event as Event).participants?['department'] as List<dynamic>?;
                                                if (departments == null) return [];
                                                return departments.map<Widget>((dept) {
                                                  return Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                                      child: Chip(
                                                        label: Text(
                                                          dept,
                                                          style: const TextStyle(
                                                            fontSize: 8,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        backgroundColor: eventColors[event.status],
                                                        padding: const EdgeInsets.all(0),
                                                        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                                      ),
                                                    );
                                                }).toList();
                                              }).toList(),
                                            ),
                                          );
                                        }

                                      ) : CalendarBuilders(
                                        defaultBuilder: (context, dateTime, focusedDay) {
                                          DateTime adjustedDay = DateTime(dateTime.year,
                                                  dateTime.month, dateTime.day, 0, 0, 0)
                                              .toLocal();

                                          bool hasEvents = _events.containsKey(adjustedDay);

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
                                                style: TextStyle(
                                                  color: darkModeOn ? (hasEvents ? darkColor : lightColor) : (hasEvents ? lightColor : darkColor), 
                                                  fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          }
                                          return Container(
                                            margin: const EdgeInsets.all(4.0),
                                            alignment: Alignment.center,
                                            child: Text(
                                              dateTime.day.toString(),
                                              style: TextStyle(
                                                color: darkModeOn ? (hasEvents ? darkColor : lightColor) : (hasEvents ? lightColor : darkColor),
                                                fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        },
                                       markerBuilder: (context, date, events) {
                                          if (events.isNotEmpty) {
                                            // Cast the events to a list of your Event type
                                            List<Event> typedEvents = events.cast<Event>();
                                            List<Widget> eventMarkers = typedEvents.map((event) {
                                              // Use the event's status color
                                              return Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 1.0),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: eventColors[event.status], // Use the event's status color
                                                ),
                                                width: 7.0, // Smaller dots for mobile
                                                height: 7.0, // Smaller dots for mobile
                                              );
                                            }).toList();

                                            return Positioned(
                                              bottom: 1,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: eventMarkers,
                                              ),
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                kIsWeb ? const SizedBox(height: 30) : const SizedBox.shrink(),     
                                kIsWeb ? UpcomingEvents(_events) : const SizedBox.shrink(),
                                kIsWeb ? OngoingEvents(_events) : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ) : const CSPCSpinKitFadingCircle(),
        ),
      ],
    );
  }
}

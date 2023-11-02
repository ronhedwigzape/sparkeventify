import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/report_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_background.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
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

  @override
  void initState() {
    super.initState();
    final fireStoreUserMethods = FireStoreUserMethods();
    fireStoreUserMethods.getCurrentUserDataStream().listen((user) {
      setState(() {
        department = user?.profile!.department;
      });
      events = kIsWeb ? fireStoreEventMethods.getEventsByDate() : fireStoreEventMethods.getEventsByDateByDepartment(department!);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Stream<DateTime> getCurrentTime() {
    return Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (int _) => DateTime.now(),
    );
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    setState(() {
      events = kIsWeb ? fireStoreEventMethods.getEventsByDate() : fireStoreEventMethods.getEventsByDateByDepartment(department!);
    });
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
        !kIsWeb ? Positioned.fill(
          child: CSPCBackground(height: MediaQuery.of(context).size.height),
        ) : const SizedBox.shrink(),
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
          child: events != null ? StreamBuilder<Map<DateTime, List<Event>>>(
            stream: events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CSPCFadeLoader());
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
                                        icon: const Icon(Icons.report, color: lightColor, size: 16,),
                                        label: Text('Generate Report Summary for $currentMonth'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor, 
                                          foregroundColor: lightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ) : const SizedBox.shrink(),
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
                                padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: darkModeOn ? darkColor : lightColor,
                                        border: Border.all(
                                            color: darkModeOn ? lightColor : darkColor)),
                                    child: TableCalendar(
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
                                      rowHeight: 60,
                                      daysOfWeekHeight: 50.0,
                                      calendarStyle: CalendarStyle(
                                        markersMaxCount: 10,
                                        todayDecoration: BoxDecoration(
                                          color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                          shape: BoxShape.circle,
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
                                                style: TextStyle(color: darkModeOn ? darkColor : lightColor, fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          }
                                          return Container(
                                            margin: const EdgeInsets.all(4.0),
                                            alignment: Alignment.center,
                                            child: Text(
                                              dateTime.day.toString(),
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          );
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

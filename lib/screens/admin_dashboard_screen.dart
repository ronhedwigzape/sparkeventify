import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';

import '../providers/darkmode_provider.dart';
import '../widgets/events_calendar.dart';
import '../widgets/past_events.dart';
import '../widgets/upcoming_events.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<DateTime, List<Event>>> events;

  @override
  void initState() {
    super.initState();
    events = FireStoreEventMethods().getEventsByDate();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return FutureBuilder<Map<DateTime, List<Event>>>(
        future: events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          } else {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final maxWidth = min(1000, constraints.maxWidth).toDouble();
                return Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dashboard_outlined,
                            color: darkModeOn ? lightColor : darkColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  color: darkModeOn ? lightColor : darkColor
                              )
                          ),
                        ],
                      ),
                    ),
                    toolbarHeight: 60,
                  ),
                  body: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: EventsCalendar(),
                          ),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  UpcomingEvents(snapshot.data!),
                                  PastEvents(snapshot.data!),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        });
  }

}

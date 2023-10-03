import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import '../providers/darkmode_provider.dart';
import '../widgets/events_calendar.dart';

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
        return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
      } else if (snapshot.hasError) {
        return const Center(child: Text("Something went wrong!"));
      } else {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = min(900, constraints.maxWidth).toDouble();
            return Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView( 
                    child: Column(
                      children: [
                         SizedBox(
                          height: constraints.maxHeight * 1,
                          child: const EventsCalendar(),
                        ),
                      ],
                    ),
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

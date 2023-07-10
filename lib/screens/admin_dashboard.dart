import 'package:flutter/material.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EventsCalendar(),
    );
  }
}
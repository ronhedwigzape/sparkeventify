import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';

import '../widgets/events_calendar.dart';
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
    return FutureBuilder<Map<DateTime, List<Event>>>(
      future: events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong!"));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Dashboard'),
            ),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 2,
                  child: EventsCalendar(),
                ),
                Expanded(
                  flex: 1,
                  child: UpcomingEvents(snapshot.data!),
                ),
              ],
            ),
          );
        }
      });
  }
}

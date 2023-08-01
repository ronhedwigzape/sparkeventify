import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/event.dart' as model;

class ReportScreen extends StatelessWidget {
  final List<model.Event> events;
  const ReportScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(events[index].title),
                  subtitle: Text(events[index].description),
              );
            }
        )
    );
  }
}
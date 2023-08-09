import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class ReportScreen extends StatelessWidget {
  final List<model.Event> events;
  const ReportScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final uniqueEvents = events.toSet().toList();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
      final maxWidth = min(1250, constraints.maxWidth).toDouble();
        return Scaffold(
            backgroundColor: darkModeOn ? white : white,
            appBar: AppBar(),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView.builder(
                  itemCount: uniqueEvents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(uniqueEvents[index].title),
                        subtitle: Text(uniqueEvents[index].description),
                    );
                  }
                ),
              ),
            )
        );
      }
    );
  }
}

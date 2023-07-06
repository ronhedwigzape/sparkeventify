import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/client_selection_screen.dart';

class Client extends StatelessWidget {
  const Client({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School App',
      theme: ThemeData(
          // Theme configuration for the mobile platform
          ),
      home: const ClientSelectionScreen(),
    );
  }
}

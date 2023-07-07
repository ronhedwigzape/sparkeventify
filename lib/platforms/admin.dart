import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/admin_login_screen.dart';

class Admin extends StatelessWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Admin',
      theme: ThemeData(
          // Theme configuration for the web platform
          ),
      home: const AdminLoginScreen(),
    );
  }
}

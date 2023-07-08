// Global variables for the app

import 'package:flutter/material.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';

const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';

Future<String> currentUser = AuthMethods().getCurrentUserType();

List<Widget> homeScreenItems = [
  // Test for current user
  FutureBuilder<String>(
    future: currentUser,
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        return Center(child: Text(
          'Home ${snapshot.data}',
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    },
  ),
  const Center(child: Text('Calendar')),
  const Center(child: Text('Announcement')),
  const Center(child: Text('Personal'),),
  const Center(child: Text('Profile'))
];

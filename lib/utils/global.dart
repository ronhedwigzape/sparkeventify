// Global variables for the app

import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/home_screen.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';

const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';

List<Widget> homeScreenItems = [
  // Test for current user
  const HomeScreen(),
  const EventsCalendar(),
  const Center(child: Text('Announcement')),
  const Center(child: Text('Personal'),),
  const Center(child: Text('Profile'))
];

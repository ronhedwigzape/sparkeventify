import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';

// Constant variables for the app
const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';
const schoolLogo = 'assets/images/cspc_logo.png';
const appName = 'Announce';

// Global key for the events calendar

List<Widget> homeScreenItems = [
  kIsWeb ?  const EventsCalendar() : const Center(child: Text('Home Screen')),
  kIsWeb ? const PostScreen() : const EventsCalendar(),
  kIsWeb
      ? const Center(child: Text('Manage Events'))
      : const Center(child: Text('Announcements')),
  kIsWeb
      ? const Center(child: Text('Manage Users'))
      : const Center(child: Text('Personal Events')),
  kIsWeb
      ? const Center(child: Text('Settings'))
      : const ProfileScreen(),
];
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/feed_screen.dart';
import 'package:student_event_calendar/screens/manage_users_screen.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/screens/events_calendar_screen.dart';
import 'package:student_event_calendar/screens/settings_screen.dart';

// Constant variables for the app
const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';
const schoolLogo = 'assets/images/cspc_logo.png';
const appName = 'Announce';

// Global key for the events calendar
List<Widget> homeScreenItems = [
  kIsWeb
      ? const EventsCalendarScreen()
      : const FeedScreen(),
  kIsWeb ? const PostScreen() : const EventsCalendarScreen(),
  kIsWeb
      ? const FeedScreen()
      : const Center(child: Text('Feedbacks')),
  kIsWeb
      ? const ManageUsersScreen()
      : const Center(child: Text('Personal Events')),
  kIsWeb ? const SettingsScreen() : const ProfileScreen(),
  const Center(child: Text('Notifications'))
];

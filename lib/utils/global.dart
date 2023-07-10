// Global variables for the app

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/add_event_screen.dart';
import 'package:student_event_calendar/screens/admin_dashboard.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';

const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';
const clientAppName = 'Events';
const adminAppName = 'CSPC Events Calendar Administrator';
List<Widget> homeScreenItems = [
  // Test for current user
  kIsWeb ? const AdminDashboard() : const Center(child: Text('Home Screen')),
  kIsWeb ? const AddEventScreen() : const EventsCalendar(),
  kIsWeb
      ? const Center(child: Text('Manage Events'))
      : const Center(child: Text('Announcements')),
  kIsWeb
      ? const Center(
          child: Text('Manage Users'),
        )
      : const Center(child: Text('Personal Events')),
  kIsWeb
      ? const Center(child: Text('Settings'))
      : const Center(
          child: Text('Profile'),
        )
];

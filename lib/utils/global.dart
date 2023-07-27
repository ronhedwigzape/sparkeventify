import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/admin_dashboard_screen.dart';
import 'package:student_event_calendar/screens/events_feed_screen.dart';
import 'package:student_event_calendar/screens/manage_users_screen.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/screens/events_calendar_screen.dart';
import 'package:student_event_calendar/screens/settings_screen.dart';
import '../resources/auth_methods.dart';
import '../resources/firestore_user_methods.dart';
import 'package:student_event_calendar/models/user.dart' as model;

// Constant variables for the app
const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';
const schoolLogo = 'assets/images/cspc_logo.png';
const appName = 'Announce';

// Global key for the events calendar
Future<List<Widget>> homeScreenItems() async {
  final String userType = await AuthMethods().getCurrentUserType();

  if (userType == 'Staff') {
    // Widgets for 'Staff'
    return [
      const EventsCalendarScreen(),
      const Center(child: Text('Feedbacks')),
      const PostScreen(),
      const EventsFeedScreen(),
      const ProfileScreen(),
      const Center(child: Text('Notifications')),
    ];
  } else if (userType == 'Admin' && kIsWeb) {
    // Widgets for 'Admin' only when app is running on Web platform
    return [
      const AdminDashboardScreen(),
      const PostScreen(),
      const EventsFeedScreen(),
      const ManageUsersScreen(),
      const SettingsScreen(),
    ];
  }
  // Widgets for Students and Officers
  return [
    const EventsCalendarScreen(),
    const Center(child: Text('Feedbacks')),
    const Center(child: Text('Personal Events')),
    const ProfileScreen(),
    const Center(child: Text('Notifications'),),
  ];
}
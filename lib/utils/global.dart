import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/events_feed_screen.dart';
import 'package:student_event_calendar/screens/manage_users_screen.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/screens/events_calendar_screen.dart';
import 'package:student_event_calendar/screens/settings_screen.dart';
import '../resources/firestore_user_methods.dart';
import 'package:student_event_calendar/models/user.dart' as model;

// Constant variables for the app
const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';
const schoolLogo = 'assets/images/cspc_logo.png';
const appName = 'Announce';

// Global key for the events calendar
List<Widget> homeScreenItems = [
  kIsWeb
      ? const Center(child: Text('Admin Dashboard'))
      : const EventsCalendarScreen(),
  kIsWeb ? const PostScreen() : const Center(child: Text('Feedbacks')),
  kIsWeb
      ? const EventsFeedScreen()
      : FutureBuilder(
      future: FireStoreUserMethods().getCurrentUserData(),
      builder: (context, AsyncSnapshot<model.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (snapshot.data?.userType == 'Staff') {
            return const PostScreen();
          } else {
            return const Center(child: Text('Personal Events'));
          }
        }
      }
  ),
  kIsWeb
      ? const ManageUsersScreen()
      :  const ProfileScreen(),
  kIsWeb ? const SettingsScreen() : const Center(child: Text('Notifications'))
];

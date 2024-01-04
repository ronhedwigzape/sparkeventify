import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/admin_dashboard_screen.dart';
import 'package:student_event_calendar/screens/feedback_screen.dart';
import 'package:student_event_calendar/screens/manage_program_department_screen.dart';
import 'package:student_event_calendar/screens/manage_events_screen.dart';
import 'package:student_event_calendar/screens/manage_staff_positions.dart';
import 'package:student_event_calendar/screens/manage_users_screen.dart';
import 'package:student_event_calendar/screens/notification_screen.dart';
import 'package:student_event_calendar/screens/personal_events_screen.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/screens/pending_events_screen.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';
import '../resources/auth_methods.dart';

final firestoreInstance = FirebaseFirestore.instance;

int? webScreenSize; 
String? schoolName; 
String? schoolAddress; 
String? schoolLogoWhite; 
String? schoolLogoBlack;
String? schoolLogo;
String? schoolBackground;
String? appName;
List<String>? programsAndDepartments; 
List<String>? programParticipants; 
List<String>? departmentParticipants; 
List<String>? staffPositions;
Map<String, String>? programDepartmentMap; 

// Placeholder for selected participants
Map<String, List<String>> selectedParticipants = {
  'program': [],
  'department': []
};

Future<void> fetchAndSetConstants() async {
  DocumentSnapshot documentSnapshot = 
      await firestoreInstance.collection('global').doc('constants').get();

  appName = documentSnapshot.get('appName') as String;
  webScreenSize = documentSnapshot.get('webScreenSize') as int;
  schoolName = documentSnapshot.get('schoolName') as String;
  schoolAddress = documentSnapshot.get('schoolAddress') as String;
  schoolLogoWhite = documentSnapshot.get('schoolLogoWhite') as String;
  schoolLogoBlack = documentSnapshot.get('schoolLogoBlack') as String;
  schoolLogo = documentSnapshot.get('schoolLogo') as String;
  schoolBackground = documentSnapshot.get('schoolBackground') as String;
  programsAndDepartments = List<String>.from(documentSnapshot.get('programsAndDepartments'));
  programParticipants = List<String>.from(documentSnapshot.get('programParticipants'));
  departmentParticipants = List<String>.from(documentSnapshot.get('departmentParticipants'));
  programDepartmentMap = Map<String, String>.from(documentSnapshot.get('programDepartmentMap'));
  staffPositions = List<String>.from(documentSnapshot.get('staffPositions'));

  // Place a select option on programs and departments and staff positions
  programsAndDepartments!.insert(0, 'Select your program and department');
  staffPositions!.insert(0, 'Select your SASO position');
}

Stream<void> fetchAndSetConstantsStream() {
 return firestoreInstance.collection('global').doc('constants').snapshots().map((snapshot) {
    appName = snapshot.get('appName') as String;
    webScreenSize = snapshot.get('webScreenSize') as int;
    schoolName = snapshot.get('schoolName') as String;
    schoolAddress = snapshot.get('schoolAddress') as String;
    schoolLogoWhite = snapshot.get('schoolLogoWhite') as String;
    schoolLogoBlack = snapshot.get('schoolLogoBlack') as String;
    schoolLogo = snapshot.get('schoolLogo') as String;
    schoolBackground = snapshot.get('schoolBackground') as String;
    programsAndDepartments = List<String>.from(snapshot.get('programsAndDepartments'));
    programParticipants = List<String>.from(snapshot.get('programParticipants'));
    departmentParticipants = List<String>.from(snapshot.get('departmentParticipants'));
    programDepartmentMap = Map<String, String>.from(snapshot.get('programDepartmentMap'));
    staffPositions = List<String>.from(snapshot.get('staffPositions'));

    // Place a select option on programs and departments and staff positions
    programsAndDepartments!.insert(0, 'Select your program and department');
    staffPositions!.insert(0, 'Select your SASO position');
 });
}

// Global key for the events calendar
Future<List<Widget>> homeScreenItems() async {
  final String userType = await AuthMethods().getCurrentUserType();

  if (userType == 'Staff' && !kIsWeb) {
    // Widgets for 'Staff'
    return [
      const EventsCalendar(),
      const PostScreen(),
      const ManageEventsScreen(),
      const ProfileScreen(),
      PendingEventsScreen(),
      const NotificationScreen(),
    ];
  } else if (userType == 'Admin' && kIsWeb) {
    // Widgets for 'Admin' only when app is running on Web platform
    return [
      const AdminDashboardScreen(),
      const PostScreen(),
      const ManageEventsScreen(),
      const ManageUsersScreen(),
      const FeedbackScreen(),
      const ProfileScreen(),
      PendingEventsScreen(),
      const NotificationScreen()
    ];
  } else if (userType == 'SuperAdmin' && kIsWeb) {
    // Widgets for 'SuperAdmin' only when app is running on Web platform
    return [
      const AdminDashboardScreen(),
      const ManageProgramDepartmentScreen(),
      const ManageStaffPositionsScreen(),
      const ProfileScreen(),
      const NotificationScreen()
    ];
  } else if (userType == 'Officer' && !kIsWeb) {
    // Widgets for 'Officer'
    return [
      const EventsCalendar(),
      const FeedbackScreen(),
      const PostScreen(),
      const ManageEventsScreen(),
      const ProfileScreen(),
      const NotificationScreen(),
    ];
  } else if (userType == 'Student' && !kIsWeb) {
    // Widgets for Students
    return [
      const EventsCalendar(),
      const FeedbackScreen(),
      const PersonalEventsScreen(),
      const ProfileScreen(),
      const NotificationScreen(),
    ];
  } else {
    return [];
  }
}

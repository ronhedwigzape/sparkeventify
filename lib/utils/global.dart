import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/admin_dashboard_screen.dart';
import 'package:student_event_calendar/screens/create_admin_screen.dart';
import 'package:student_event_calendar/screens/feedback_screen.dart';
import 'package:student_event_calendar/screens/manage_org_screen.dart';
import 'package:student_event_calendar/screens/manage_program_department_screen.dart';
import 'package:student_event_calendar/screens/manage_events_screen.dart';
import 'package:student_event_calendar/screens/manage_staff_positions.dart';
import 'package:student_event_calendar/screens/manage_users_screen.dart';
import 'package:student_event_calendar/screens/notification_screen.dart';
import 'package:student_event_calendar/screens/personal_events_screen.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/screens/pending_events_screen.dart';
import 'package:student_event_calendar/screens/trashed_events_screen.dart';
import 'package:student_event_calendar/screens/trashed_users_screen.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';
import '../resources/auth_methods.dart';

final firestoreInstance = FirebaseFirestore.instance;

// Constant variables for the app
const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'SparkEventify';
const schoolLogoWhite = 'assets/icon/monochrome_cspc_launcher_icon_white.png';
const schoolLogoBlack = 'assets/icon/monochrome_cspc_launcher_icon_black.png';
const schoolLogo = 'assets/icon/app_icon.png';
const schoolBackground = 'assets/images/cspc_background.png';
const appName = 'SparkEventify';
List<String>? programsAndDepartments; 
List<String>? programParticipants; 
List<String>? departmentParticipants; 
List<String>? staffPositions;

// Placeholder for selected participants
Map<String, List<String>> selectedParticipants = {
  'program': [],
  'department': []
};

Future<void> fetchAndSetConstants() async {
  DocumentSnapshot documentSnapshot = 
      await firestoreInstance.collection('global').doc('constants').get();

  programsAndDepartments = List<String>.from(documentSnapshot.get('programsAndDepartments'));
  programParticipants = List<String>.from(documentSnapshot.get('programParticipants'));
  departmentParticipants = List<String>.from(documentSnapshot.get('departmentParticipants'));
  staffPositions = List<String>.from(documentSnapshot.get('staffPositions'));

  // Place a select option on programs and departments and staff positions
  // programsAndDepartments!.insert(0, 'Select your program and department');
  // staffPositions!.insert(0, 'Select your SASO position');
}

Stream<void> fetchAndSetConstantsStream() {
 return firestoreInstance.collection('global').doc('constants').snapshots().map((snapshot) {
    programsAndDepartments = List<String>.from(snapshot.get('programsAndDepartments'));
    programParticipants = List<String>.from(snapshot.get('programParticipants'));
    departmentParticipants = List<String>.from(snapshot.get('departmentParticipants'));
    programDepartmentMap = Map<String, String>.from(snapshot.get('programDepartmentMap'));
    staffPositions = List<String>.from(snapshot.get('staffPositions'));

    // Place a select option on programs and departments and staff positions
    // programsAndDepartments!.insert(0, 'Select your program and department');
    // staffPositions!.insert(0, 'Select your SASO position');
 });
}

// List all associated program for departments
Map<String, String> programDepartmentMap = {
  'BSCS': 'CCS',
  'BSIT': 'CCS',
  'BSIS': 'CCS',
  'BLIS': 'CCS',
  'BSN': 'CHS',
  'BSM': 'CHS',
  'BSME': 'CEA',
  'BSEE': 'CEA',
  'BSECE': 'CEA',
  'BSCoE': 'CEA',
  'BSCiE': 'CEA',
  'BSA': 'CEA',
  'BSOA': 'CTHBM',
  'BSHM': 'CTHBM',
  'BSTM': 'CTHBM',
  'BSE': 'CTHBM',
  'BSBA': 'CTHBM',
  'BAEL': 'CAS',
  'BSMa': 'CAS',
  'BSAM': 'CAS',
  'BSDC': 'CAS',
  'BPA': 'CAS',
  'BHS': 'CAS',
  'BTVTEFP': 'CTDE',
  'BTVTEFS': 'CTDE',
  'BTVTEET': 'CTDE',
  'BPE': 'CTDE',
  'BCAE': 'CTDE',
  'BSNE': 'CTDE'
};


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
      const ManageOrganizationScreen(),
      const ManageStaffPositionsScreen(),
      const CreateAdminScreen(),
      const TrashedEventsScreen(),
      const TrashedUsersScreen(),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/admin_dashboard_screen.dart';
import 'package:student_event_calendar/screens/feedback_screen.dart';
import 'package:student_event_calendar/screens/manage_events_screen.dart';
import 'package:student_event_calendar/screens/manage_users_screen.dart';
import 'package:student_event_calendar/screens/notification_screen.dart';
import 'package:student_event_calendar/screens/personal_events_screen.dart';
import 'package:student_event_calendar/screens/post_screen.dart';
import 'package:student_event_calendar/screens/profile_screen.dart';
import 'package:student_event_calendar/widgets/events_calendar.dart';
import '../resources/auth_methods.dart';

// Constant variables for the app
const webScreenSize = 600;
const schoolName = 'Camarines Sur Polytechnic Colleges';
const schoolAddress = 'Nabua, Camarines Sur';
const schoolLogoWhite = 'assets/icon/monochrome_cspc_launcher_icon_white.png';
const schoolLogoBlack = 'assets/icon/monochrome_cspc_launcher_icon_black.png';
const schoolLogo = 'assets/images/cspc_logo.png';
const schoolBackground = 'assets/images/cspc_background.png';
const appName = 'Announce';

// Global Programs and Departments
final List<String> programsAndDepartments = [
  'Select your program and department',
  'BSCS - CCS - Computer Science',
  'BSIT - CCS - Information Technology',
  'BSIS - CCS - Information Systems',
  'BLIS - CCS - Information Science',
  'BSN - CHS - Nursing',
  'BSM - CHS - Midwifery',
  'BSME - CEA - Mechanical Engineering',
  'BSEE - CEA - Electrical Engineering',
  'BSECE - CEA - Electronics Communication Engineering',
  'BSCoE - CEA - Computer Engineering',
  'BSCiE - CEA - Civil Engineering',
  'BSA - CEA - Architecture',
  'BSOA - CTHBM - Office Administration',
  'BSHM - CTHBM - Hospitality Management',
  'BSTM - CTHBM - Tourism Management',
  'BSE - CTHBM - Entreprenuership',
  'BSBA - CTHBM - Business Administration Major in Financial Management',
  'BAEL - CAS - English Language Studies',
  'BSMa - CAS - Mathematics',
  'BSAM - CAS - Applied Mathematics',
  'BSDC - CAS - Development Communication',
  'BPA - CAS - Public Administration',
  'BHS - CAS - Human Services',
  'BTVTEFP - CTDE - Major in Fish Processing',
  'BTVTEFS - CTDE - Major in Food Service Management',
  'BTVTEET - CTDE - Major in Electronics Technology',
  'BPE - CTDE - Physical Education',
  'BCAE - CTDE - Culture and Arts Education',
  'BSNE - CTDE - Special Needs Education'
];

// Programs
List<String> programParticipants = [
  'BSCS',
  'BSIT',
  'BSIS',
  'BLIS',
  'BSN',
  'BSM',
  'BSME',
  'BSEE',
  'BSECE',
  'BSCoE',
  'BSCiE',
  'BSA',
  'BSOA',
  'BSHM',
  'BSTM',
  'BSE',
  'BSBA',
  'BAEL',
  'BSMa',
  'BSAM',
  'BSDC',
  'BPA',
  'BHS',
  'BTVTEFP',
  'BTVTEFS',
  'BTVTEET',
  'BPE',
  'BCAE',
  'BSNE'
];

// Departments
List<String> departmentParticipants = [
  'CCS',
  'CHS',
  'CEA',
  'CTHBM',
  'CAS',
  'CTDE'
];

// Selected Participants
Map<String, List<String>> selectedParticipants = {
  'program': [],
  'department': []
};

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

final List<String> staffPositions = [
  'Select your position',
  'Director - Student Affairs and Services - SASO',
  'Administrative Aide VI - Head of Staff - SASO',
  'Administrative Aide III - Support Staff - Student Development',
  'Administrative Aide III - Support Staff - Scholarships(TES) & Financial Assist.',
  'Administrative Aide II - Support Staff - Scholarships(CSP/TDP) & Financial Assist.',
  'Administrative Aide II - Support Staff - Information Services',
];

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
    ];
  } else if (userType == 'SuperAdmin' && kIsWeb) {
    // Widgets for 'SuperAdmin' only when app is running on Web platform
    return [
      const AdminDashboardScreen(),
      const ProfileScreen(),
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

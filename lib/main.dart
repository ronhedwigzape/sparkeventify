import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/firebase_options.dart';
import 'package:student_event_calendar/providers/user_provider.dart';
import 'package:student_event_calendar/screens/admin_screen.dart';
import 'package:student_event_calendar/screens/client_selection_screen.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/screens/officer_screen.dart';
import 'package:student_event_calendar/screens/staff_screen.dart';
import 'package:student_event_calendar/screens/student_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => UserProvider())], 
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Event Calendar',
      home: AuthScreen(),
    ));
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static bool runningOnMobile() {
    return !kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasData) {
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final String userType = snapshot.data?.get('userType');
              if (userType == 'Admin' && kIsWeb) {
                return const AdminScreen();
              } else if (userType == 'Student' &&
                  runningOnMobile()) {
                return const StudentScreen();
              } else if (userType == 'Staff' &&
                  runningOnMobile()) {
                return const StaffScreen();
              } else if (userType == 'Officer' &&
                  runningOnMobile()) {
                return const OfficerScreen();
              } else {
                return const Center(
                  child: Text('Unknown user'),
                );
              }
            },
          );
        }
        if (runningOnMobile()) {
          return const ClientSelectionScreen();
        } else if (kIsWeb) {
          return const LoginScreen();
        } else {
          return const Center(
            child: Text('Unsupported Platform'),
          );
        }
      },
    );
  }
}

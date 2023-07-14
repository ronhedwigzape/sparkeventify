import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/firebase_options.dart';
import 'package:student_event_calendar/layouts/admin_screen_layout.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/providers/user_provider.dart';
import 'package:student_event_calendar/screens/client_selection_screen.dart';
import 'package:student_event_calendar/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    configureFirebaseMessaging();
    initializeFirebaseMessaging();
    getDeviceToken();
  }

  void initializeFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
  }

  void getDeviceToken() async {
    String? deviceToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Device Token: $deviceToken');
    }
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        // Handle the incoming message when the app is in the foreground
         if (kDebugMode) {
          if (message.notification != null) {
            print('Notification Title: ${message.notification!.title}');
            print('Notification Body: ${message.notification!.body}');
          }
          print('Data Payload(onMessage): ${message.data}');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('Done listening');
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        // Handle the incoming message when the app is launched from a terminated state
        if (kDebugMode) {
          if (message.notification != null) {
            print('Notification Title: ${message.notification!.title}');
            print('Notification Body: ${message.notification!.body}');
          }
          print('Data Payload(onMessageOpened): ${message.data}');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('Done listening');
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(
      (RemoteMessage message) async {
        if (kDebugMode) {
          print('onBackgroundMessage: $message');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Student Event Calendar',
          home: AuthScreen(),
        )
      );
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
              if (userType == 'Admin' && !runningOnMobile()) {
                return const AdminScreenLayout();
              } else if (runningOnMobile()) {
                return const ClientScreenLayout();
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

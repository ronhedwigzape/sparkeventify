import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_event_calendar/auth/login_screen.dart';
import 'package:student_event_calendar/firebase_options.dart';
import 'package:student_event_calendar/layouts/admin_screen_layout.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/providers/dialog_provider.dart';
import 'package:student_event_calendar/providers/user_provider.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/unknown_user.dart';
import 'package:timezone/data/latest.dart' as timezone;

void main() async {
  timezone.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
  // FirebaseNotificationService().manageTokenRegistrations();
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('dialogShown', false);
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  SnackBar? snackbar;
  bool isDialogMounted = false; // Track the mount status of the dialog
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    FirebaseNotificationService().init();
    FirebaseNotificationService().configure();
    FirebaseNotificationService().getDeviceToken();
    _connectivitySubscription = ConnectivityService().connectivityStream.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      // No internet connection
      if (!isDialogMounted) {
        // Only show the dialog if it is not already mounted
        showInternetConnectionDialog(
            'No internet connection. Please check your connection and try again.');
        isDialogMounted = true; // Set the dialog mount status to true
      }
    } else {
      // Internet connection is available
      showSnackbar('Internet connection is available.');
      if (isDialogMounted) {
        // If the dialog is mounted, dismiss it
        Navigator.of(navigatorKey.currentState!.context).pop();
        isDialogMounted = false; // Set the dialog mount status to false
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.wifi,
              color: darkModeGrassColor,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
      ),
    );
  }

  void showInternetConnectionDialog(String message) {
    showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false, // user must tap button to close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Flexible(child: Text('Internet Connection Status')),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
                isDialogMounted =
                    false; // Set the dialog mount status to false when dismissed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DarkModeProvider()),
        ChangeNotifierProvider(create: (_) => DialogProvider()),
      ],
      child: Builder(builder: (context) {
        final darkMode = Provider.of<DarkModeProvider>(context).darkMode;
        final theme = darkMode ? ThemeData.dark() : ThemeData.light();

        return OverlaySupport(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: theme,
            // showPerformanceOverlay: true,
            title: 'CSPC Student Event Calendar',
            home: const AuthScreen(),
          ),
        );
      }),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static bool runningOnMobile() {
    return !kIsWeb;
  }

  static bool runningOnWeb() {
    return kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
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
                return Center(
                  child: CircularProgressIndicator(
                      color: darkModeOn
                          ? darkModePrimaryColor
                          : lightModePrimaryColor),
                );
              }
              // Check if document exists
              if (snapshot.hasData && snapshot.data!.exists) {
                final String userType = snapshot.data!.get('userType');

                if (userType == 'Admin' && runningOnWeb()) {
                  return const AdminScreenLayout();
                } else if ((userType == 'Student' && runningOnMobile()) ||
                    (userType == 'Staff' && runningOnMobile()) ||
                    (userType == 'Officer' && runningOnMobile())) {
                  return const ClientScreenLayout();
                } else {
                  return const UnknownUser();
                }
              } else {
                // Handle case when the document does not exist
                if (runningOnMobile() || runningOnWeb()) {
                  return const LoginScreen();
                } else {
                  return const Center(
                    child: Text('Unsupported Platform'),
                  );
                }
              }
            },
          );
        }
        if (runningOnMobile() || runningOnWeb()) {
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

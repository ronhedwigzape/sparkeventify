import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:student_event_calendar/firebase_options.dart';
import 'package:student_event_calendar/platforms/admin.dart';
import 'package:student_event_calendar/platforms/client.dart';
import 'package:student_event_calendar/providers/user_provider.dart';
import 'package:student_event_calendar/screens/admin_login_screen.dart';
import 'package:student_event_calendar/screens/client_login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
enum AppPlatform { web, android, ios, unknown }

AppPlatform getPlatform() {
  if (kIsWeb) {
    return AppPlatform.web;
  } else if (Platform.isAndroid) {
    return AppPlatform.android;
  } else if (Platform.isIOS) {
    return AppPlatform.ios;
  } else {
    return AppPlatform.unknown;
  }
}

Widget getApp(AppPlatform platform) {
  switch (platform) {
    case AppPlatform.web:
      return const Admin();
    case AppPlatform.android:
    case AppPlatform.ios:
      return const Client();
    default:
      throw UnsupportedError('Unsupported platform');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(getApp(getPlatform()));
}

Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Event Calendar',
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                if (Platform.isAndroid) {
                  return const Client();
                } else if (Platform.isIOS) {
                  return const Client();
                } else if (kIsWeb) {
                  return const Admin();
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }
            // login
            if (kIsWeb) {
              return const AdminLoginScreen();
            } else if (Platform.isAndroid) {
              return const ClientLoginScreen();
            } else if (Platform.isIOS) {
              return const ClientLoginScreen();
            }
            return const SizedBox();
          }),
    ),
  );
}

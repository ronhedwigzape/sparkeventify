import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/auth/login_screen.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';

import 'global.dart';

class UnknownUser extends StatelessWidget {
  const UnknownUser({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToLogin() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
      AuthMethods().signOut();
    }

    return Center(
      child: Scaffold(
          body: Container(
        padding: MediaQuery.of(context).size.width > webScreenSize
            ?
            // Web screen
            EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3)
            :
            // Mobile screen
            const EdgeInsets.symmetric(horizontal: 32.0),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Unknown user!',
              style: TextStyle(
                  fontSize: kIsWeb ? 50 : 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
                onPressed: () => navigateToLogin(),
                icon: const Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Icon(Icons.login),
                ),
                label: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Text('Go back to Login'),
                ))
          ],
        ),
      )),
    );
  }
}

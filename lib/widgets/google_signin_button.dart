import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: AuthMethods().signInWithGoogle,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: darkModeOn
                      ? darkModeTertiaryColor
                      : lightModeTertiaryColor,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 20,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    'Google',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

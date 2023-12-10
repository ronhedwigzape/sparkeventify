import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const GoogleSignInButton({super.key, required this.onGoogleSignIn});

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onGoogleSignIn,
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
                  Text(
                    'Google',
                    style: TextStyle(fontSize: 15, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
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

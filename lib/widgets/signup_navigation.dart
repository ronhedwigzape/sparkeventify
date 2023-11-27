import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class SignUpNavigation extends StatelessWidget {
  const SignUpNavigation({super.key, required this.navigateToSignup});
  final VoidCallback navigateToSignup;

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return !kIsWeb
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                child: Text(
                  'Don\'t have an account?',
                  style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                ),
              ),
              GestureDetector(
                onTap: navigateToSignup,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Text(
                    ' Sign up.',
                    style: TextStyle(
                      color: darkModeOn ? lightColor : darkColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          )
        : const SizedBox.shrink();
  }
}

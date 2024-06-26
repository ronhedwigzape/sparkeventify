import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class LoginDivider extends StatelessWidget {
  const LoginDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
            height: 50,
            thickness: 2,
            indent: 20,
            endIndent: 20,
          ),
        ),
        Text('or', style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),),
        Expanded(
          child: Divider(
            color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
            height: 50,
            thickness: 2,
            indent: 20,
            endIndent: 20,
          ),
        ),
      ],
    );
  }
}

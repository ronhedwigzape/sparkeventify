import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key, required this.signIn});

  final VoidCallback signIn;

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return InkWell(
      onTap: signIn,
      child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: ShapeDecoration(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            color: darkModeOn ? darkModePrimaryColor : lightModeBlueColor,
          ),
          child: const Text(
            'Log in',
            style: TextStyle(
              color: lightColor,
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }
}

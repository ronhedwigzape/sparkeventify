import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/screens/auth/officer_signup_screen.dart';
import 'package:student_event_calendar/screens/auth/staff_signup_screen.dart';
import 'package:student_event_calendar/screens/auth/student_signup_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import '../../providers/darkmode_provider.dart';

class ClientSelectionScreen extends StatefulWidget {
  const ClientSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ClientSelectionScreen> createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> {
  void onStudentTap() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const StudentSignupScreen()));
  }

  void onOfficerTap() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const OfficerSignupScreen()));
  }

  void onStaffTap() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const StaffSignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context, listen: false).darkMode;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CSPC Logo
            const CSPCLogo(
              height: 150.0,
            ),
            // CSPC Address
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Text(
                    schoolName,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: darkModeOn ? lightColor : darkColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Text(schoolAddress, style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                ),
              ],
            ),
            const SizedBox(height: 40.0),
            // Client Selection Buttons
            InkWell(
              onTap: onStudentTap,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: darkModeOn ? darkColor : lightColor,
                    border: Border.all(color: darkModeOn ? darkModeSecondaryColor : secondaryDarkColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Student'.toUpperCase(), style: TextStyle(color: darkModeOn ? lightColor : darkColor),)),
            ),
            InkWell(
              onTap: onOfficerTap,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: darkModeOn ? darkColor : lightColor,
                    border: Border.all(color: darkModeOn ? darkModeSecondaryColor : secondaryDarkColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Organization Officer'.toUpperCase(), style: TextStyle(color: darkModeOn ? lightColor : darkColor))),
            ),
            InkWell(
              onTap: onStaffTap,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: darkModeOn ? darkColor : lightColor,
                    border: Border.all(color: darkModeOn ? darkModeSecondaryColor : secondaryDarkColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('SASO Staff'.toUpperCase(), style: TextStyle(color: darkModeOn ? lightColor : darkColor))),
            ),
          ],
        ),
      ),
    );
  }
}

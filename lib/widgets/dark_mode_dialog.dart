import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';

class DarkModeDialog extends StatefulWidget {
  const DarkModeDialog({super.key});

  @override
  State<DarkModeDialog> createState() => _DarkModeDialogState();
}

class _DarkModeDialogState extends State<DarkModeDialog> {

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    return SimpleDialog(
      title: Row(
        children: [
          Icon(darkModeOn ? Icons.light_mode : Icons.dark_mode,
            color: darkModeOn ? lightColor : darkColor,),
          const SizedBox(width: 10),
          Text(
            'Switch to ${darkModeOn ? 'Light' : 'Dark'} Mode',
            style: TextStyle(
              color: darkModeOn ? lightColor : darkColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Are you sure you want to switch to ${darkModeOn ? 'Light' : 'Dark'} Mode? This will reload the app.',
            style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
            ),
        ),
        SimpleDialogOption(
          padding: const EdgeInsets.all(20),
          onPressed:() async {
            bool isConnected = await ConnectivityService().isConnected();
            if (isConnected) {
                mounted ? Provider.of<DarkModeProvider>(context, listen: false).toggleTheme() : '';
                mounted ? Navigator.of(context).pop() : '';
            } else {
              // Show a message to the user
              mounted ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
                  duration: const Duration(seconds: 5),
                ),
              ) : '';
            }
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.check_circle, 
              color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
              const SizedBox(width: 10),
              Text('Yes', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
            ],
          ),
        ),
        SimpleDialogOption(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Icon(Icons.cancel, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
              const SizedBox(width: 10),
              Text('No', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
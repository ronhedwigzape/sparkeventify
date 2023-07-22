import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/darkmode_provider.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  _signOut() async {
    return showDialog(
        context: context,
        builder: (context) {
          final darkModeOn = Provider.of<DarkModeProvider>(context, listen: false).darkMode;
          return SimpleDialog(
            title: Text(
              'Log Out Confirmation',
              style: TextStyle(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text('Are you sure you want to sign out?'),
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                onPressed: () async {
                  await AuthMethods().signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle, color: darkModeOn ? darkModeGrassColor : lightModeGrassColor),
                    const SizedBox(width: 10),
                    const Text('Yes'),
                  ],
                ),
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.cancel, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                    const SizedBox(width: 10),
                    const Text('Go Back'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      body: Row(
        children: [
          IconButton(
            onPressed: () => Provider.of<DarkModeProvider>(context, listen: false).toggleTheme(),
            icon: Icon(darkModeOn ? Icons.dark_mode : Icons.light_mode, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
            tooltip: 'Switch to ${darkModeOn ? 'Light' : 'Dark'} Mode',
          ),
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout,
                color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
            tooltip: 'Log out',
          ),
        ],
      ),

    );
  }
}

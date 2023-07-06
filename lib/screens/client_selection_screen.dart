import 'package:flutter/material.dart';
import 'package:student_event_calendar/screens/client_login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';

class ClientSelectionScreen extends StatefulWidget {
  const ClientSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ClientSelectionScreen> createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> {

  void onClientTap() {
    Navigator.of(context)
    .push(MaterialPageRoute(
      builder: (context) => 
      const ClientLoginScreen()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CSPC Logo
            const Image(image: AssetImage('assets/cspc_logo.png'), height: 200.0),
            // CSPC Address
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: const Text(
                    'Camarines Sur Polytechnic Colleges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: const Text('Nabua, Camarines Sur'),
                ),
              ],
            ),
            const SizedBox(height: 40.0),
            // Client Selection Buttons
            InkWell(
              onTap: onClientTap,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Student'.toUpperCase())),
            ),
            InkWell(
              onTap: onClientTap,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Organization Officer'.toUpperCase())),
            ),
            InkWell(
              onTap: onClientTap,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('SASO Staff'.toUpperCase())),
            ),
          ],
        ),
      ),
    );
  }
}

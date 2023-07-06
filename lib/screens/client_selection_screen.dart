import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/colors.dart';

class ClientSelectionScreen extends StatefulWidget {
  const ClientSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ClientSelectionScreen> createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/cspc_logo.png'), 
              height: 200.0
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8,),
                  child: const Text(
                    'Camarines Sur Polytechnic Colleges',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8,),
                  child: const Text('Nabua, Camarines Sur'),
                ),
              ],
            ),
            const SizedBox(height: 40.0),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                color: blueColor,
              ),
              child: Text('Student'.toUpperCase())
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                color: blueColor,
              ),
              child: Text('Organization Officer'.toUpperCase())
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                color: blueColor,
              ),
              child: Text('SASO Staff'.toUpperCase())
            ),
          ],
        ),
      ),
    );
  }
}

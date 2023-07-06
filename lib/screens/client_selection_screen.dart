import 'package:flutter/material.dart';

class ClientSelectionScreen extends StatelessWidget {
  const ClientSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // AppBar configuration for the mobile platform
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle student login
              },
              child: const Text('Student'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle organization officer login
              },
              child: const Text('Organization Officer'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle school staff login
              },
              child: const Text('Staff'),
            ),
          ],
        ),
      ),
    );
  }
}

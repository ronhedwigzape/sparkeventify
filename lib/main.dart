import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


void main() {
  if (kIsWeb) {
    runApp(const SchoolAdminApp());
  } else {
    runApp(const SchoolApp());
  }
}

class SchoolAdminApp extends StatelessWidget {
  const SchoolAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Admin',
      theme: ThemeData(
        // Theme configuration for the web platform
      ),
      home: const SchoolAdminHomePage(),
    );
  }
}

class SchoolAdminHomePage extends StatelessWidget {
  const SchoolAdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar configuration for the web platform
      ),
      body: const Center(
        child: Text('School Admin Home Page'),
      ),
    );
  }
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      theme: ThemeData(
        // Theme configuration for the mobile platform
      ),
      home: const UserTypeSelectionPage(),
    );
  }
}

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({Key? key}) : super(key: key);

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
              child: const Text('School Staff'),
            ),
          ],
        ),
      ),
    );
  }
}


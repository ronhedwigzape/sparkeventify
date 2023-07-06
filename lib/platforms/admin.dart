import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Admin',
      theme: ThemeData(
          // Theme configuration for the web platform
          ),
      home: const Text('Admin Page'),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key, required this.snap}) : super(key: key);

  final snap;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: AppBar(
        iconTheme: darkModeOn ? const IconThemeData(color: darkColor) : const IconThemeData(color: lightColor),
        backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
        elevation: 0.0,
        title: Text('${widget.snap['type'] == 'Academic' ? 'Announcement' : 'Event'} Details',
          style: TextStyle(color: darkModeOn ? darkColor : lightColor),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.snap['id'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final snap = snapshot.data;

          return Column(
            children: [
              Text(snap?['title'] ?? 'No title', style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),),
              Text(snap?['description'] ?? 'No description'),
            ],
          );
        },
      ),
    );
  }
}

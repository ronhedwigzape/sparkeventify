import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

class PersonalEventDialog extends StatefulWidget {
  const PersonalEventDialog({super.key, this.personalEvent});

  final PersonalEvent? personalEvent;

  @override
  State<PersonalEventDialog> createState() => _PersonalEventDialogState();
}

class _PersonalEventDialogState extends State<PersonalEventDialog> {
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return AlertDialog(
      title: Text(widget.personalEvent!.title, style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor, fontSize: 24)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Start Date: ${widget.personalEvent!.startDate}'),
            Text('End Date: ${widget.personalEvent!.endDate}'),
            Text('Start Time: ${widget.personalEvent!.startTime}'),
            Text('End Time: ${widget.personalEvent!.endTime}'),
            Text('Description: ${widget.personalEvent!.description}'),
            Text('Created By: ${widget.personalEvent!.createdBy}'),
            Text('Venue: ${widget.personalEvent!.venue}'),
            Text('Type: ${widget.personalEvent!.type}'),
            Text('Status: ${widget.personalEvent!.status}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close', style: TextStyle(color: white)),
        ),
      ],
    );
  }
}

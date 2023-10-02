import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/personal_event.dart';

class PersonalEventDialog extends StatefulWidget {
  const PersonalEventDialog({super.key, this.personalEvent});

  final PersonalEvent? personalEvent;

  @override
  State<PersonalEventDialog> createState() => _PersonalEventDialogState();
}

class _PersonalEventDialogState extends State<PersonalEventDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.personalEvent!.title),
      content: Text(widget.personalEvent!.description),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
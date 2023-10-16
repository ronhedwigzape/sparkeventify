import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';

import '../providers/darkmode_provider.dart';
import '../utils/colors.dart';

class FeedbackSummaryButton extends StatefulWidget {
  const FeedbackSummaryButton({super.key, required this.eventId});

  final String eventId;

  @override
  State<FeedbackSummaryButton> createState() => _FeedbackSummaryButtonState();
}

class _FeedbackSummaryButtonState extends State<FeedbackSummaryButton> {
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return TextButton.icon(
      icon: Icon(Icons.feedback),
      label: Text('Show Feedback Summary'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder<Map<String, dynamic>>(
              future: FirestoreFeedbackMethods().getEventFeedbackSummary(widget.eventId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AlertDialog(
                    content: LinearProgressIndicator(
                      color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    content: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  Map<String, dynamic> summary = snapshot.data!;
                  return AlertDialog(
                    title: Text('Feedback Summary'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Total Evaluators: ${summary['totalEvaluators']}'),
                          Text('Satisfied Evaluators: ${summary['satisfiedEvaluators']}'),
                          Text('Dissatisfied Evaluators: ${summary['dissatisfiedEvaluators']}'),
                          Text('Programs: ${summary['programs'].entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
                          Text('Departments: ${summary['departments'].entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

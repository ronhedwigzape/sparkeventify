import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/evaluator_feedback.dart';
import 'package:student_event_calendar/models/event_feedbacks.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';

class EventFeedbackScreen extends StatefulWidget {
  const EventFeedbackScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends State<EventFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Event Feedback Evaluation')),
      body: FutureBuilder<List<EventFeedbacks>>(
        future: FirestoreFeedbackMethods().getAllFeedbacks(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LinearProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No feedbacks for this event.'));
            } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                EventFeedbacks eventFeedbacks = snapshot.data![index];
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventFeedbacks.evaluatorFeedbacks.length,
                  itemBuilder: (context, feedbackIndex) {
                    EvaluatorFeedback feedback = eventFeedbacks.evaluatorFeedbacks[feedbackIndex];
                    return Card(
                      child: ListTile(
                        title: Text(feedback.userFullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Program: ${feedback.userProgram}'),
                            Text('Department: ${feedback.userDepartment}'),
                            Text('Satisfaction: ${feedback.satisfactionStatus ? 'Satisfied' : 'Not satisfied'}'),
                            Text('Evaluation: ${feedback.studentEvaluation}'),
                            Text('Attendance: ${feedback.attendanceStatus ? 'Attended' : 'Did not attend'}'),
                            Text('Feedback done: ${feedback.isFeedbackDone ? 'Yes' : 'No'}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          }
        },
      ),
    );
  }
}

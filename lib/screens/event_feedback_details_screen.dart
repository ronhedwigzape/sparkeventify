import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/event_feedbacks.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';

class EventFeedbackDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventFeedbackDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventFeedbackDetailsScreen> createState() => _EventFeedbackDetailsScreenState();
}

class _EventFeedbackDetailsScreenState extends State<EventFeedbackDetailsScreen> {
  Map<String, dynamic> attendanceSummary = {};
  Map<int, int> satisfactionSummary = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  Map<String, int> programAttendance = {};
  Map<String, int> departmentAttendance = {};
  

  @override
  void initState() {
    super.initState();
    fetchFeedbackData();
  }

  Future<void> fetchFeedbackData() async {
    // Fetch attendance data
    var attendanceData = await FirestoreFeedbackMethods().getAttendanceForStudentsByProgramAndDepartment(widget.eventId);

    // Assuming we need to process feedbacks to get satisfaction data
    var allFeedbacks = await FirestoreFeedbackMethods().getAllFeedbacks(widget.eventId);
    processFeedbackData(allFeedbacks);
  }

  void processFeedbackData(List<EventFeedbacks> allFeedbacks) {
    int totalAttended = 0;
    int totalNotAttended = 0;
    allFeedbacks.forEach((eventFeedback) {
      eventFeedback.evaluatorFeedbacks.forEach((feedback) {
        String program = feedback.userProgram ?? 'Unknown';
        String department = feedback.userDepartment ?? 'Unknown';
        bool attended = feedback.attendanceStatus ?? false;

        if (attended) {
          totalAttended++;
          programAttendance.update(program, (value) => value + 1, ifAbsent: () => 1);
          departmentAttendance.update(department, (value) => value + 1, ifAbsent: () => 1);
        } else {
          totalNotAttended++;
        }

        // Process satisfaction data
        int satisfaction = feedback.satisfactionStatus ?? 0;
        if (satisfaction >= 1 && satisfaction <= 5) {
          satisfactionSummary[satisfaction] = (satisfactionSummary[satisfaction] ?? 0) + 1;
        }
      });
    });

    setState(() {
      attendanceSummary = {'Attended': totalAttended, 'Not Attended': totalNotAttended};
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Event Attendance & Satisfaction Summary')),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance Summary', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Attended: ${attendanceSummary['Attended'] ?? 0}'),
            SizedBox(height: 4),
            Text('Did Not Attend: ${attendanceSummary['Not Attended'] ?? 0}'),
            Divider(),
            Text('Program Attendance', style: Theme.of(context).textTheme.titleLarge),
            ...programAttendance.entries.map((entry) {
              return ListTile(
                title: Text(entry.key), // Program name
                trailing: Text('Attended: ${entry.value}'),
              );
            }).toList(),
            Divider(),
            Text('Department Attendance', style: Theme.of(context).textTheme.titleLarge),
            ...departmentAttendance.entries.map((entry) {
              return ListTile(
                title: Text(entry.key), // Department name
                trailing: Text('Attended: ${entry.value}'),
              );
            }).toList(),
            Divider(),
            Text('Satisfaction Summary', style: Theme.of(context).textTheme.headline6),
            ...List.generate(5, (index) {
              String levelText = ["Worst", "Poor", "Average", "Good", "Excellent"][index];
              return ListTile(
                title: Text('Level ${index + 1} ($levelText):'),
                trailing: Text('${satisfactionSummary[index + 1] ?? 0}'),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

}

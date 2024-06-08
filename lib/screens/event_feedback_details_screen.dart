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
    
    // Process the fetched feedback data
    processFeedbackData(allFeedbacks);

    // Now, explicitly process the attendance data
    processAttendanceData(attendanceData);
  }

  void processAttendanceData(Map<String, Map<String, Map<String, bool>>> attendanceData) {
    int totalAttended = 0;
    int totalNotAttended = 0;
    Map<String, int> localProgramAttendance = {};
    Map<String, int> localDepartmentAttendance = {};

    attendanceData.forEach((program, deptData) {
      deptData.forEach((department, studentData) {
        studentData.forEach((studentId, attended) {
          if (attended) {
            totalAttended++;
            localProgramAttendance.update(program, (val) => val + 1, ifAbsent: () => 1);
            localDepartmentAttendance.update(department, (val) => val + 1, ifAbsent: () => 1);
          } else {
            totalNotAttended++;
          }
        });
      });
    });

    setState(() {
      programAttendance = localProgramAttendance;
      departmentAttendance = localDepartmentAttendance;
      attendanceSummary['Attended'] = totalAttended;
      attendanceSummary['Not Attended'] = totalNotAttended;
    });
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
    appBar: AppBar(title: const Center(child: Text('Event Attendance & Satisfaction Summary',
     style: TextStyle(fontWeight: FontWeight.w900),))),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 300.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 5,),
                Text('Attendance Summary', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Attended: ${attendanceSummary['Attended'] ?? 0}'),
                const SizedBox(width: 10),
                Text('Did Not Attend: ${attendanceSummary['Not Attended'] ?? 0}'),
              ],
            ),
            
            const Divider(),
            Row(
              children: [
                const Icon(Icons.school),
                const SizedBox(width: 5,),
                Text('Program Attendance', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            ...programAttendance.entries.map((entry) {
              return ListTile(
                title: Text(entry.key), // Program name
                trailing: Text('Attended: ${entry.value}'),
              );
            }).toList(),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.school),
                const SizedBox(width: 5,),
                Text('Department Attendance', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            ...departmentAttendance.entries.map((entry) {
              return ListTile(
                title: Text(entry.key), // Department name
                trailing: Text('Attended: ${entry.value}'),
              );
            }).toList(),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.rate_review),
                const SizedBox(width: 5,),
                Text('Satisfaction Summary', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
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

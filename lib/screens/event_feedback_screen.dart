import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event_feedbacks.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';
import 'package:student_event_calendar/screens/event_feedback_details_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:pie_chart/pie_chart.dart';

class EventFeedbackScreen extends StatefulWidget {
  const EventFeedbackScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends State<EventFeedbackScreen> {
  String? attendanceFilter;
  String? satisfactionFilter;
  String? programFilter;
  String? departmentFilter;
  List<DataRow> rows = [];

 @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Event Feedback Evaluation')),
      body: StreamBuilder<List<EventFeedbacks>>(
        stream: FirestoreFeedbackMethods().streamAllFeedbacks(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LinearProgressIndicator(
                color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
              ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No feedbacks for this event.'));
            } else {
              List<EventFeedbacks> feedbacks = snapshot.data!;
              Map<int, int> satisfactionCounts = Map.fromIterable(List.generate(6, (i) => i), value: (_) => 0);
              int totalEvaluators = 0; // Initialize total evaluators count

              for (var feedback in feedbacks) {
                for (var evaluatorFeedback in feedback.evaluatorFeedbacks) {
                  int satisfactionLevel = evaluatorFeedback.satisfactionStatus ?? 0;
                  satisfactionCounts[satisfactionLevel] = satisfactionCounts[satisfactionLevel]! + 1;
                  totalEvaluators++; // Increment total evaluators count for each feedback
                }
              }

              Map<String, double> dataMap = {
                "Worst": satisfactionCounts[1]?.toDouble() ?? 0.0,
                "Poor": satisfactionCounts[2]?.toDouble() ?? 0.0,
                "Average": satisfactionCounts[3]?.toDouble() ?? 0.0,
                "Good": satisfactionCounts[4]?.toDouble() ?? 0.0,
                "Excellent": satisfactionCounts[5]?.toDouble() ?? 0.0,
              };

              List<Color> colorList = [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.lightGreen,
                Colors.green,
              ];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total Evaluators: $totalEvaluators",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkModeOn ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    PieChart(
                      dataMap: dataMap,
                      animationDuration: const Duration(milliseconds: 800),
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 3.2,
                      initialAngleInDegree: 0,
                      centerText: "Satisfaction Levels",
                      legendOptions: const LegendOptions(
                        showLegendsInRow: true,
                        legendPosition: LegendPosition.right,
                        showLegends: true,
                        legendShape: BoxShape.circle,
                        legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ringStrokeWidth: 32,
                      colorList: colorList,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EventFeedbackDetailsScreen(eventId: widget.eventId),
                          ),
                        );
                      },
                      child: const Text('View Presentation of Attendance Details'),
                    )
                  ],
                ),
              );
            }
          }
        }
      ),
    );
  }
}

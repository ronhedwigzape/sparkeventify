import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event_feedbacks.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';
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
                  color:
                      darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                ));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No feedbacks for this event.'));
                } else {
                  int satisfiedCount = 0;
                  int notSatisfiedCount = 0;
                  rows = [];

                  for (var feedbacks in snapshot.data!) {
                    for (var feedback in feedbacks.evaluatorFeedbacks) {
                      if (feedback.satisfactionStatus!) {
                        satisfiedCount++;
                      } else {
                        notSatisfiedCount++;
                      }

                      rows.add(DataRow(
                        cells: <DataCell>[
                          DataCell(Text(feedback.userFullName!)),
                          DataCell(Text(feedback.userProgram!)),
                          DataCell(Text(feedback.userDepartment!)),
                          DataCell(Text(feedback.attendanceStatus!
                              ? 'Attended'
                              : 'Did not attend')),
                          DataCell(Text(feedback.satisfactionStatus!
                              ? 'Satisfied'
                              : 'Not satisfied')),
                        ],
                      ));
                    }
                  }

                  Map<String, double> dataMap = {
                    'Satisfied': satisfiedCount.toDouble(),
                    'Not Satisfied': notSatisfiedCount.toDouble(),
                  };


                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20,),
                      PieChart(
                        dataMap: dataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 3.2,
                        initialAngleInDegree: 0,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 32,
                        centerText: "Satisfaction",
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.right,
                          showLegends: true,
                          legendShape: BoxShape.circle,
                          legendTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValueBackground: true,
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: false,
                          decimalPlaces: 1,
                        ),
                      )
                    ]),
                  );
                }
              }
            }));
  }
}

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
  List<DataRow> filteredRows = [];

  void filterRows() {
    setState(() {
      filteredRows = rows.where((row) {
        final programCell = row.cells[1].child as Text;
        final departmentCell = row.cells[2].child as Text;
        final attendanceCell = row.cells[3].child as Text;
        final satisfactionCell = row.cells[4].child as Text;
        return (attendanceFilter == null || attendanceCell.data == attendanceFilter) &&
            (satisfactionFilter == null || satisfactionCell.data == satisfactionFilter) &&
            (programFilter == null || programCell.data == programFilter) &&
            (departmentFilter == null || departmentCell.data == departmentFilter);
      }).toList();
    });
  }

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

                  filteredRows = List.from(rows);

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
                      ),
                      DropdownButton<String>(
                        value: attendanceFilter,
                        items: <String>[
                          'All',
                          'Attended',
                          'Did not attend',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            attendanceFilter =
                                newValue == 'All' ? null : newValue;
                            filterRows();
                          });
                        },
                      ),
                      DropdownButton<String>(
                        value: satisfactionFilter,
                        items: <String>[
                          'All',
                          'Satisfied',
                          'Not satisfied',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            satisfactionFilter =
                                newValue == 'All' ? null : newValue;
                            filterRows();
                          });
                        },
                      ),
                      // Add similar DropdownButtons for programFilter and departmentFilter here
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Program'),
                          ),
                          DataColumn(
                            label: Text('Department'),
                          ),
                          DataColumn(
                            label: Text('Attendance'),
                          ),
                          DataColumn(
                            label: Text('Satisfaction'),
                            numeric: true,
                          ),
                        ],
                        rows: filteredRows,
                      )
                    ]),
                  );
                }
              }
            }));
  }
}

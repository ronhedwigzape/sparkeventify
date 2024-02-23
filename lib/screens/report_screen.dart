import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:pdf/widgets.dart' as pw;

class ReportScreen extends StatefulWidget {
  final List<model.Event> events;

  const ReportScreen({Key? key, required this.events}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<model.Event> filteredEvents = [];
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  String? selectedVenue;
  String? selectedDepartment;
  List<String> venues = [];
  List<String> departments = [];

  @override
  void initState() {
    super.initState();
    venues = ['All', ...widget.events.map((e) => e.venue ?? 'N/A').toSet().toList()];
    departments = ['All', ...widget.events.expand((e) => e.participants?['department'] ?? []).cast<String>().toSet().toList()];

    // Create a set of unique events based on a unique identifier
    final uniqueEvents = <String, model.Event>{};
    for (var event in widget.events) {
      String uniqueId = '${event.title}-${event.startDate}-${event.venue}';
      if (!uniqueEvents.containsKey(uniqueId)) {
        uniqueEvents[uniqueId] = event;
      }
    }

    filteredEvents = uniqueEvents.values.toList();
  }

  void filterEvents() {
    setState(() {
      filteredEvents = widget.events.where((event) {
        bool venueMatch = selectedVenue == null || selectedVenue == 'All' || event.venue == selectedVenue;
        // Explicitly check for null before using the list in a condition
        bool departmentMatch = selectedDepartment == null || selectedDepartment == 'All' || (event.participants?['department'] != null && event.participants!['department'].contains(selectedDepartment));
        return venueMatch && departmentMatch;
      }).toList();
    });
  }

  Future<void> selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (picked != null) {
      final startDate = picked.start;
      final endDate = picked.end;

      setState(() {
        filteredEvents = widget.events.where((event) =>
          event.startDate!.isAfter(startDate) && event.endDate!.isBefore(endDate)
        ).toList();
      });
    }
  }

  Future<void> generatePdf(List<model.Event> events) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("fonts/OpenSans-Regular.ttf"));
    const double fontSize = 10.0;
    const cellPadding = pw.EdgeInsets.all(4.0);
    var myPageFormat = PdfPageFormat.a4.landscape;

    final headers = ['Event Date', 'Event Title', 'Start Time', 'End Time', 'Venue', 'Participants'];

    // Create a set of unique events based on a unique identifier, e.g., title and date
    final uniqueEvents = <String>{};
    final uniqueEventList = <model.Event>[];

    for (var event in events) {
      String uniqueId = '${event.title}-${event.startDate}';
      if (!uniqueEvents.contains(uniqueId)) {
        uniqueEvents.add(uniqueId);
        uniqueEventList.add(event);
      }
    }

    List<pw.TableRow> createEventRows(Set<model.Event> uniqueEvents) {
      return uniqueEvents.map((event) {
        final eventDate = event.startDate!.isAtSameMomentAs(event.endDate!)
          ? DateFormat('yyyy-MM-dd').format(event.startDate!)
          : '${DateFormat('yyyy-MM-dd').format(event.startDate!)} to ${DateFormat('yyyy-MM-dd').format(event.endDate!)}';
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(eventDate, style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(event.title!, style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(DateFormat('hh:mm a').format(event.startTime!), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(DateFormat('hh:mm a').format(event.endTime!), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(event.venue ?? 'N/A', style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(
                event.participants?['department']?.join(", ") ?? 'N/A',
                style: pw.TextStyle(font: font, fontSize: fontSize)
              ),
            ),
          ],
        );
      }).toList();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: myPageFormat,
        header: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Center(child: pw.Text('Camarines Sur Polytechnic Colleges', style: pw.TextStyle(font: font, fontSize: fontSize))),
            pw.SizedBox(height: 10.0),
            pw.Center(child: pw.Text('MONTHLY MONITORING SHEET OF STUDENTS’ ACTIVITY CONDUCTED', style: pw.TextStyle(font: font, fontSize: fontSize))),
            pw.SizedBox(height: 10.0)
          ],
        ),
        build: (pw.Context context) => [
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: headers.map((header) => 
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4.0),
                    child: pw.Text(header, style: pw.TextStyle(font: font, fontSize: fontSize)),
                  )
                ).toList(),
              ),
              ...createEventRows(uniqueEventList.toSet()), // Pass unique events to create rows
            ],
          ),
        ],
      ),
    );

    final pdfContentBytes = await pdf.save();

    // Use the appropriate method to save the PDF file
    // For example, using the path_provider and flutter_file_saver packages
    // final output = await getTemporaryDirectory();
    // final file = File("${output.path}/Event Report.pdf");
    // await file.writeAsBytes(pdfContentBytes);

    // If you want to share the PDF or open it using another app
    await FlutterFileSaver().writeFileAsBytes(
      fileName: 'Event Report.pdf',
      bytes: pdfContentBytes,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          // Venue Dropdown
          DropdownButton<String>(
            value: selectedVenue,
            hint: const Text("Select Venue"),
            items: venues.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedVenue = newValue;
              });
              filterEvents();
            },
          ),
          const SizedBox(width: 10,),
          // Department Dropdown
          DropdownButton<String>(
            value: selectedDepartment,
            hint: const Text("Select Participants"),
            items: departments.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDepartment = newValue;
              });
              filterEvents();
            },
          ),
          const SizedBox(width: 10,),
          IconButton(
            onPressed: selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: 'Select Date Range',
          ),
          const SizedBox(width: 10,),
          IconButton(
            onPressed: () => generatePdf(filteredEvents),
            icon: const Icon(Icons.print),
            tooltip: 'Generate PDF',
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _printKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('MONTHLY MONITORING SHEET OF STUDENTS’ ACTIVITY CONDUCTED'),
                  ],
                ),
                const SizedBox(height: 20,),
                DataTable(
                  dataRowMinHeight: 100,  // Adjust this to change the minimum row height
                  dataRowMaxHeight: 100, // Adjust this to change the row height
                  headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (Theme.of(context).brightness == Brightness.dark) {
                      return Colors.grey.shade800;  // choose the color for dark mode
                    } else {
                      return Colors.grey.shade200;  // choose the color for light mode
                    }
                  }),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Event Date')),
                    DataColumn(label: Text('Event Title')),
                    DataColumn(label: Flexible(child: Text('Time'))),
                    DataColumn(label: Text('Venue')),
                    DataColumn(label: Text('Participants')),
                  ],
                  rows: filteredEvents.map(
                    (event) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(event.startDate!), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))),
                        DataCell(Flexible(child: Text(event.title!, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)))),
                        DataCell(Text(DateFormat('hh:mm a').format(event.startTime!), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))),
                        DataCell(Text(event.venue ?? 'N/A', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))),
                        DataCell(
                          SizedBox(
                            height: 100,  // Match this with dataRowHeight
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...event.participants!['department'].map<Widget>((dept) => Text(dept, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_io/io.dart';

class ReportScreen extends StatefulWidget {
  final List<model.Event> events;
  final String currentMonth;

  const ReportScreen({Key? key, required this.events, required this.currentMonth}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<model.Event> filteredEvents = [];
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    filteredEvents = widget.events;
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
          event.startDate.isAfter(startDate) && event.endDate.isBefore(endDate)
        ).toList();
      });
    }
  }

  Future<pw.MemoryImage?> _fetchImage(String url) async {
    try {
      final httpClient = HttpClient();
      final ioClient = IOClient(httpClient);
      final response = await ioClient.get(Uri.parse(url));
      return pw.MemoryImage(response.bodyBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching image $url: $e');
      }
      return null;
    }
  }

  Future<void> generatePdf(List<model.Event> events) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("fonts/OpenSans-Regular.ttf"));
    const double fontSize = 10.0;
    const cellPadding = pw.EdgeInsets.all(4.0);
    var myPageFormat = PdfPageFormat.a4.portrait;

    Map<model.Event, pw.MemoryImage?> images = {};
    for (var event in events) {
      images[event] = event.image != null ? await _fetchImage(event.image!) : null;
    }

    final headers = ['Event Date', 'Event Title', 'Start Time', 'Venue', 'Participants'];

    List<pw.TableRow> createEventRows(List<model.Event> events, Map<model.Event, pw.MemoryImage?> images) {
      return events.map((event) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(DateFormat('yyyy-MM-dd').format(event.startDate) + ' to ' + DateFormat('yyyy-MM-dd').format(event.endDate), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(event.title, style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(DateFormat('hh:mm a').format(event.startTime), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(event.venue ?? 'N/A', style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(event.participants!['department'].join(", "), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
          ],
        );
      }).toList();
    }

    List<pw.Widget> pages = [];
    for (int i = 0; i < events.length; i += 10) {
      pages.add(
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
            ...createEventRows(events.sublist(i, i + 10 < events.length ? i + 10 : events.length), images),
          ],
        ),
      );
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
            pw.SizedBox(height: 10.0),
            pw.Center(child: pw.Text(widget.currentMonth, style: pw.TextStyle(font: font, fontSize: fontSize))),
          ],
        ),
        build: (pw.Context context) => pages,
      ),
    );

    final pdfContentBytes = await pdf.save();

    await FlutterFileSaver().writeFileAsBytes(
      fileName: 'Event Report.pdf',
      bytes: pdfContentBytes,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report for ${widget.currentMonth}'),
        actions: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.currentMonth)
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
                    DataColumn(label: Text('Start Time')),
                    DataColumn(label: Text('Venue')),
                    DataColumn(label: Text('Participants')),
                  ],
                  rows: filteredEvents.map(
                    (event) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(event.startDate), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))),
                        DataCell(Text(event.title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))),
                        DataCell(Text(DateFormat('hh:mm a').format(event.startTime), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color))),
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


import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:student_event_calendar/utils/colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_io/io.dart';
import 'package:pdf/pdf.dart';


class ReportScreen extends StatelessWidget {
  final List<model.Event> events;
  final String currentMonth;
  const ReportScreen({super.key, required this.events, required this.currentMonth});

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

    // Define a smaller font size
    const double fontSize = 10.0;

    // Define consistent padding for table cells
    const cellPadding = pw.EdgeInsets.all(4.0);  // Adjust this value as needed for padding

    // Define the width for each column
    // const double columnWidth = 0.125; // This represents a fraction of the total table width
    // final columnWidths = <int, pw.TableColumnWidth>{
    //   0: pw.FlexColumnWidth(columnWidth),
    //   1: pw.FlexColumnWidth(columnWidth),
    //   2: pw.FlexColumnWidth(columnWidth),
    //   3: pw.FlexColumnWidth(columnWidth),
    //   4: pw.FlexColumnWidth(columnWidth),
    //   5: pw.FlexColumnWidth(columnWidth),
    //   6: pw.FlexColumnWidth(columnWidth),
    //   7: pw.FlexColumnWidth(columnWidth),
    //   // Add or remove columns based on your table
    // };
    
    // Predefined A4 size - most common for documents
    var myPageFormat = PdfPageFormat.a4;

    // Custom shorter page format - for example, A5 size
    // var myShortPageFormat = PdfPageFormat.a5;

    // Custom longer page format - you can specify the size you need
    // var myLongPageFormat = const PdfPageFormat(
    //   21.0 * PdfPageFormat.cm,
    //   29.7 * PdfPageFormat.cm,
    //   marginAll: 2.0 * PdfPageFormat.cm,
    // );

    // Decide which format to use
    // myPageFormat = myShortPageFormat; // Uncomment to use short format
    myPageFormat = PdfPageFormat.legal;  // Uncomment to use long format

    // Fetch all images first and store them in a map
    Map<model.Event, pw.MemoryImage?> images = {};
    for (var event in events) {
      images[event] = event.image != null ? await _fetchImage(event.image!) : null;
    }

    // Creating table headers
    final headers = ['Event Title', 'Start Date', 'End Date', 'Start Time', 'End Time', 'Description', 'Venue', 'Type',];

    // Function to create a row for each event
    List<pw.TableRow> createEventRows(List<model.Event> events, Map<model.Event, pw.MemoryImage?> images) {
      return events.map((event) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(event.title, style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding,            
              child: pw.Text(DateFormat('yyyy-MM-dd').format(event.startDate), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(DateFormat('yyyy-MM-dd').format(event.endDate), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(DateFormat('hh:mm a').format(event.startTime), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(DateFormat('hh:mm a').format(event.endTime), style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(event.description, style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(event.venue ?? 'N/A', style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
            pw.Padding(
              padding: cellPadding, 
              child: pw.Text(event.type, style: pw.TextStyle(font: font, fontSize: fontSize)),
            ),
          ],
        );
      }).toList();
    }

    // Adding the table to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: myPageFormat.copyWith(
                      marginBottom: 10, // Adjust bottom margin
                      marginLeft: 10,   // Adjust left margin
                      marginRight: 10,  // Adjust right margin
                      marginTop: 10,    // Adjust top margin
                    ).landscape,
        build: (pw.Context context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(2.0), 
            child: pw.Header(
              level: 0,
              child: pw.Center(
                child: pw.Text('Report for $currentMonth', style: pw.TextStyle(font: font)),
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
               pw.TableRow(
                children: headers.map((header) => 
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4.0), // Adjust padding as needed
                    child: pw.Text(header, style: pw.TextStyle(font: font, fontSize: fontSize)),
                  )
                ).toList(),
              ),
              ...createEventRows(events, images),
            ],
          ),
        ],
      ),
    );

    // Finalize the PDF and get the file content as a Uint8List
    final pdfContentBytes = await pdf.save();

    // Save the file using flutter_file_saver
    await FlutterFileSaver().writeFileAsBytes(
      fileName: 'Event Report.pdf',
      bytes: pdfContentBytes,
    );
  }


  @override
  Widget build(BuildContext context) {
    final uniqueEvents = events.toSet().toList();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
     
        final maxWidth = min(1600, constraints.maxWidth).toDouble();
        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            title: Text('Report for $currentMonth'),
            actions: [
              IconButton(
                onPressed: () async {
                  await generatePdf(uniqueEvents);
                },
                icon: const Icon(Icons.print),
                tooltip: 'Generate PDF',
              )
            ],
          ), // remove AppBar in print version
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView.builder(
                itemCount: uniqueEvents.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(10), 
                    padding: const EdgeInsets.all(10), 
                    decoration: BoxDecoration(
                      border: Border.all(color: black, width: 1), 
                    ),
                    child: ListTile(
                      title: Text(
                        uniqueEvents[index].title, 
                        style: const TextStyle(color: black)),
                      subtitle: Text(
                        uniqueEvents[index].description, 
                        style: const TextStyle(color: black)),
                    ),
                  );
                }
              ),
            ),
          )
        );
      }
    );
  }
}


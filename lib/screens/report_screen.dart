import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:http/io_client.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:student_event_calendar/utils/colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_io/io.dart';


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

    List<pw.Widget> eventWidgets = [];

    eventWidgets.add(
      pw.Header(
        level: 0,
        child: pw.Center(
          child: pw.Text('Report for $currentMonth', style: pw.TextStyle(font: font)),
        ),
      ),
    );

    for (var event in events) {
      final image = event.image != null ? await _fetchImage(event.image!) : null;
      eventWidgets.add(
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: <pw.Widget>[
            pw.Header(
              level: 1,
              child: pw.Center(
                child: pw.Text('Event Title: ${event.title}', style: pw.TextStyle(font: font)),
              ),
            ),
            if (image != null)
              pw.Center(
                child: pw.Image(image, width: 200.0),
              ),
            pw.Center(
              child: pw.Paragraph(
                text: 'Event Description: ${event.description}',
                style: pw.TextStyle(font: font,)
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.ListView(
          children: eventWidgets,
        ),
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


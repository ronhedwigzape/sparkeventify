import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:student_event_calendar/utils/colors.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;


class ReportScreen extends StatelessWidget {
  final List<model.Event> events;
  const ReportScreen({super.key, required this.events});

  Future<pw.MemoryImage?> _fetchImage(String url) async {
    try {
      final response = await html.window.fetch(url);
      final data = await response.arrayBuffer();
      final blob = html.Blob([data]);
      final reader = html.FileReader();
      final completer = Completer<Uint8List>();
      reader.onLoadEnd.listen((_) => completer.complete(reader.result as Uint8List));
      reader.readAsArrayBuffer(blob);
      final imageData = await completer.future;
      return pw.MemoryImage(imageData);
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
  
    for (var event in events) {
      final image = event.image != null ? await _fetchImage(event.image!) : null;
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            children: <pw.Widget>[
              pw.Header(
                level: 0,
                child: pw.Text('Event Title: ${event.title}', style: pw.TextStyle(font: font)),
              ),
              if (image != null)
                pw.Image(image, width: 200.0),
              pw.Paragraph(
                text: 'Event Description: ${event.description}',
                style: pw.TextStyle(font: font,)
              ),
            ],
          ),
        ),
      );
    }
    // Saving the document to a List
    final bytes = await pdf.save();
    // Creating a blob for the data
    final blob = html.Blob([bytes], 'application/pdf');
    // Creating a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    // Creating an anchor element and clicking it to start the download
    html.AnchorElement(href: url)
      ..setAttribute('download', 'events.pdf')
      ..click();
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
            title: const Text('Report'),
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


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_event_calendar/utils/global.dart';

// Define a StatelessWidget as it has no mutable state
class CSPCBackground extends StatelessWidget {
  // Define the properties of the widget
  const CSPCBackground({
    super.key,
    required this.height, // Height of the image
  });
  final double height;

  // Build method for the widget
  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to handle the asynchronous loading of the image
    return FutureBuilder(
      future: loadImage(), // Load the image
      builder: (context, snapshot) {
        // Check the connection state of the Future
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, check if the data is not null
          if (snapshot.data != null) {
            // If the data is not null, return an Image widget
            return FittedBox(
              fit: BoxFit.cover,
              child: Image.memory(
                snapshot.data as Uint8List, // Convert the data to a Uint8List
                height: height.toDouble(), // Set the height of the image
              ),
            );
          } else {
            // If the data is null, return an empty widget
            return const SizedBox.shrink();
          }
        } else {
          // If the Future is not complete, return an empty widget
          return const SizedBox.shrink();
        }
      },
    );
  }


  // Method to load the image
  Future<Uint8List> loadImage() async {
    try {
      // Load the image data into a ByteData object
      final byteData = await rootBundle.load(schoolBackground);
      // Convert the ByteData to a Uint8List and return it
      return byteData.buffer.asUint8List();
    } catch (e, stacktrace) {
      // If an error occurs, print the error and stacktrace if in debug mode
      if (kDebugMode) {
        print('Error loading image: $e');
        print('Stacktrace: $stacktrace');
      }
      // Return an empty Uint8List
      return Uint8List(0);
    }
  }
}

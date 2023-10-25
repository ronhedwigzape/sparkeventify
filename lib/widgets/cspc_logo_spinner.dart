import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Define a StatelessWidget as it has no mutable state
class CSPCLogoSpinner extends StatelessWidget {
  // Define the properties of the widget
  const CSPCLogoSpinner({
    super.key,
    required this.height,
    required this.imageData, // Height of the image
  });

  final double height;
  final Uint8List imageData;

  // Build method for the widget
  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imageData,
      height: height.toDouble(),
    );
  }

}

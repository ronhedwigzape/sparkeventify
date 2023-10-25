import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo_spinner.dart';
import 'package:flutter/services.dart';

class CustomSpinner extends StatefulWidget {
  const CustomSpinner({Key? key}) : super(key: key);

  @override
  State<CustomSpinner> createState() => _CustomSpinnerState();
}

class _CustomSpinnerState extends State<CustomSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

    // Method to load the image
  Future<Uint8List> loadImage() async {
    try {
      // Load the image data into a ByteData object
      final byteData = await rootBundle.load(schoolLogo);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: loadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: RotationTransition(
                  turns: _controller,
                  child: CustomPaint(
                    painter: _SpinnerPainter(),
                  ),
                ),
              ),
              CSPCLogoSpinner(height: 50, imageData: snapshot.data!), // Pass the image data here
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
      super.dispose();
    }
  }

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    for (int i = 0; i < 8; i++) {
      final startAngle = (i * 45) * pi / 180;
      const sweepAngle = 30 * pi / 180;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

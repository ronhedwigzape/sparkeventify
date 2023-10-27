import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_event_calendar/utils/colors.dart';

class CSPCSpinKitFadingCircle extends StatefulWidget {
  const CSPCSpinKitFadingCircle({
    Key? key,
    this.color,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  final Color? color;
  final double? size;
  final Duration? duration;

  @override
  State<CSPCSpinKitFadingCircle> createState() => _CSPCSpinKitFadingCircleState();
}

class _CSPCSpinKitFadingCircleState extends State<CSPCSpinKitFadingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          !kIsWeb ? Image.asset(
            'assets/images/cspc_logo.png',
            width: 80,
            height: 80,
          ) : const SizedBox.shrink(),
          const SizedBox(height: 10),
          SpinKitFadingCircle(
            color: widget.color ?? lightModePrimaryColor,
            size: widget.size!,
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

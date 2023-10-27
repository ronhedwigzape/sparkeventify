import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';

class CSPCFadeLoader extends StatefulWidget {
  const CSPCFadeLoader({Key? key}) : super(key: key);

  @override
  State<CSPCFadeLoader> createState() => _CSPCFadeLoaderState();
}

class _CSPCFadeLoaderState extends State<CSPCFadeLoader> {

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        CSPCSpinKitFadingCircle(
          color: darkModePrimaryColor,
          size: 50.0,
          duration: Duration(milliseconds: 600),
        ),
      ],
    );
  }
}
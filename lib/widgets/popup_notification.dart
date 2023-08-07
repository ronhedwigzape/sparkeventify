import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:student_event_calendar/utils/colors.dart';

class PopupNotification extends StatelessWidget {
  final String message;
  final String title;

  const PopupNotification(
      {super.key, required this.message, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: lightColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
          child: ListTile(
            leading:
                ClipOval(child: Image.asset('assets/images/cspc_logo.png')),
            title: Text(
              title, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(color: darkColor)),
            subtitle: Text(
              message, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(color: darkColor)),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                OverlaySupportEntry.of(context)?.dismiss();
              },
            ),
          ),
        ),
      ),
    );
  }
}

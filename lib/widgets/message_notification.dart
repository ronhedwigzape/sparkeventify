import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class MessageNotification extends StatelessWidget {
  final String message;
  final String title;

  const MessageNotification({super.key, required this.message, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
          child: ListTile(
            leading: ClipOval(child: Image.asset('assets/images/cspc_logo.png')),
            title: Text(title),
            subtitle: Text(message),
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

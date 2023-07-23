import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/firebase_notifications.dart';
class NotificationButton extends StatefulWidget {
  final List<String> selectedUsers;

  const NotificationButton({Key? key, required this.selectedUsers}) : super(key: key);

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {

  void sendNotifications(List<String> selectedUsers, String title, String message) async {
    List<String> messages = [];
    for (String user in selectedUsers) {
      if (kDebugMode) {
        print("Notification sent to User $user");
        print("Title: $title");
        print("Message: $message");
      }
      messages.add(await FirebaseNotifications().sendNotificationToUser(user, title, message));
    }
    setState(() {
      selectedUsers.clear();
    });

    if (messages.every((message) => message == 'Notification sent successfully')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications sent successfully')),
        );
      }
    } else {
      for(String m in messages) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(m)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final formKey = GlobalKey<FormState>();
            String title = '';
            String message = '';

            return AlertDialog(
              title: Text('Send notifications to ${widget.selectedUsers.length} users'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Notification title'),
                      validator: (value) {
                        if (value == null || value.isEmpty || widget.selectedUsers.isEmpty) return 'Choose a user to notify & enter a title.';
                        title = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Notification message',
                          border: OutlineInputBorder()
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty || widget.selectedUsers.isEmpty) return 'Choose a user to notify & enter a message.';
                        message = value;
                        return null;
                      },
                    ),
                    TextButton(
                      child: const Text('Send'),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Close the dialog
                          Navigator.of(context).pop();
                          // Send the notification
                          sendNotifications(widget.selectedUsers, title, message);
                          setState(() {
                            widget.selectedUsers.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Text('Send Notifications (${widget.selectedUsers.length})'),
    );
  }
}
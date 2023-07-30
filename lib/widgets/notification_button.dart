import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';

import '../providers/darkmode_provider.dart';
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
      messages.add(
          await FirebaseNotifications().sendNotificationToUser(
              FirebaseAuth.instance.currentUser!.uid,
              user,
              title,
              message
          )
      );
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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
        backgroundColor: darkModeOn ? darkColor : lightColor
      ),
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
                          labelText: 'Notification message',
                          alignLabelWithHint: true,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel')),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor
                            ),
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
                            child: const Text('Send'),
                          ),
                        ],
                      ),
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

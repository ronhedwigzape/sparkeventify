import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/utils/colors.dart';
import '../providers/darkmode_provider.dart';
import '../services/firebase_notifications.dart';

class NotificationButton extends StatefulWidget {
  final List<String> selectedUsers;
  final Function clearSelectedUsers;

  const NotificationButton({Key? key, required this.selectedUsers, required this.clearSelectedUsers}) : super(key: key);

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {

  Future<String> sendNotifications(List<String> selectedUsers, String title, String message) async {
    List<String> messages = [];
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    String response = '';

    for (String user in selectedUsers) {
      if (kDebugMode) {
        print("Notification sent to User $user");
        print("Title: $title");
        print("Message: $message");
      }
      response = await FirebaseNotifications().sendNotificationToUser(
          currentUser,
          user,
          title,
          message
      );
      messages.add(response);
    }

    if (messages.every((message) => message == 'Notification sent successfully')) {
      widget.clearSelectedUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications sent successfully')),
        );
      }
    } else {
      // todo: refactor this
      widget.clearSelectedUsers();
      for(String m in messages) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(m)));
        }
      }
    }
    return response;
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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: darkModeOn ? darkColor : lightColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                width: MediaQuery.of(context).size.width - 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Text(
                                  'Send notifications to ${widget.selectedUsers.length} ${widget.selectedUsers.length > 1 ? 'users' : 'user'}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)
                              ),
                            ),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Notification title',
                                border: OutlineInputBorder()
                            ),
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
                                TextButton.icon(
                                    style: TextButton.styleFrom(
                                        foregroundColor: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                    label: const Text('Cancel'),
                                    icon: const Icon(Icons.cancel),),
                                TextButton.icon(
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
                                  icon: const Icon(Icons.send),
                                  label: const Text('Send'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            );
          });

    },
      child: Text('Send Notifications (${widget.selectedUsers.length})'),
    );
  }
}

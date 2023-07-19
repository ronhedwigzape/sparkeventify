import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/widgets/users_card.dart';
import '../models/user.dart' as model;

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  String dropdownUserType = 'All';
  String dropdownYear = 'All';
  String dropdownSection = 'All';
  List<String> selectedUsers = [];

  void selectAllUsers(List<model.User> users) {
    setState(() {
      List<String> allUserUids = users.map((user) => user.uid).toList();
      selectedUsers = allUserUids;
    });
  }

  void toggleAllSelected(List<model.User> users) {
    setState(() {
      List<String> allUserUids = users.map((user) => user.uid).toList();
      if (selectedUsers.length == allUserUids.length) {
        // If every user is already selected, clear the selection
        selectedUsers.clear();
      } else {
        // Otherwise, select every user
        selectedUsers = List.from(allUserUids);
      }
    });
  }

  void sendNotifications(List<String> selectedUsers, String title, String message) {
    for (String user in selectedUsers) {
      if (kDebugMode) {
        print("Notification sent to User $user");
        print("Title: $title");
        print("Message: $message");
      }
    }
    setState(() {
      selectedUsers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<model.User> allUsers = snapshot.data!.docs.map((doc) => model.User.fromSnap(doc)).toList();

        List<model.User> filteredUsers = allUsers.where((user) {
          return (dropdownUserType == 'All' || user.userType == dropdownUserType) &&
              (dropdownYear == 'All' || (user.profile?.year ?? 'All') == dropdownYear) &&
              (dropdownSection == 'All' || (user.profile?.section ?? 'All') == dropdownSection);
        }).toList();

        return Column(
          children: [
            DropdownButton<String>(
              value: dropdownUserType,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownUserType = newValue!;
                });
              },
              items: <String>['All', 'Student', 'Officer', 'Staff']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: dropdownYear,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownYear = newValue!;
                });
              },
              items: <String>['All', '1', '2', '3', '4']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: dropdownSection,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownSection = newValue!;
                });
              },
              items: <String>['All', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final formKey = GlobalKey<FormState>();
                    String title = '';
                    String message = '';

                    return AlertDialog(
                      title: const Text('Send notification'),
                      content: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Notification title'),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter a title.';
                                title = value;
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Notification message'),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter a message.';
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
                                  sendNotifications(selectedUsers, title, message);
                                  setState(() {
                                    selectedUsers.clear();
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
              child: const Text('Send Notifications'),
            ),
            ElevatedButton(
              onPressed: () {
                toggleAllSelected(filteredUsers);
              },
              child: const Text('Toggle Select All'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return UsersCard(
                    user: filteredUsers[index],
                    selectedUsers: selectedUsers,
                    onSelectedChanged: (uid) {
                      setState(() {
                        if (selectedUsers.contains(uid)) {
                          selectedUsers.remove(uid);
                        } else {
                          selectedUsers.add(uid);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/firestore_user_methods.dart';

class TrashedUsersScreen extends StatefulWidget {
  const TrashedUsersScreen({super.key});

  @override
  State<TrashedUsersScreen> createState() => _TrashedUsersScreenState();
}

class _TrashedUsersScreenState extends State<TrashedUsersScreen> {
  final FireStoreUserMethods firestoreUserMethods = FireStoreUserMethods();

  void _showRestoreDialog(model.User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore User'),
          content: Text('Are you sure you want to restore "${user.profile?.fullName} of ${user.profile?.program} - ${user.profile?.year}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Restore'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                String response = await firestoreUserMethods.restoreUser(user.uid!);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRemovePermanentlyDialog(model.User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove User Permanently'),
          content: Text('Are you sure you want to permanently remove "${user.profile?.fullName} of ${user.profile?.program} - ${user.profile?.year}"? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Remove'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                String response = await firestoreUserMethods.removeUserPermanently(user.uid!);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trashed Users'),
      ),
      body: StreamBuilder<List<model.User>>(
        stream: firestoreUserMethods.getTrashedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trashed users'));
          }

          List<model.User> trashedUsers = snapshot.data!;

          return ListView.builder(
            itemCount: trashedUsers.length,
            itemBuilder: (context, index) {
              model.User user = trashedUsers[index];
              return ListTile(
                title: Text(user.username ?? 'No Username'),
                subtitle: const Text('Trashed User'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () => _showRestoreDialog(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () => _showRemovePermanentlyDialog(user),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';

class TrashedEventsScreen extends StatefulWidget {
  const TrashedEventsScreen({super.key});

  @override
  State<TrashedEventsScreen> createState() => _TrashedEventsScreenState();
}

class _TrashedEventsScreenState extends State<TrashedEventsScreen> {
  final FireStoreEventMethods firestoreEventMethods = FireStoreEventMethods();

  void _showRestoreDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore Event'),
          content: Text('Are you sure you want to restore "${event.title}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Restore'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                String response = await firestoreEventMethods.restoreEvent(event.id);
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

  void _showRemovePermanentlyDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Event Permanently'),
          content: Text('Are you sure you want to permanently remove "${event.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Remove'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                String response = await firestoreEventMethods.removeEventPermanently(event.id);
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
        title: const Text('Trashed Events'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: firestoreEventMethods.getTrashedEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trashed events'));
          }

          List<Event> trashedEvents = snapshot.data!;

          return ListView.builder(
            itemCount: trashedEvents.length,
            itemBuilder: (context, index) {
              Event event = trashedEvents[index];
              return ListTile(
                title: Text(event.title),
                subtitle: Text('Deleted on: ${event.dateUpdated}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () => _showRestoreDialog(event),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () => _showRemovePermanentlyDialog(event),
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

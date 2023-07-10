import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/events.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreEventMethods {
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('events');

  // Add a new event to the 'events' collection
  Future<String> addEvent(
    String name,
    Uint8List image,
    String description,
    String createdBy,
    Uint8List document,
    String dateTime,
    List participants,
    String venue,
    String type,
    String status,
  ) async {
    String response = 'Some error occurred';

    try {
      String imageUrl = await StorageMethods()
          .uploadImageToStorage('images', image, true);

      String documentUrl = await StorageMethods()
      .uploadFileToStorage('documents', document);

      String eventId = const Uuid().v4();

      Event event = Event(
        name: name,
        image: imageUrl,
        description: description,
        createdBy: createdBy,
        document: documentUrl,
        participants: participants,
        venue: venue,
        dateTime: DateTime.parse(dateTime),
        type: type,
        status: status,
        updatedAt: DateTime.now(),
      );

      _eventsCollection.doc(eventId).set(event.toJson());

      response = 'Success';
    } on FirebaseException catch (err) {
      if (err.code == 'permission-denied') {
        response = 'Permission denied';
      }
      response = err.toString();
    }
    return response;
  }

  // Update specific event with new data
  Future<void> updateEvent(String eventId, Event event) async {
    await _eventsCollection.doc(eventId).update(event.toJson());
  }

  // Delete specific event
  Future<void> removeEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  // Get all events
  Stream<QuerySnapshot> getAllEvents() {
    return _eventsCollection.snapshots();
  }

}

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
    String eventName,
    Uint8List eventImage,
    String eventDescription,
    String createdBy,
    Uint8List eventDocument,
    String eventDate,
    String eventType,
    String status,
  ) async {
    String response = 'Some error occurred';

    try {
      String imageUrl = await StorageMethods()
          .uploadImageToStorage('images', eventImage, true);

      String documentUrl = await StorageMethods()
      .uploadFileToStorage('documents', eventDocument);

      String eventId = const Uuid().v4();

      Event event = Event(
        eventName: eventName,
        eventImage: imageUrl,
        eventDescription: eventDescription,
        createdBy: createdBy,
        eventDocument: documentUrl,
        eventDate: DateTime.parse(eventDate),
        eventType: eventType,
        status: status,
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
}

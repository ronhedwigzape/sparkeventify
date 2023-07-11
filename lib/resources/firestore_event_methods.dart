import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/events.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreEventMethods {
  // Reference to the 'events' collection in Firestore
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('events');

  // Method to add a new event to the 'events' collection
  Future<String> addEvent(
    String name,
    Uint8List image,
    String description,
    String createdBy,
    Uint8List document,
    DateTime dateTime,
    List participants,
    String venue,
    String type,
    String status,
  ) async {
    String response = 'Some error occurred';

    try {
      // Upload the image to storage and get the URL
      String imageUrl = await StorageMethods()
          .uploadImageToStorage('images', image, true);

      // Upload the document to storage and get the URL
      String documentUrl = await StorageMethods()
      .uploadFileToStorage('documents', document);

      // Generate a unique ID for the event
      String eventId = const Uuid().v4();

      // Create a new Event object
      Event event = Event(
        id: eventId,
        name: name,
        image: imageUrl,
        description: description,
        createdBy: createdBy,
        document: documentUrl,
        participants: participants,
        venue: venue,
        dateTime: dateTime,
        type: type,
        status: status,
        updatedAt: DateTime.now(),
      );

      // Add the event to the 'events' collection in Firestore
      _eventsCollection.doc(eventId).set(event.toJson());

      response = 'Success';
    } on FirebaseException catch (err) {
      // Handle any errors that occur
      if (err.code == 'permission-denied') {
        response = 'Permission denied';
      }
      response = err.toString();
    }
    return response;
  }

  Future<String> updateEvent(String eventId, Event event) async {
    String response = 'Some error occurred';

    try {
      // Update the event in the 'events' collection in Firestore
      await _eventsCollection.doc(eventId).update(event.toJson());

      response = 'Success';
    } on FirebaseException catch (err) {
      // Handle any errors that occur
      if (err.code == 'permission-denied') {
        response = 'Permission denied';
      }
      response = err.toString();
    }
    return response;
  }

  Future<String> removeEvent(String eventId) async {
    String response = 'Some error occurred';

    try {
      // Remove the event from the 'events' collection in Firestore
      await _eventsCollection.doc(eventId).delete();

      response = 'Success';
    } on FirebaseException catch (err) {
      // Handle any errors that occur
      if (err.code == 'permission-denied') {
        response = 'Permission denied';
      }
      response = err.toString();
    }
    return response;
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreEventMethods {
  // Reference to the 'events' collection in Firestore
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('events');

  // Method to add a new event to the 'events' collection
  Future<String> postEvent(
    String title,
    Uint8List? image,
    String description,
    String createdBy,
    Uint8List? document,
    DateTime startDate,
    DateTime endDate,
    DateTime startTime,
    DateTime endTime,
    Map<String, List<dynamic>> participants,
    String venue,
    String type,
    String status,
  ) async {
    String response = 'Some error occurred';
    try {
      // If the image is not null, upload it to storage and get the URL
      String imageUrl = '';
      if (image != null) {
         imageUrl = await StorageMethods().uploadImageToStorage('images', image, true);
      }
      // If the document is not null, upload it to storage and get the URL
      String documentUrl = '';
      if (document != null) {
         documentUrl = await StorageMethods().uploadFileToStorage('documents', document);
      }
      // Generate a unique ID for the event
      String eventId = const Uuid().v4();
      // Create a new Event object
      Event event = Event(
        id: eventId,
        title: title,
        image: imageUrl,
        description: description,
        createdBy: createdBy,
        document: documentUrl,
        participants: participants,
        venue: venue,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        type: type,
        status: status,
        datePublished: DateTime.now(),
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

  // Method that has a key of type event's DateTime and a value of type List<Event>
  Future<Map<DateTime, List<Event>>> getEventsByDate() async {
    Map<DateTime, List<Event>> events = {};
    QuerySnapshot snapshot = await _eventsCollection.get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        Event event = await Event.fromSnap(doc);

        DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
            .toLocal();
        DateTime endDate = DateTime(event.endDate.year, event.endDate.month, event.endDate.day, 23, 59, 59)
            .toLocal();

        for (var day = startDate; day.isBefore(endDate) || day.isAtSameMomentAs(endDate);
        day = day.add(const Duration(days: 1))) {
          DateTime adjustedDay = DateTime(day.year, day.month, day.day, 0, 0, 0)
              .toLocal();
          if (events.containsKey(adjustedDay)) {
            events[adjustedDay]!.add(event);
          } else {
            events[adjustedDay] = [event];
          }
        }
      }
    }
    return events;
  }


  // Method that gets event by event id
  Future<Event> getEventById(String eventId) async {
    // Reference the document in the 'events' collection with the specified id
    DocumentSnapshot doc = await _eventsCollection.doc(eventId).get();
    // Check if the document exists
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    // Convert the document snapshot to an Event object and return it
    return Event.fromSnap(doc);
  }

  Future<String> updateEventStatus(
      String eventId, 
      bool isCancelled, 
      bool isMoved, 
      DateTime startDate, 
      DateTime endDate, 
      Event? movedEvent  // if event is moved, new event details should be provided here
  ) async {
    String response = 'Some error occurred';
    DateTime currentDateTime = DateTime.now();

    try {
      // If the event is moved, update event's details using the supplied new event details
      if (isMoved && movedEvent != null) {
        return await updateEvent(eventId, movedEvent);
      }

      // If the current date/time is before the start date/time, then the status is "Upcoming"
      if (startDate.isAfter(currentDateTime)) {
        await _eventsCollection.doc(eventId).set({
            'status': isCancelled ? 'Cancelled' : 'Upcoming',
        }, SetOptions(merge: true));
      } 
      // If the current date/time is after the end date/time, then the status is "Past"
      else if (endDate.isBefore(currentDateTime)) {
        await _eventsCollection.doc(eventId).set({
            'status': isCancelled ? 'Cancelled' : 'Past',
        }, SetOptions(merge: true));
      } 
      // If the current date/time is between the start and end datetime, then the status is "Ongoing"
      else {
        await _eventsCollection.doc(eventId).set({
            'status': isCancelled ? 'Cancelled' : 'Ongoing',
        }, SetOptions(merge: true));
      }

      // Set response to 'Success' if the status is updated successfully
      response = 'Success';
    } on FirebaseException catch (err) {
        // Handle any errors that occur
        if (err.code == 'permission-denied') {
          response = 'Permission denied';
        }
        // Handle other errors
        response = err.toString();
    }
    // Return the response
    return response;
  }

}

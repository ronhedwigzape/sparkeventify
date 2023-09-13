import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStorePersonalEventMethods {
  // Reference to the 'personal_events' collection in Firestore
  final CollectionReference _personalEventsCollection = FirebaseFirestore.instance.collection('personalEvents');

  // Method to add a new event to the 'personal_events' collection
  Future<String> postPersonalEvent(
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
      PersonalEvent event = PersonalEvent(
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
        dateUpdated: DateTime.now(),
        datePublished: DateTime.now(),
      );
      // Add the event to the 'personal_events' collection in Firestore
      _personalEventsCollection.doc(eventId).set(event.toJson());

      await FireStorePersonalEventMethods().updatePersonalEventStatus(
        eventId, false, false, startDate, endDate, null);
        
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

  Future<String> updatePersonalEvent(String eventId, PersonalEvent event) async {
    String response = 'Some error occurred';

    try {
      // Update the event in the 'personal_events' collection in Firestore
      await _personalEventsCollection.doc(eventId).update(event.toJson());

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

  Future<String> removePersonalEvent(String eventId) async {
    String response = 'Some error occurred';

    try {
      // Remove the event from the 'personal_events' collection in Firestore
      await _personalEventsCollection.doc(eventId).delete();

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
  Future<Map<DateTime, List<PersonalEvent>>> getPersonalEventsByDate() async {
    // Initialize an empty map to store the personal_events.
    Map<DateTime, List<PersonalEvent>> personalEvents = {};

    // Get all documents from the personal_events collection.
    QuerySnapshot snapshot = await _personalEventsCollection.get();

    // Check if the snapshot contains any documents.
    if (snapshot.docs.isNotEmpty) {
      // Loop through each document in the snapshot.
      for (var doc in snapshot.docs) {
        // Convert the document snapshot to an Event object.
        PersonalEvent event = await PersonalEvent.fromSnap(doc);

        // Get the start and end dates of the event and adjust the time to the start and end of the day respectively.
        DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
            .toLocal();
        DateTime endDate = DateTime(event.endDate.year, event.endDate.month, event.endDate.day, 23, 59, 59)
            .toLocal();

        // Loop through each day between the start and end dates.
        for (var day = startDate; day.isBefore(endDate) || day.isAtSameMomentAs(endDate);
        day = day.add(const Duration(days: 1))) {
          // Adjust the time of the day to the start of the day.
          DateTime adjustedDay = DateTime(day.year, day.month, day.day, 0, 0, 0)
              .toLocal();

          // Check if the personal_events map already contains the adjusted day as a key.
          if (personalEvents.containsKey(adjustedDay)) {
            // If the key exists, add the event to the list of personal_events for that day.
            personalEvents[adjustedDay]!.add(event);
          } else {
            // If the key does not exist, create a new list with the event and add it to the map.
            personalEvents[adjustedDay] = [event];
          }
        }
      }
    }

    // Return the map of personal_events.
    return personalEvents;
  }


  // Method that gets event by event id
  Future<PersonalEvent> getPersonalEventById(String eventId) async {
    // Reference the document in the 'personal_events' collection with the specified id
    DocumentSnapshot doc = await _personalEventsCollection.doc(eventId).get();
    // Check if the document exists
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    // Convert the document snapshot to an Event object and return it
    return PersonalEvent.fromSnap(doc);
  }

  Future<String> updatePersonalEventStatus(
      String eventId, 
      bool? isCancelled, 
      bool? isMoved, 
      DateTime startDate, 
      DateTime endDate, 
      PersonalEvent? movedEvent  // if event is moved, new event details should be provided here
  ) async {
    String response = 'Some error occurred';
    DateTime currentDateTime = DateTime.now();

    try {
      // If the event is moved, update event's details using the supplied new event details
      if (isMoved! && movedEvent != null) {
        return await updatePersonalEvent(eventId, movedEvent);
      }

      // If the current date/time is before the start date/time, then the status is "Upcoming"
      if (startDate.isAfter(currentDateTime)) {
        await _personalEventsCollection.doc(eventId).set({
            'status': isCancelled! ? 'Cancelled' : 'Upcoming',
        }, SetOptions(merge: true));
      } 
      // If the current date/time is after the end date/time, then the status is "Past"
      else if (endDate.isBefore(currentDateTime)) {
        await _personalEventsCollection.doc(eventId).set({
            'status': isCancelled! ? 'Cancelled' : 'Past',
        }, SetOptions(merge: true));
      } 
      // If the current date/time is between the start and end datetime, then the status is "Ongoing"
      else {
        await _personalEventsCollection.doc(eventId).set({
            'status': isCancelled! ? 'Cancelled' : 'Ongoing',
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

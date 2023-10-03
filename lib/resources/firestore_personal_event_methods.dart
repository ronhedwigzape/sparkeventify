import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
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
    String venue,
    String type,
    String status,
    bool isEdited
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
        venue: venue,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        type: type,
        status: status,
        dateUpdated: DateTime.now(),
        datePublished: DateTime.now(),
        isEdited: isEdited
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

  // Method to get all personal events
  Stream<List<PersonalEvent>> getPersonalEvents() {
    return _personalEventsCollection.snapshots().asyncMap((snapshot) async {
      return await Future.wait(snapshot.docs.map((doc) async => await PersonalEvent.fromSnap(doc)).toList());
    });
  }

  // Method that has a key of type event's DateTime and a value of type List<Event>
  Future<Map<DateTime, List<PersonalEvent>>> getPersonalEventsByDate() async {
    Map<DateTime, List<PersonalEvent>> personalEvents = {};

    QuerySnapshot snapshot = await _personalEventsCollection.get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        PersonalEvent event = await PersonalEvent.fromSnap(doc);

        DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
            .toLocal();
        DateTime endDate = DateTime(event.endDate.year, event.endDate.month, event.endDate.day, 23, 59, 59)
            .toLocal();

        for (var day = startDate; day.isBefore(endDate) || day.isAtSameMomentAs(endDate);
        day = day.add(const Duration(days: 1))) {
          DateTime adjustedDay = DateTime(day.year, day.month, day.day, 0, 0, 0)
              .toLocal();

          if (personalEvents.containsKey(adjustedDay)) {
            personalEvents[adjustedDay]!.add(event);
          } else {
            personalEvents[adjustedDay] = [event];
          }
        }
      }
    }
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

  Stream<model.User> getUserDetailsByEventsCreatedBy(String createdBy) {
    return Stream.fromFuture(getUserByEventsCreatedBy(createdBy));
  }

  Future<model.User> getUserByEventsCreatedBy(String createdBy) async {
    // Query the events collection for events created by the user
    QuerySnapshot eventQuerySnapshot = await FirebaseFirestore.instance
        .collection('personalEvents')
        .where('createdBy', isEqualTo: createdBy)
        .get();
    // If no events were found, return null
    if (eventQuerySnapshot.docs.isEmpty) {
      throw Exception('No personal events found created by user $createdBy');
    }
    // Get the first event document
    DocumentSnapshot eventDocument = eventQuerySnapshot.docs.first;
    // Get the 'createdBy' field from the event document
    String userId = eventDocument['createdBy'];
    // Query the users collection for the user with the obtained 'createdBy' (userId)
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // If no user was found, return null
    if (!userSnapshot.exists) {
      throw Exception('No user found with id $userId');
    }
    // Create a User object from the document snapshot
    model.User user = model.User.fromSnap(userSnapshot);
    // Return the User object
    return user;
  }

}

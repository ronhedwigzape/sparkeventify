import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:uuid/uuid.dart';

class FireStoreEventMethods {
  // Reference to the 'events' collection in Firestore
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('events');
  final FirebaseNotificationService _firebaseNotificationService = FirebaseNotificationService();

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
      // Check for conflicting events
      QuerySnapshot querySnapshot = await _eventsCollection
          .where('startDate', isEqualTo: startDate)
          .where('endDate', isEqualTo: endDate)
          .where('venue', isEqualTo: venue)
          .get();
          
      for (var doc in querySnapshot.docs) {
        Event existingEvent = await Event.fromSnap(doc);
        if (existingEvent.startTime.isAtSameMomentAs(startTime) &&
            existingEvent.endTime.isAtSameMomentAs(endTime)) {
          return 'Conflicting event exists';
        }
      }

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
        dateUpdated: DateTime.now(),
        datePublished: DateTime.now(),
      );
      // Add the event to the 'events' collection in Firestore
      _eventsCollection.doc(eventId).set(event.toJson());

      await FireStoreEventMethods().updateEventStatus(
        eventId, false, false, startDate, endDate, startTime, endTime);
        
      response = 'Success';

      String senderId = FirebaseAuth.instance.currentUser!.uid;

      // Send a notification to all participants
      if (participants['department'] != null && participants['program'] != null) {
        for (var department in participants['department']!) {
          for (var program in participants['program']!) {
            await _firebaseNotificationService.sendNotificationToUsersInDepartmentAndProgram(
              senderId, 
              department, 
              program, 
              'New Event', 
              'A new event "$title" has been posted. It will start on ${DateFormat('yyyy-MM-dd').format(startDate)} at ${DateFormat('h:mm a').format(startTime)} and end on ${DateFormat('yyyy-MM-dd').format(endDate)} at ${DateFormat('h:mm a').format(endTime)}. Description: $description. Venue: $venue.'
            );
          }
        }
      }
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
      await StorageMethods().deleteImageFromStorage('images/$eventId');
      await StorageMethods().deleteFileFromStorage('documents/$eventId');

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
  Stream<Map<DateTime, List<Event>>> getEventsByDate() {
    // Return a stream from the events collection.
    return _eventsCollection.snapshots().asyncMap((snapshot) async {
      // Initialize an empty map to store the events.
      Map<DateTime, List<Event>> events = {};

      // Check if the snapshot contains any documents.
      if (snapshot.docs.isNotEmpty) {
        // Loop through each document in the snapshot.
        for (var doc in snapshot.docs) {
          // Convert the document snapshot to an Event object.
          Event event = await Event.fromSnap(doc);

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

            // Check if the events map already contains the adjusted day as a key.
            if (events.containsKey(adjustedDay)) {
              // If the key exists, add the event to the list of events for that day.
              events[adjustedDay]!.add(event);
            } else {
              // If the key does not exist, create a new list with the event and add it to the map.
              events[adjustedDay] = [event];
            }
          }
        }
      }
      // Return the map of events.
      return events;
    });
  }

  Stream<Map<DateTime, List<Event>>> getEventsByDateByDepartment(String department) {
    // Return a stream from the events collection.
    return _eventsCollection.snapshots().asyncMap((snapshot) async {
      // Initialize an empty map to store the events.
      Map<DateTime, List<Event>> events = {};

      // Check if the snapshot contains any documents.
      if (snapshot.docs.isNotEmpty) {
        // Loop through each document in the snapshot.
        for (var doc in snapshot.docs) {
          // Convert the document snapshot to an Event object.
          Event event = await Event.fromSnap(doc);

          // Check if the event's department matches the provided department.
          if (event.participants != null && event.participants!['department'].contains(department)) {
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

              // Check if the events map already contains the adjusted day as a key.
              if (events.containsKey(adjustedDay)) {
                // If the key exists, add the event to the list of events for that day.
                events[adjustedDay]!.add(event);
              } else {
                // If the key does not exist, create a new list with the event and add it to the map.
                events[adjustedDay] = [event];
              }
            }
          }
        }
      }
      // Return the map of events.
      return events;
      
    });
  }

  Stream<Map<DateTime, List<Event>>> getEventsByDateByDepartmentByProgram(String department, String program) {
    // Return a stream from the events collection.
    return _eventsCollection.snapshots().asyncMap((snapshot) async {
      // Initialize an empty map to store the events.
      Map<DateTime, List<Event>> events = {};

      // Check if the snapshot contains any documents.
      if (snapshot.docs.isNotEmpty) {
        // Loop through each document in the snapshot.
        for (var doc in snapshot.docs) {
          // Convert the document snapshot to an Event object.
          Event event = await Event.fromSnap(doc);

          // Check if the event's department and program matches the provided department and program.
          if (event.participants != null && event.participants!['department'].contains(department) && event.participants!['program'].contains(program)) {
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

              // Check if the events map already contains the adjusted day as a key.
              if (events.containsKey(adjustedDay)) {
                // If the key exists, add the event to the list of events for that day.
                events[adjustedDay]!.add(event);
              } else {
                // If the key does not exist, create a new list with the event and add it to the map.
                events[adjustedDay] = [event];
              }
            }
          }
        }
      }
      // Return the map of events.
      return events;
    });
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
    bool? isCancelled,
    bool? isMoved,
    DateTime startDate,
    DateTime endDate,
    DateTime startTime,
    DateTime endTime,
  ) async {
    String response = 'Some error occurred';
    DateTime currentDateTime = DateTime.now();

    // Combine date and time
    DateTime startDateTime = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
    DateTime endDateTime = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);

    // Check if isCancelled and isMoved are not null before using them
    isCancelled = isCancelled ?? false;
    isMoved = isMoved ?? false;

    try {
      if (isMoved) {
        await _eventsCollection.doc(eventId).set({
          'status': 'Moved',
        }, SetOptions(merge: true));
        return 'Success';
      }

      if (startDateTime.isAfter(currentDateTime)) {
        await _eventsCollection.doc(eventId).set({
          'status': isCancelled ? 'Cancelled' : 'Upcoming',
        }, SetOptions(merge: true));
      } else if (endDateTime.isBefore(currentDateTime)) {
        await _eventsCollection.doc(eventId).set({
          'status': isCancelled ? 'Cancelled' : 'Past',
        }, SetOptions(merge: true));
      } else {
        await _eventsCollection.doc(eventId).set({
          'status': isCancelled ? 'Cancelled' : 'Ongoing',
        }, SetOptions(merge: true));
      }

      response = 'Success';
    } on FirebaseException catch (err) {
      if (err.code == 'permission-denied') {
        response = 'Permission denied';
      } else {
        response = err.toString();
      }
    }

    return response;
  }

  Stream<String> updateEventStatusByStream(
    String eventId,
    bool? isCancelled,
    bool? isMoved,
    DateTime startDate,
    DateTime endDate,
    DateTime startTime,
    DateTime endTime,
  ) async* {
    DateTime currentDateTime = DateTime.now();

    // Combine date and time
    DateTime startDateTime = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
    DateTime endDateTime = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);

    // Check if isCancelled and isMoved are not null before using them
    isCancelled = isCancelled ?? false;
    isMoved = isMoved ?? false;

    try {
      if (isMoved) {
        await _eventsCollection.doc(eventId).set({
          'status': 'Moved',
        }, SetOptions(merge: true));
        yield 'Moved';
      }

      if (startDateTime.isAfter(currentDateTime)) {
        await _eventsCollection.doc(eventId).set({
          'status': isCancelled ? 'Cancelled' : 'Upcoming',
        }, SetOptions(merge: true));
        yield isCancelled ? 'Cancelled' : 'Upcoming';
      } else if (endDateTime.isBefore(currentDateTime)) {
        await _eventsCollection.doc(eventId).set({
          'status': isCancelled ? 'Cancelled' : 'Past',
        }, SetOptions(merge: true));
        yield isCancelled ? 'Cancelled' : 'Past';
      } else {
        await _eventsCollection.doc(eventId).set({
          'status': isCancelled ? 'Cancelled' : 'Ongoing',
        }, SetOptions(merge: true));
        yield isCancelled ? 'Cancelled' : 'Ongoing';
      }
    } on FirebaseException catch (err) {
      if (err.code == 'permission-denied') {
        yield 'Permission denied';
      } else {
        yield err.toString();
      }
    }
  }

}

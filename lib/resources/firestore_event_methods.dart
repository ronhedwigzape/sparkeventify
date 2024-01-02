import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
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
    String userType,
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
        approvalStatus: (userType == 'Admin' || userType == 'Staff') ? 'approved' : 'pending', // Set approvalStatus based on userType
      );
      // Add the event to the 'events' collection in Firestore
      _eventsCollection.doc(eventId).set(event.toJson());

      await FireStoreEventMethods().updateEventStatus(
        eventId, false, false, startDate, endDate, startTime, endTime);

      // Fetch the officer who created the event
      model.User officer = await FireStoreUserMethods().getUserById(createdBy);

      // If the user is an officer, send a notification to admin/staff
      if (userType == 'Officer') {
        // Fetch all users
        List<model.User> users = await FirebaseNotificationService().fetchAllUsers();
        for (var user in users) {
          // If the user is an admin or staff, send them a notification
          if (user.userType == 'Admin' || user.userType == 'Staff') {
            await FirebaseNotificationService().sendNotificationToUser(
              createdBy, // senderId
              user.uid!, // userId
              'New Event Pending Approval', // title
              'A new event "$title" has been posted by ${officer.profile!.fullName}, ${officer.profile!.officerPosition}, ${officer.profile!.organization} and is pending your approval.' // body
            );
          }
        }
      } 

      // If the user is an administrator or staff, send a notification to all participants
      if (userType == 'Admin' || userType == 'Staff') {
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
      }

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

  // Method to update event details from Firebase Firestore
  Future<String> updateEvent(String eventId, Event event, String userType) async {
    String response = 'Some error occurred';

    try {
      // Fetch the details of the officer who created the event
      model.User officer = await FireStoreUserMethods().getUserById(event.createdBy);

      // If the user is an officer, make the event pending again
      if (userType == 'Officer') {

        // Update the event
        await _eventsCollection.doc(eventId).update(event.toJson());

        // Make the event pending again
        await _eventsCollection.doc(eventId).update({
          'approvalStatus': 'pending',
        });

        // Notify admin/staff about the pending update
        List<model.User> users = await FirebaseNotificationService().fetchAllUsers();
        for (var user in users) {
          if (user.userType == 'Admin' || user.userType == 'Staff') {
            await FirebaseNotificationService().sendNotificationToUser(
              officer.uid!, // senderId
              user.uid!, // userId
              'Event Update Pending Approval', // title
              'An update to the event "${event.title}" has been posted by ${officer.profile!.fullName}, ${officer.profile!.officerPosition}, ${officer.profile!.organization} and is pending your approval.' // body
            );
          }
        }
      } else {
        // If the user is an admin or staff, update the event directly
        await _eventsCollection.doc(eventId).update(event.toJson());
      }

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


  // Method to removes the specified event
  Future<String> removeEvent(String eventId) async {
    String response = 'Some error occurred';

    try {
      // Reference to the event document in Firestore
      DocumentReference eventDocRef = _eventsCollection.doc(eventId);

      // Fetch the event details
      DocumentSnapshot doc = await eventDocRef.get();
      Event event = await Event.fromSnap(doc);

      // Reference to the 'feedbacks' subcollection
      CollectionReference feedbackSubcollection = eventDocRef.collection('feedbacks');

      // Query all documents in the 'feedback' subcollection
      QuerySnapshot querySnapshot = await feedbackSubcollection.get();

      // Delete all documents in the 'feedback' subcollection
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Remove the event from the 'events' collection in Firestore
      await eventDocRef.delete();
      await StorageMethods().deleteImageFromStorage('images/$eventId');
      await StorageMethods().deleteFileFromStorage('documents/$eventId');

      // Send a notification to all participants
      if (event.participants != null) {
        for (var department in event.participants!['department']!) {
          for (var program in event.participants!['program']!) {
            await _firebaseNotificationService.sendNotificationToUsersInDepartmentAndProgram(
              event.createdBy, 
              department, 
              program, 
              'Event Removed', 
              'The event "${event.title}" has been removed.'
            );
          }
        }
      }

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

  // Method to get all events of users(event participants) in real-time by event date
  Stream<Map<DateTime, List<Event>>> getEventsByDate() {
    // Return a stream from the events collection.
    return _eventsCollection.where('approvalStatus', isEqualTo: 'approved').snapshots().asyncMap((snapshot) async {
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

  // Method to get all events of users(event participants) in real-time that have the specified department by event date
  Stream<Map<DateTime, List<Event>>> getEventsByDateByDepartment(String department) {
    // Return a stream from the events collection.
    return _eventsCollection.where('approvalStatus', isEqualTo: 'approved').snapshots().asyncMap((snapshot) async {
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

  // Method to get all events of users(event participants) in real-time that have the specified department and program by event date
  Stream<Map<DateTime, List<Event>>> getEventsByDateByDepartmentByProgram(String department, String program) {
    // Return a stream from the events collection.
    return _eventsCollection.where('approvalStatus', isEqualTo: 'approved').snapshots().asyncMap((snapshot) async {
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

  // Method to handle automatic update for event's status
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

  // Method to handle realtime updates for updating events
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

  // Method to make approval or rejection for the specified event
  Future<bool> approveOrRejectEvent(String eventId, bool approve) async {
    try {
      DocumentSnapshot doc = await _eventsCollection.doc(eventId).get();
      Event event = await Event.fromSnap(doc);

      // Fetch the details of the officer who created the event
      model.User officer = await FireStoreUserMethods().getUserById(event.createdBy);

      // If the event is rejected, remove the event
      if (!approve) {
        await removeEvent(eventId);
      } else {
        // If the event is approved, send notifications to participants
        // Fetch current user's details
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        model.User currentUser = await FireStoreUserMethods().getUserById(currentUserId);

        String? approvedByPosition = currentUser.userType;
        if (currentUser.userType == 'Staff') {
          approvedByPosition = '${currentUser.profile!.staffType}, ${currentUser.profile!.staffPosition}, ${currentUser.profile!.staffDescription}';
        }

        await _eventsCollection.doc(eventId).update({
          'approvalStatus': 'approved',
          'approvedBy': currentUser.profile!.fullName,
          'approvedByPosition': approvedByPosition,
        });

        // Send a notification to the officer who created the event
        FirebaseNotificationService().sendNotificationToUser(
          currentUser.uid!, // senderId
          officer.uid!, // userId
          'Event Approved', // title
          'Your event "${event.title}" has been approved by ${currentUser.profile!.fullName}, $approvedByPosition.', // body
        );

        // Check if the event has been updated
        if (event.dateUpdated!.isAfter(event.datePublished!)) {
          // If the event has been updated, send a different notification to participants
          if (event.participants != null) {
            for (var department in event.participants!['department']!) {
              for (var program in event.participants!['program']!) {
                await _firebaseNotificationService.sendNotificationToUsersInDepartmentAndProgram(
                  event.createdBy, 
                  department, 
                  program, 
                  'Event Updated', 
                  'The event "${event.title}" has been updated. It will start on ${DateFormat('yyyy-MM-dd').format(event.startDate)} at ${DateFormat('h:mm a').format(event.startTime)} and end on ${DateFormat('yyyy-MM-dd').format(event.endDate)} at ${DateFormat('h:mm a').format(event.endTime)}. Description: ${event.description}. Venue: ${event.venue}.'
                );
              }
            }
          }

          // Send a notification to the officer who updated the event
          FirebaseNotificationService().sendNotificationToUser(
            currentUser.uid!, // senderId
            officer.uid!, // userId
            'Updated Event Approved', // title
            'Your updated event "${event.title}" has been approved by ${currentUser.profile!.fullName}, $approvedByPosition.', // body
          );
        } else {
          // If the event has not been updated, send the original notification to participants
          if (event.participants != null) {
            for (var department in event.participants!['department']!) {
              for (var program in event.participants!['program']!) {
                await _firebaseNotificationService.sendNotificationToUsersInDepartmentAndProgram(
                  event.createdBy, 
                  department, 
                  program, 
                  'New Event', 
                  'A new event "${event.title}" has been posted. It will start on ${DateFormat('yyyy-MM-dd').format(event.startDate)} at ${DateFormat('h:mm a').format(event.startTime)} and end on ${DateFormat('yyyy-MM-dd').format(event.endDate)} at ${DateFormat('h:mm a').format(event.endTime)}. Description: ${event.description}. Venue: ${event.venue}.'
                );
              }
            }
          }
        }
      }

      return true;
    } on FirebaseException catch (err) {
      // Handle any errors that occur
      print(err.toString());
      return false;
    }
  }

  Stream<List<Event>> getApprovedEvents() {
  return FirebaseFirestore.instance
    .collection('events')
    .where('approvalStatus', isEqualTo: 'approved')
    .orderBy('datePublished', descending: true)
    .snapshots()
    .map((QuerySnapshot query) {
      return query.docs.map((doc) => Event.fromSnapStream(doc)).toList();
    });
  }

  Stream<List<Event>> getPendingEvents() {
  return FirebaseFirestore.instance
    .collection('events')
    .where('approvalStatus', isEqualTo: 'pending')
    .orderBy('datePublished', descending: true)
    .snapshots()
    .map((QuerySnapshot query) {
      return query.docs.map((doc) => Event.fromSnapStream(doc)).toList();
    });
  }

  // Function to get all pending events by date
  Stream<Map<DateTime, List<Event>>> getPendingEventsByDate() {
    return _eventsCollection
        .where('approvalStatus', isEqualTo: 'pending')
        .orderBy('datePublished', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      Map<DateTime, List<Event>> events = {};

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Event event = await Event.fromSnap(doc);
          DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
              .toLocal();
          if (events.containsKey(startDate)) {
            events[startDate]!.add(event);
          } else {
            events[startDate] = [event];
          }
        }
      }

      return events;
    });
  }

  // Function to get all rejected events by date
  Stream<Map<DateTime, List<Event>>> getRejectedEventsByDate() {
    return _eventsCollection
        .where('approvalStatus', isEqualTo: 'rejected')
        .orderBy('datePublished', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      Map<DateTime, List<Event>> events = {};

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Event event = await Event.fromSnap(doc);
          DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
              .toLocal();
          if (events.containsKey(startDate)) {
            events[startDate]!.add(event);
          } else {
            events[startDate] = [event];
          }
        }
      }

      return events;
    });
  }

  // Function to get all pending events by date for a specific department and program
  Stream<Map<DateTime, List<Event>>> getPendingEventsByDateByDepartmentByProgram(String department, String program) {
    return _eventsCollection
        .where('approvalStatus', isEqualTo: 'pending')
        .where('participants.department', arrayContains: department)
        .where('participants.program', arrayContains: program)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      Map<DateTime, List<Event>> events = {};

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Event event = await Event.fromSnap(doc);
          DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
              .toLocal();
          if (events.containsKey(startDate)) {
            events[startDate]!.add(event);
          } else {
            events[startDate] = [event];
          }
        }
      }

      return events;
    });
  }

  // Function to get all rejected events by date for a specific department and program
  Stream<Map<DateTime, List<Event>>> getRejectedEventsByDateByDepartmentByProgram(String department, String program) {
    return _eventsCollection
        .where('approvalStatus', isEqualTo: 'rejected')
        .where('participants.department', arrayContains: department)
        .where('participants.program', arrayContains: program)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      Map<DateTime, List<Event>> events = {};

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Event event = await Event.fromSnap(doc);
          DateTime startDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day, 0, 0, 0)
              .toLocal();
          if (events.containsKey(startDate)) {
            events[startDate]!.add(event);
          } else {
            events[startDate] = [event];
          }
        }
      }

      return events;
    });
  }

  // Function to get the count of all pending events
  Stream<int> getPendingEventsCount() {
    return _eventsCollection
        .where('approvalStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Function to get the count of all rejected events
  Stream<int> getRejectedEventsCount() {
    return _eventsCollection
        .where('approvalStatus', isEqualTo: 'rejected')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }


}

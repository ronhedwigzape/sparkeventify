import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/evaluator_feedback.dart';
import 'package:student_event_calendar/models/event_feedbacks.dart';
import 'package:uuid/uuid.dart';
import 'package:student_event_calendar/models/event.dart' as model;

// Reference to the 'events' collection in Firestore
final FirebaseFirestore _db = FirebaseFirestore.instance;
CollectionReference _eventRef = _db.collection('events');
StreamSubscription<DocumentSnapshot>? _eventStreamSubscription;

class FirestoreFeedbackMethods {
  // Method to get eventFeedbackUid by eventId

  Stream<String?> streamGetEventFeedbackUid(String eventId) async* {
    final controller = StreamController<String?>();

    _eventRef.doc(eventId)
      .collection('feedbacks')
      .get()
      .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var data = snapshot.docs.first.data();
          controller.add(data['eventFeedbackUid']);
        } else {
          controller.add(null);
        }
        controller.close();
      })
      .catchError((error) {
        controller.addError(error);
        return null;  // Return null instead of void
      });

    yield* controller.stream;
  }

  Future<String?> getEventFeedbackUid(String eventId) async {
    QuerySnapshot snapshot =
        await _eventRef.doc(eventId).collection('feedbacks').get();
    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['eventFeedbackUid'];
    } else {
      return null;
    }
  }

  // Method to add a feedback to a specific event
  Future<String> addEmptyFeedback(String eventId) async {
    var uuid = const Uuid();
    String feedbackId = uuid.v4();

    await _eventRef.doc(eventId)
      .collection('feedbacks')
      .doc(feedbackId)
      .set({
        'eventFeedbackUid': feedbackId,
        'evaluatorFeedbacks': []
      });

    // Update hasFeedback field in the event document
    await _eventRef.doc(eventId).update({'hasFeedback': true});

    return feedbackId;
  }

  // Method to add evaluation to the feedback
  Future<void> addEvaluatorFeedback(String eventId, String feedbackId, EvaluatorFeedback evaluatorFeedback) {
    return _eventRef.doc(eventId)
      .collection('feedbacks')
      .doc(feedbackId)
      .update({ 
        'evaluatorFeedbacks': FieldValue.arrayUnion([evaluatorFeedback.toJson()])
      });
  }

  // Method to update evaluator's feedback basing from current user's id
  Future<void> updateEvaluatorsFeedbackByUserId(String eventId, String userId, EvaluatorFeedback updatedEvaluatorFeedback) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);
    for (var feedback in allFeedbacks) {
      feedback.evaluatorFeedbacks = feedback.evaluatorFeedbacks.map((evaluatorFeedback) {
        if (evaluatorFeedback.userUid == userId) {
          return updatedEvaluatorFeedback;
        } else {
          return evaluatorFeedback;
        }
      }).toList();
      _eventRef.doc(eventId).collection('feedbacks').doc(feedback.eventFeedbackUid).update(feedback.toJson());
    }
  }

  // Method to get all feedbacks from a specific event
  Future<List<EventFeedbacks>> getAllFeedbacks(String eventId) async {
    QuerySnapshot snapshot = await _eventRef.doc(eventId).collection('feedbacks').get();
    return snapshot.docs.map((doc) => EventFeedbacks.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Stream<List<EventFeedbacks>> streamAllFeedbacks(String eventId) {
    return _eventRef.doc(eventId).collection('feedbacks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventFeedbacks.fromMap(doc.data())).toList();
    });
  }

  // Method to get all evaluator's feedback from a specific event feedback
  Future<List<EvaluatorFeedback>> getAllEvaluatorsFeedback(String eventId, String feedbackId) async {
    DocumentSnapshot snapshot = await _eventRef.doc(eventId).collection('feedbacks').doc(feedbackId).get();
    EventFeedbacks eventFeedbacks = EventFeedbacks.fromMap(snapshot.data() as Map<String, dynamic>);
    return eventFeedbacks.evaluatorFeedbacks;
  }

  // Method to get all evaluator's feedback that is same from the current user's id - returns array of evaluator's feedback
  Future<List<EvaluatorFeedback>> getEvaluatorsFeedbackByUserId(String eventId, String userId) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);
    List<EvaluatorFeedback> userFeedbacks = [];
    for (var feedback in allFeedbacks) {
      userFeedbacks.addAll(feedback.evaluatorFeedbacks
        .where((evaluatorFeedback) => evaluatorFeedback.userUid == userId));
    }
    return userFeedbacks;
  }

  Stream<bool> getEventFeedbackStatusByUserId(String eventId, String userId) {
    return _eventRef
        .doc(eventId)
        .collection('feedbacks')
        .snapshots()
        .map((snapshot) {
      bool isFeedbackDone = false;

      for (var doc in snapshot.docs) {
        EventFeedbacks feedback =
            EventFeedbacks.fromMap(doc.data());
        for (var evaluatorFeedback in feedback.evaluatorFeedbacks) {
          if (evaluatorFeedback.userUid == userId) {
            isFeedbackDone = evaluatorFeedback.isFeedbackDone!;
            break; // Break the loop if the user's feedback is found
          }
        }
      }

      return isFeedbackDone;
    });
  }

  // Method to unlock the feedback for a specific user
  Future<void> unlockEvaluatorEventFeedbackByUserId(
    String eventId,
    String userId,
  ) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);

    for (var feedback in allFeedbacks) {
      feedback.evaluatorFeedbacks =
          feedback.evaluatorFeedbacks.map((evaluatorFeedback) {
        if (evaluatorFeedback.userUid == userId) {
          evaluatorFeedback.isFeedbackDone = false;
        }
        return evaluatorFeedback;
      }).toList();

      await _eventRef
          .doc(eventId)
          .collection('feedbacks')
          .doc(feedback.eventFeedbackUid)
          .update(feedback.toJson());
    }
  }

  // Method to unlock all feedback for a specific event
  Future<void> unlockAllFeedbacksInEvent(String eventId) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);

    for (var feedback in allFeedbacks) {
      feedback.evaluatorFeedbacks =
          feedback.evaluatorFeedbacks.map((evaluatorFeedback) {
        evaluatorFeedback.isFeedbackDone = false;
        return evaluatorFeedback;
      }).toList();

      await _eventRef
          .doc(eventId)
          .collection('feedbacks')
          .doc(feedback.eventFeedbackUid)
          .update(feedback.toJson());
    }
  }

  // Method to remove evaluator's feedback basing from current user's id
  Future<void> removeEvaluatorsFeedbackByUserId(String eventId, String userId) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);
    for (var feedback in allFeedbacks) {
      feedback.evaluatorFeedbacks.removeWhere(
          (evaluatorFeedback) => evaluatorFeedback.userUid == userId);
      _eventRef
          .doc(eventId)
          .collection('feedbacks')
          .doc(feedback.eventFeedbackUid)
          .update(feedback.toJson());
    }
  }

  // Method to remove a specific event feedback
  Future<void> removeFeedback(String eventId, String feedbackId) {
    return _eventRef
        .doc(eventId)
        .collection('feedbacks')
        .doc(feedbackId)
        .delete();
  }

  // Method to remove all event feedbacks
  Future<void> removeAllEventFeedbacks(String eventId) async {
    QuerySnapshot snapshot =
      await _eventRef.doc(eventId).collection('feedbacks').get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      doc.reference.delete();
    }

    // Update hasFeedback field in the event document
    await _eventRef.doc(eventId).update({'hasFeedback': false});
  }

  Stream<Map<DateTime, List<model.Event>>> getEventsWithFeedbackByDate() {
    // Get all documents from the events collection where 'hasFeedback' is true.
    return _eventRef.where('hasFeedback', isEqualTo: true).snapshots().asyncMap((snapshot) async {
      // Initialize an empty map to store the events.
      Map<DateTime, List<model.Event>> events = {};

      // Check if the snapshot contains any documents.
      if (snapshot.docs.isNotEmpty) {
        // Loop through each document in the snapshot.
        for (var doc in snapshot.docs) {
          // Convert the document snapshot to an Event object.
          model.Event event = await model.Event.fromSnap(doc);

          // Get the start and end dates of the event and adjust the time to the start and end of the day respectively.
          DateTime startDate = DateTime(event.startDate!.year, event.startDate!.month, event.startDate!.day, 0, 0, 0)
              .toLocal();
          DateTime endDate = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day, 23, 59, 59)
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

    Stream<Map<DateTime, List<model.Event>>> getEventsWithFeedbackByDateByDepartment(String department) {
    // Get all documents from the events collection where 'hasFeedback' is true.
    return _eventRef.where('hasFeedback', isEqualTo: true).snapshots().asyncMap((snapshot) async {
      // Initialize an empty map to store the events.
      Map<DateTime, List<model.Event>> events = {};

      // Check if the snapshot contains any documents.
      if (snapshot.docs.isNotEmpty) {
        // Loop through each document in the snapshot.
        for (var doc in snapshot.docs) {
          // Convert the document snapshot to an Event object.
          model.Event event = await model.Event.fromSnap(doc);

          // Check if the event's department matches the provided department.
          if (event.participants != null && event.participants!['department'].contains(department)) {
            // Get the start and end dates of the event and adjust the time to the start and end of the day respectively.
            DateTime startDate = DateTime(event.startDate!.year, event.startDate!.month, event.startDate!.day, 0, 0, 0)
                .toLocal();
            DateTime endDate = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day, 23, 59, 59)
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

  Future<Map<String, dynamic>> getEventFeedbackSummary(String eventId) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);

    int totalEvaluators =  0;
    Map<int, int> satisfactionCounts = Map.fromIterable(List.generate(6, (i) => i), value: (_) =>  0);
    Map<String, int> programs = {};
    Map<String, int> departments = {};

    for (var feedback in allFeedbacks) {
      for (var evaluatorFeedback in feedback.evaluatorFeedbacks) {
        totalEvaluators++;

        // Increment the count for the corresponding satisfaction status
        int satisfactionStatus = evaluatorFeedback.satisfactionStatus ??  0;
        satisfactionCounts[satisfactionStatus] = satisfactionCounts[satisfactionStatus]! +  1;

        // Count programs
        if (programs.containsKey(evaluatorFeedback.userProgram)) {
          programs[evaluatorFeedback.userProgram!] = programs[evaluatorFeedback.userProgram]! +  1;
        } else {
          programs[evaluatorFeedback.userProgram!] =  1;
        }

        // Count departments
        if (departments.containsKey(evaluatorFeedback.userDepartment)) {
          departments[evaluatorFeedback.userDepartment!] = departments[evaluatorFeedback.userDepartment]! +  1;
        } else {
          departments[evaluatorFeedback.userDepartment!] =  1;
        }
      }
    }

    return {
      'totalEvaluators': totalEvaluators,
      'satisfactionCounts': satisfactionCounts,
      'programs': programs,
      'departments': departments,
    };
  }

  Future<Map<String, Map<String, Map<String, bool>>>> getAttendanceForStudentsByProgramAndDepartment(String eventId) async {
    // Initialize a map to hold the attendance status for each student, grouped by program and department
    Map<String, Map<String, Map<String, bool>>> studentAttendance = {};

    // Retrieve all feedbacks for the event
    QuerySnapshot feedbackSnapshot = await _eventRef.doc(eventId).collection('feedbacks').get();

    // Process each feedback to collect attendance status for students
    for (var feedbackDoc in feedbackSnapshot.docs) {
      EventFeedbacks feedback = EventFeedbacks.fromMap(feedbackDoc.data() as Map<String, dynamic>);
      for (var evaluatorFeedback in feedback.evaluatorFeedbacks) {
        // Use the program and department from the evaluator feedback to group the attendance status
        String program = evaluatorFeedback.userProgram!;
        String department = evaluatorFeedback.userDepartment!;

        // Ensure the program and department groups exist in the map
        studentAttendance.putIfAbsent(program, () => <String, Map<String, bool>>{});
        studentAttendance[program]!.putIfAbsent(department, () => <String, bool>{});

        // Record the attendance status for the student
        studentAttendance[program]![department]![evaluatorFeedback.userUid!] = evaluatorFeedback.attendanceStatus!;
      }
    }

    return studentAttendance;
  }


  Stream<List<model.Event>> getEventsWithoutFeedback() async* {
    var controller = StreamController<List<model.Event>>();
    FirebaseFirestore.instance
        .collection('events')
        .where('hasFeedback', isEqualTo: false)
        .snapshots()
        .listen((snapshot) async {
      List<model.Event> events = [];
      for (var doc in snapshot.docs) {
        model.Event event = await model.Event.fromSnap(doc);
        events.add(event);
      }
      controller.add(events);
    });

    yield* controller.stream;
  }

  void toggleEventFeedbackStream(String eventId) {
    _eventStreamSubscription = _eventRef.doc(eventId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        bool currentHasFeedback = data['hasFeedback'] ?? false;
        _eventRef.doc(eventId).update({'hasFeedback': !currentHasFeedback});
      }
    });
  }

  void stopEventStream() {
    _eventStreamSubscription?.cancel();
  }

}

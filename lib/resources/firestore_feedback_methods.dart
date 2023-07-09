import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/feedbacks.dart';
import 'package:uuid/uuid.dart';

final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('events');

class FirestoreFeedbackMethods {
  // Feedbacks are assumed to be a separate collection within the 'events' collection
  // Add new feedback to an event
  Future<void> addFeedback(String eventId, Feedbacks feedback) async {
    var uuid = const Uuid();
    String feedbackId = uuid.v4();
    await _eventsCollection.doc(eventId).collection('feedbacks').doc(feedbackId).set(feedback.toJson());
  }

  // Update a specific feedback of a specific event
  Future<void> updateFeedback(String eventId, String feedbackId, Feedbacks feedback) async {
    await _eventsCollection
        .doc(eventId)
        .collection('feedbacks')
        .doc(feedbackId)
        .update(feedback.toJson());
  }

  // Delete a specific feedback of a specific event
  Future<void> removeFeedback(String eventId, String feedbackId) async {
    await _eventsCollection
        .doc(eventId)
        .collection('feedbacks')
        .doc(feedbackId)
        .delete();
  }
}

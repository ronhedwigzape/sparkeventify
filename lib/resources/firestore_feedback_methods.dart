import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/feedbacks.dart';
import 'package:uuid/uuid.dart';

// Reference to the 'events' collection in Firestore
final CollectionReference _eventsCollection =
    FirebaseFirestore.instance.collection('events');

class FirestoreFeedbackMethods {
  // Method to add a feedback to a specific event
  Future<void> addFeedback(String eventId, Feedbacks feedback) async {
    var uuid = const Uuid();
    String feedbackId = uuid.v4();
    await _eventsCollection
        .doc(eventId)
        .collection('feedbacks')
        .doc(feedbackId)
        .set(feedback.toJson());
  }

  // Method to update a specific feedback of a specific event
  Future<void> updateFeedback(
      String eventId, String feedbackId, Feedbacks feedback) async {
    await _eventsCollection
        .doc(eventId)
        .collection('feedbacks')
        .doc(feedbackId)
        .update(feedback.toJson());
  }

  // Method to delete a specific feedback of a specific event
  Future<void> removeFeedback(String eventId, String feedbackId) async {
    await _eventsCollection
        .doc(eventId)
        .collection('feedbacks')
        .doc(feedbackId)
        .delete();
  }
}

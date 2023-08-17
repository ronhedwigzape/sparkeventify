import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/evaluator.dart';
import 'package:uuid/uuid.dart';

// Reference to the 'events' collection in Firestore
final FirebaseFirestore _db = FirebaseFirestore.instance;
CollectionReference _eventRef = _db.collection('events');

class FirestoreFeedbackMethods {

  // Method to add a feedback to a specific event
  Future<void> addEmptyFeedback(String eventId) {
    var uuid = const Uuid();
    String feedbackId = uuid.v4();

    return _eventRef.doc(eventId).collection('feedbacks').doc(feedbackId).set({
      'feedbackUid': feedbackId,
      'evaluators': []
    });
  }

  // Method to add evaluation to the feedback
  Future<void> addEvaluatorFeedback(String eventId, String feedbackId, Evaluator evaluator) {
    return _eventRef.doc(eventId)
      .collection('feedbacks').doc(feedbackId)
      .update({'evaluators': FieldValue.arrayUnion([evaluator.toJson()])});
  }

  // Method to update evaluator's feedback
  Future<void> updateEvaluatorFeedback(String eventId, String feedbackId, Evaluator oldEvaluator, Evaluator newEvaluator) async {
    await _eventRef.doc(eventId)
      .collection('feedbacks').doc(feedbackId)
      .update({'evaluators': FieldValue.arrayRemove([oldEvaluator.toJson()])});
    await _eventRef.doc(eventId)
      .collection('feedbacks').doc(feedbackId)
      .update({'evaluators': FieldValue.arrayUnion([newEvaluator.toJson()])});
  }

  // Method to remove evaluator's feedback
  Future<void> removeEvaluatorFeedback(String eventId, String feedbackId, Evaluator evaluator) {
    return _eventRef.doc(eventId)
      .collection('feedbacks').doc(feedbackId)
      .update({'evaluators': FieldValue.arrayRemove([evaluator.toJson()])});
  }

  // Method to remove feedback
  Future<void> removeFeedback(String eventId, String feedbackId) {
    return _eventRef.doc(eventId).collection('feedbacks').doc(feedbackId).delete();
  }

}

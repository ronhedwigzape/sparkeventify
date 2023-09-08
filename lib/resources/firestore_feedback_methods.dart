import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/evaluator_feedback.dart';
import 'package:student_event_calendar/models/event_feedbacks.dart';
import 'package:uuid/uuid.dart';

// Reference to the 'events' collection in Firestore
final FirebaseFirestore _db = FirebaseFirestore.instance;
CollectionReference _eventRef = _db.collection('events');

class FirestoreFeedbackMethods {

  // Method to add a feedback to a specific event
  Future<void> addEmptyFeedback(String eventId) {
    var uuid = const Uuid();
    String feedbackId = uuid.v4();

    return _eventRef.doc(eventId)
      .collection('feedbacks')
      .doc(feedbackId)
      .set({
        'eventFeedbackUid': feedbackId,
        'evaluatorFeedbacks': []
      });
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
      userFeedbacks.addAll(feedback.evaluatorFeedbacks.where((evaluatorFeedback) => evaluatorFeedback.userUid == userId));
    }
    return userFeedbacks;
  }

  // Method to remove evaluator's feedback basing from current user's id
  Future<void> removeEvaluatorsFeedbackByUserId(String eventId, String userId) async {
    List<EventFeedbacks> allFeedbacks = await getAllFeedbacks(eventId);
    for (var feedback in allFeedbacks) {
      feedback.evaluatorFeedbacks.removeWhere((evaluatorFeedback) => evaluatorFeedback.userUid == userId);
      _eventRef.doc(eventId).collection('feedbacks').doc(feedback.eventFeedbackUid).update(feedback.toJson());
    }
  }

  // Method to remove event feedback
  Future<void> removeFeedback(String eventId, String feedbackId) {
    return _eventRef.doc(eventId)
      .collection('feedbacks')
      .doc(feedbackId)
      .delete();
  }

  // Method to remove all event feedbacks
  Future<void> removeAllEventFeedbacks(String eventId) async {
    QuerySnapshot snapshot = await _eventRef.doc(eventId).collection('feedbacks').get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      doc.reference.delete();
    }
  }


}

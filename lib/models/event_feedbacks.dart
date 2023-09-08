import 'package:student_event_calendar/models/evaluator_feedback.dart';

class EventFeedbacks {
  String eventFeedbackUid;
  List<EvaluatorFeedback> evaluatorFeedbacks;

  EventFeedbacks({
    required this.eventFeedbackUid,
    required this.evaluatorFeedbacks,
  });

  // Convert Feedbacks object to JSON
  Map<String, dynamic> toJson() => {
    'eventFeedbackUid': eventFeedbackUid,
    'evaluatorFeedbacks': evaluatorFeedbacks.map((e) => e.toJson()).toList(),
  };

  // Create Feedbacks object from a map
  static EventFeedbacks fromMap(Map<String, dynamic> map) {
    return EventFeedbacks(
      eventFeedbackUid: map['eventFeedbackUid'],
      evaluatorFeedbacks: (map['evaluatorFeedbacks'] as List).map((e) => EvaluatorFeedback.fromMap(e)).toList(),
    );
  }
}
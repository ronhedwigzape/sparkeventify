import 'package:student_event_calendar/models/evaluator.dart';

class Feedbacks {
  String feedbackUid;
  List<Evaluator> evaluators;

  Feedbacks({
    required this.feedbackUid,
    required this.evaluators,
  });

  // Convert Feedbacks object to JSON
  Map<String, dynamic> toJson() => {
    'feedbackUid': feedbackUid,
    'evaluators': evaluators.map((e) => e.toJson()).toList(),
  };

  // Create Feedbacks object from a map
  static Feedbacks fromMap(Map<String, dynamic> map) {
    return Feedbacks(
      feedbackUid: map['feedbackUid'],
      evaluators: (map['evaluators'] as List).map((e) => Evaluator.fromMap(e)).toList(),
    );
  }
}
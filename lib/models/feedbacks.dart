import 'package:student_event_calendar/models/evaluators.dart';

class Feedbacks {
  final String? feedbackDocument;
  final String? feedbackLink;
  final List<Evaluators>? evaluators;

  Feedbacks({
    this.feedbackDocument,
    this.feedbackLink,
    this.evaluators,
  });
    Map<String, dynamic> toJson() => {
        'feedbackDocument': feedbackDocument,
        'feedbackLink': feedbackLink,
        'evaluators': evaluators?.map((e) => e.toJson()).toList(),
  };

  static Feedbacks fromMap(Map<String, dynamic> map) {
    // Map evaluators as list of Evaluators objects
    List<Evaluators> evaluatorsList = (map['evaluators'] as List).map((evaluator) {
      return Evaluators.fromMap(evaluator);
    }).toList();
    
    return Feedbacks(
      feedbackDocument: map['feedbackDocument'],
      feedbackLink: map['feedbackLink'],
      evaluators: evaluatorsList,
    );
  }
}

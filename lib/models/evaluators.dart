class Evaluators {
  final String? uid;
  final String? feedbackMessage;

  Evaluators({
    this.uid,
    this.feedbackMessage,
  });

  // Convert Evaluators object to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'feedbackMessage': feedbackMessage,
      };

  // Create Evaluators object from a map
  static Evaluators fromMap(Map<String, dynamic> map) {
    return Evaluators(
      uid: map['uid'],
      feedbackMessage: map['feedbackMessage'],
    );
  }
}

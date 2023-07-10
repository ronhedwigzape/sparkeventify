class Evaluators {
  final String? uid;
  final String? feedbackMessage;

  Evaluators({
    this.uid,
    this.feedbackMessage,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'feedbackMessage': feedbackMessage,
  };

  static Evaluators fromMap(Map<String, dynamic> map) {
    return Evaluators(
      uid: map['uid'],
      feedbackMessage: map['feedbackMessage'],
    );
  }
}

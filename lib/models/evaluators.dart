class Evaluators {
  final String? userId;
  final String? feedbackMessage;

  Evaluators({
    this.userId,
    this.feedbackMessage,
  });

    Map<String, dynamic> toJson() => {
        'userId': userId,
        'feedbackMessage': feedbackMessage,
  };

  static Evaluators fromMap(Map<String, dynamic> map) {
    return Evaluators(
      userId: map['userId'],
      feedbackMessage: map['feedbackMessage'],
    );
  }
}

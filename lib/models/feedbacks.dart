class Feedbacks {
  final String? feedbackDocument;
  final String? feedbackLink;

  Feedbacks({
    this.feedbackDocument,
    this.feedbackLink,
  });

  Map<String, dynamic> toJson() => {
    'feedbackDocument': feedbackDocument,
    'feedbackLink': feedbackLink,
  };

  static Feedbacks fromMap(Map<String, dynamic> map) {
    return Feedbacks(
      feedbackDocument: map['feedbackDocument'],
      feedbackLink: map['feedbackLink'],
    );
  }
}

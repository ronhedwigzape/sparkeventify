class Feedbacks {
  final String? feedbackDocument;
  final String? feedbackLink;

  Feedbacks({
    this.feedbackDocument,
    this.feedbackLink,
  });

  // Convert Feedbacks object to JSON
  Map<String, dynamic> toJson() => {
        'feedbackDocument': feedbackDocument,
        'feedbackLink': feedbackLink,
      };

  // Create Feedbacks object from a map
  static Feedbacks fromMap(Map<String, dynamic> map) {
    return Feedbacks(
      feedbackDocument: map['feedbackDocument'],
      feedbackLink: map['feedbackLink'],
    );
  }
}

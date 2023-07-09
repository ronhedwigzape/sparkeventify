import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/feedbacks.dart';

class Event {
  final String eventName;
  final DateTime eventDate;
  final String eventDescription;
  final String createdBy;
  final String? eventImage;
  final String eventDocument;
  final List<dynamic>? attendees;
  final String eventType;
  final String status;
  final Feedbacks? feedbacks;

  const Event({
    required this.eventName,
    required this.eventDate,
    required this.eventDescription,
    required this.createdBy,
    this.eventImage,
    required this.eventDocument,
    this.attendees,
    required this.eventType,
    required this.status,
    this.feedbacks,
  });

  Map<String, dynamic> toJson() => {
        'eventName': eventName,
        'eventDate': eventDate,
        'eventDescription': eventDescription,
        'createdBy': createdBy,
        'eventImage': eventImage,
        'eventDocument': eventDocument,
        'attendees': attendees,
        'eventType': eventType,
        'status': status,
        'feedbacks': feedbacks?.toJson(),
      };

  static Future<Event> fromSnap(DocumentSnapshot snap) async {
    var snapshot = snap.data() as Map<String, dynamic>;
    var feedbacksSnap = snapshot['feedbacks'] as Map<String, dynamic>;
    return Event(
      eventName: snapshot['eventName'],
      eventDate: (snapshot['eventDate'] as Timestamp).toDate(),
      eventDescription: snapshot['eventDescription'],
      createdBy: snapshot['createdBy'],
      eventImage: snapshot['eventImage'],
      eventDocument: snapshot['eventDocument'],
      attendees: snapshot['attendees'],
      eventType: snapshot['eventType'],
      status: snapshot['status'],
      feedbacks: Feedbacks.fromMap(feedbacksSnap),
    );
  }
}

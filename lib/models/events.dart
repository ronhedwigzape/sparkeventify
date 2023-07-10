import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String name;
  final DateTime date;
  final String description;
  final String createdBy;
  final String? image;
  final String document;
  final List<dynamic>? attendees;
  final String? venue;
  final String type;
  final String status;

  Event({
    required this.name,
    required this.date,
    required this.description,
    required this.createdBy,
    this.image,
    required this.document,
    this.attendees,
    this.venue,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date,
    'description': description,
    'createdBy': createdBy,
    'image': image,
    'document': document,
    'attendees': attendees,
    'venue': venue,
    'type': type,
    'status': status,
  };

  static Future<Event> fromSnap(DocumentSnapshot snap) async {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Event(
      name: snapshot['name'],
      date: (snapshot['date'] as Timestamp).toDate(),
      description: snapshot['description'],
      createdBy: snapshot['createdBy'],
      image: snapshot['image'],
      document: snapshot['document'],
      attendees: snapshot['attendees'],
      venue: snapshot['venue'],
      type: snapshot['type'],
      status: snapshot['status'],
    );
  }
}

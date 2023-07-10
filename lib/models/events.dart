import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String name;
  final DateTime dateTime;
  final String description;
  final String createdBy;
  final String? image;
  final String document;
  final List<dynamic>? participants;
  final String? venue;
  final String type;
  final String status;
  DateTime updatedAt;

  Event({
    required this.name,
    required this.dateTime,
    required this.description,
    required this.createdBy,
    this.image,
    required this.document,
    this.participants,
    this.venue,
    required this.type,
    required this.status,
    required this.updatedAt, 
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dateTime': dateTime,
        'description': description,
        'createdBy': createdBy,
        'image': image,
        'document': document,
        'participants': participants,
        'venue': venue,
        'type': type,
        'status': status,
        'updatedAt': updatedAt,
      };

  static Future<Event> fromSnap(DocumentSnapshot snap) async {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Event(
      name: snapshot['name'],
      dateTime: (snapshot['dateTime'] as Timestamp).toDate(),
      description: snapshot['description'],
      createdBy: snapshot['createdBy'],
      image: snapshot['image'],
      document: snapshot['document'],
      participants: snapshot['participants'],
      venue: snapshot['venue'],
      type: snapshot['type'],
      status: snapshot['status'],
      updatedAt: (snapshot['updatedAt'] as Timestamp).toDate(), 
    );
  }
}

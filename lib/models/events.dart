import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  DateTime dateTime;
  String description;
  String createdBy;
  String? image;
  String document;
  List<dynamic>? participants;
  String? venue;
  String type;
  String status;
  DateTime updatedAt;

  Event({
    required this.id, 
    required this.title,
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

  // Convert Event object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
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

  // Create Event object from DocumentSnapshot
  static Future<Event> fromSnap(DocumentSnapshot snap) async {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Event(
      id: snapshot['id'],
      title: snapshot['title'],
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

  // @override
  // String toString() {
  //   return 'Event{id: $id, title: $title, dateTime: $dateTime, description: $description, createdBy: $createdBy, image: $image, document: $document, participants: $participants, venue: $venue, type: $type, status: $status, updatedAt: $updatedAt}';
  // }
}

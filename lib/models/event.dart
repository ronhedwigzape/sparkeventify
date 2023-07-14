import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  DateTime date; 
  DateTime time;
  String description;
  String createdBy;
  String? image;
  String? document;
  List<dynamic>? participants;
  String? venue;
  String type;
  String status;
  DateTime? datePublished;

  Event({
    required this.id, 
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.createdBy,
    this.image,
    this.document,
    this.participants,
    this.venue,
    required this.type,
    required this.status,
    this.datePublished,
  });

  // Convert Event object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'time': time,
        'description': description,
        'createdBy': createdBy,
        'image': image,
        'document': document,
        'participants': participants,
        'venue': venue,
        'type': type,
        'status': status,
        'datePublished': datePublished,
      };

  // Create Event object from DocumentSnapshot
  static Future<Event> fromSnap(DocumentSnapshot snap) async {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Event(
      id: snapshot['id'],
      title: snapshot['title'],
      date: (snapshot['date'] as Timestamp).toDate().toLocal(),
      time: (snapshot['time'] as Timestamp).toDate().toLocal(),
      description: snapshot['description'],
      createdBy: snapshot['createdBy'],
      image: snapshot['image'],
      document: snapshot['document'],
      participants: snapshot['participants'],
      venue: snapshot['venue'],
      type: snapshot['type'],
      status: snapshot['status'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate().toUtc()
    );
  }

  // @override
  // String toString() {
  //   return 'Event{id: $id, title: $title, date: $date, time: $time, description: $description, createdBy: $createdBy, image: $image, document: $document, participants: $participants, venue: $venue, type: $type, status: $status, updatedAt: $updatedAt}';
  // }
}

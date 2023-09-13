import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalEvent {
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  DateTime startTime;
  DateTime endTime;
  String description;
  String createdBy;
  String? image;
  String? document;
  Map<String, dynamic>? participants;
  String? venue;
  String type;
  String status;
  DateTime? datePublished;

  PersonalEvent({
    required this.id, 
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
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
        'startDate': startDate,
        'endDate': endDate,
        'startTime': startTime,
        'endTime': endTime,
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
  static Future<PersonalEvent> fromSnap(DocumentSnapshot snap) async {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PersonalEvent(
      id: snapshot['id'],
      title: snapshot['title'],
      startDate: (snapshot['startDate'] as Timestamp).toDate().toLocal(),
      endDate: (snapshot['endDate'] as Timestamp).toDate().toLocal(),
      startTime: (snapshot['startTime'] as Timestamp).toDate().toLocal(),
      endTime: (snapshot['endTime'] as Timestamp).toDate().toLocal(),
      description: snapshot['description'],
      createdBy: snapshot['createdBy'],
      image: snapshot['image'],
      document: snapshot['document'],
      participants: Map<String, List<dynamic>>.from(snapshot['participants']),
      venue: snapshot['venue'],
      type: snapshot['type'],
      status: snapshot['status'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate().toUtc()
    );
  }

}

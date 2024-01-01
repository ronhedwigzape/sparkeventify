import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
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
  DateTime? dateUpdated;
  DateTime? datePublished;
  bool? hasFeedback;
  String approvalStatus;
  Map<String, dynamic>? pendingUpdate;
  String? approvedBy;
  String? approvedByPosition;

  Event({
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
    this.dateUpdated,
    this.datePublished,
    this.hasFeedback = false,
    this.approvalStatus = 'pending',
    this.pendingUpdate,
    this.approvedBy,
    this.approvedByPosition,
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
    'dateUpdated': dateUpdated,
    'datePublished': datePublished,
    'hasFeedback': hasFeedback,
    'approvalStatus': approvalStatus,
    'pendingUpdate': pendingUpdate,
    'approvedBy': approvedBy,
    'approvedByPosition': approvedByPosition,
  };

  // Create Event object from a map
  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      startDate: (json['startDate'] as Timestamp).toDate().toLocal(),
      endDate: (json['endDate'] as Timestamp).toDate().toLocal(),
      startTime: (json['startTime'] as Timestamp).toDate().toLocal(),
      endTime: (json['endTime'] as Timestamp).toDate().toLocal(),
      description: json['description'],
      createdBy: json['createdBy'],
      image: json['image'],
      document: json['document'],
      participants: Map<String, List<dynamic>>.from(json['participants']),
      venue: json['venue'],
      type: json['type'],
      status: json['status'],
      hasFeedback: json['hasFeedback'],
      dateUpdated: (json['dateUpdated'] as Timestamp).toDate().toUtc(),
      datePublished: (json['datePublished'] as Timestamp).toDate().toUtc(),
      approvalStatus: json['approvalStatus'],
      pendingUpdate: json['pendingUpdate'],
      approvedBy: json['approvedBy'],
      approvedByPosition: json['approvedByPosition'],
    );
  }

  // Create Event object from DocumentSnapshot
  static Event fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Event(
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
      hasFeedback: snapshot['hasFeedback'],
      dateUpdated: (snapshot['dateUpdated'] as Timestamp).toDate().toUtc(),
      datePublished: (snapshot['datePublished'] as Timestamp).toDate().toUtc(),
      approvalStatus: snapshot['approvalStatus'],
      pendingUpdate: snapshot['pendingUpdate'],
      approvedBy: snapshot['approvedBy'],
      approvedByPosition: snapshot['approvedByPosition'],
    );
  }

  static Event fromSnapStream(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Event(
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
      hasFeedback: snapshot['hasFeedback'],
      dateUpdated: (snapshot['dateUpdated'] as Timestamp).toDate().toUtc(),
      datePublished: (snapshot['datePublished'] as Timestamp).toDate().toUtc(),
      approvalStatus: snapshot['approvalStatus'],
      pendingUpdate: snapshot['pendingUpdate'],
      approvedBy: snapshot['approvedBy'],
      approvedByPosition: snapshot['approvedByPosition'],
    );
  }
}

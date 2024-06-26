import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String? id;
  String? title;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startTime;
  DateTime? endTime;
  String? description;
  String? createdBy;
  String? image;
  String? document;
  Map<String, dynamic>? participants;
  String? venue;
  String? type;
  String? status;
  DateTime? dateUpdated;
  DateTime? datePublished;
  bool? hasFeedback;
  String approvalStatus;
  String? approvedBy;
  String? approvedByPosition;
  String? organizationInvolved;

  Event({
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.description,
    this.createdBy,
    this.image,
    this.document,
    this.participants,
    this.venue,
    this.type,
    this.status,
    this.dateUpdated,
    this.datePublished,
    this.hasFeedback = false,
    this.approvalStatus = 'pending',
    this.approvedBy = "",
    this.approvedByPosition = "",
    this.organizationInvolved = "",
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
    'approvedBy': approvedBy,
    'approvedByPosition': approvedByPosition,
    'organizationInvolved': organizationInvolved,
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
      approvedBy: json['approvedBy'],
      approvedByPosition: json['approvedByPosition'],
      organizationInvolved: json['organizationInvolved'],
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
      approvedBy: snapshot['approvedBy'],
      approvedByPosition: snapshot['approvedByPosition'],
      organizationInvolved: snapshot['organizationInvolved'],
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
      approvedBy: snapshot['approvedBy'],
      approvedByPosition: snapshot['approvedByPosition'],
      organizationInvolved: snapshot['organizationInvolved'],
    );
  }
}

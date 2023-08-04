import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/user.dart' as model;

class Notification {
  String? id;
  String? title;
  String? message;
  DocumentReference<Object?>? sender;
  DocumentReference<Object?>? recipient;
  Timestamp? timestamp;
  bool? read;
  model.User? senderData; 
  model.User? recipientData;

  // Named constructor
  Notification({
    this.id,
    this.title,
    this.message,
    this.sender,
    this.recipient,
    this.timestamp,
    this.read,
    this.senderData,
    this.recipientData,
  });

  // Convert Notification object to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'sender': sender,
    'recipient': recipient,
    'timestamp': timestamp,
    'read': read,
  };

  // Create Notification object from DocumentSnapshot
  static Notification fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Notification(
      id: data['id'],
      title: data['title'],
      message: data['message'],
      sender: data['sender'],
      recipient: data['recipient'],
      timestamp: data['timestamp'],
      read: data['read'],
    );
  }
}

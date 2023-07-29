import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String? id;
  String? title;
  String? message;
  DocumentReference? sender;
  DocumentReference? recipient;
  Timestamp? timestamp;
  bool? read;

  // Named constructor
  Notification({
    this.id,
    this.title,
    this.message,
    this.sender,
    this.recipient,
    this.timestamp,
    this.read,
  });

  // Convert Notification object to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
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
      message: data['message'],
      sender: data['sender'],
      recipient: data['recipient'],
      timestamp: data['timestamp'],
      read: data['read'],
    );
  }
}

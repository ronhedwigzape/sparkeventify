import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_event_calendar/models/user.dart' as model;

class FireStoreUserMethods {
  // Reference to the 'users' collection in Firestore
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.User?> getCurrentUserData() async {
    model.User? user;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final documentSnapshot = await _usersCollection.doc(currentUser.uid).get();

    if (documentSnapshot.exists) {
      // Convert DocumentSnapshot to User
      user = model.User.fromSnap(documentSnapshot);
    }
    return user;
  }

  Future<void> updateCurrentUserData(model.User user) async {
    await _usersCollection.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  Future<model.User> getUserDetailsByEventsCreatedBy(String createdBy) async {
  // Query the events collection for events created by the user
  QuerySnapshot eventQuerySnapshot = await FirebaseFirestore.instance
      .collection('events')
      .where('createdBy', isEqualTo: createdBy)
      .get();

  // If no events were found, return null
  if (eventQuerySnapshot.docs.isEmpty) {
    throw Exception('No events found created by user $createdBy');
  }

  // Get the first event document
  DocumentSnapshot eventDocument = eventQuerySnapshot.docs.first;

  // Get the 'createdBy' field from the event document
  String userId = eventDocument['createdBy'];

  // Query the users collection for the user with the obtained 'createdBy' (userId)
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  // If no user was found, return null
  if (!userSnapshot.exists) {
    throw Exception('No user found with id $userId');
  }

  // Create a User object from the document snapshot
  model.User user = model.User.fromSnap(userSnapshot);

  // Return the User object
  return user;
}


}

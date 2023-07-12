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


}

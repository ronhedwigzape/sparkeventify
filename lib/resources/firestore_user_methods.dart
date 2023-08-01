import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';

class FireStoreUserMethods {
  // Reference to the 'users' collection in Firestore
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;

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
    await _usersCollection
        .doc(user.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Stream<model.User> getUserDetailsByEventsCreatedBy(String createdBy) {
    return Stream.fromFuture(getUserByEventsCreatedBy(createdBy));
  }

  Future<model.User> getUserByEventsCreatedBy(String createdBy) async {
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
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // If no user was found, return null
    if (!userSnapshot.exists) {
      throw Exception('No user found with id $userId');
    }
    // Create a User object from the document snapshot
    model.User user = model.User.fromSnap(userSnapshot);
    // Return the User object
    return user;
  }

  Future<void> deleteUser(String uid) async {
    try {
      final HttpsCallable callable = functions.httpsCallable('deleteUser');
      await callable.call(<String, dynamic>{'uid': uid});
      if (kDebugMode) {
        print('User deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e}');
      }
    }
  }

  Future<void> updateProfileImage(Uint8List? file, String currentUserUid) async {      
    
    String downloadUrl = '';
    if (file != null) {
      downloadUrl = await StorageMethods()
          .uploadImageToStorage('profileImages', file, false);
    }

    // Get a reference to the user's document in Firestore
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    // Update the profileImage field in the user's document
    return userDocRef.update({
      'profile.profileImage': downloadUrl,
    });
  }
}

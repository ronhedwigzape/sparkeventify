import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;

class AuthMethods {
  // Initialize Firebase Auth and Firebase Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  // Get current user uid
  Future<String> getCurrentUserUid() async {
    User currentUser = _auth.currentUser!;
    return currentUser.uid;
  }

  // Get current user type
  Future<String> getCurrentUserType() async {
    final User currentUser = _auth.currentUser!;
    final DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return (snap.data() as Map<String, dynamic>)['userType'];
  }

  // Sign up user (Admin, Student, SASO Staff, Organization Officer)
  Future<String> signUp(
      {required String email,
      required String password,
      String? username,
      required String userType,
      model.Profile? profile}) async {
    String res = "Enter valid credentials";

    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          userType.isNotEmpty &&
          profile != null &&
          profile.fullName!.isNotEmpty &&
          profile.phoneNumber!.isNotEmpty) {
        // Create user in Firebase Auth
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // Create user object for storing credentials in Firebase Firestore
        model.User user = model.User(
            uid: credential.user!.uid,
            email: email,
            username: username,
            userType: userType,
            profile: profile,
            password: password);
        // Set user details in Firebase Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());
        // Return success response if the user is successfully created in the database
        res = "Success";
      } else {
        res = "Please complete all required* fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted.';
      } else if (err.code == 'weak-password') {
        res = 'The password must be 6 characters long or more.';
      } else if (err.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else {
        // Return error response if the fields are empty
        res = err.message!;
      }
    }
    return res;
  }

  // Sign in user (Admin, Student, SASO Staff, Organization Officer)
  Future<String> signIn({required String email, required String password}) async {
    String response = "Enter valid credentials";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // Sign in with Firebase Authentication
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        // Return success response if the user is successfully signed in
        response = "Success";
      } else {
        // Return error response if the fields are empty
        response = "Please enter email and password";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        response = 'No user found for that email.';
      } else if (err.code == 'wrong-password') {
        response = 'Wrong password provided for that user.';
      } else {
        // Return error response if the email and password is empty
        response = err.message!;
      }
    }
    return response;
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

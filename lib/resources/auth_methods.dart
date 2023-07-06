import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<String> getUserType() async {
      User currentUser = _auth.currentUser!;
      DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
      return (snap.data() as Map<String, dynamic>)['userType'];
  }

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      required String userType,
      model.Profile? profile}) async {
    String res = "Enter valid credentials";

    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && userType.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        if (kDebugMode) {
          print(credential.user!.uid);
        }

        model.User user = model.User(
          uid: credential.user!.uid,
          email: email,
          username: username,
          userType: userType,
          profile: profile,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());

        res = "Success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted.';
      } else if (err.code == 'weak-password') {
        res = 'The password must be 6 characters long or more.';
      } else if (err.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else {
        res = err.message!;
      }
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Enter valid credentials";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        UserCredential credential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (kDebugMode) {
          print(credential.user!.uid);
        }
        res = "Success";
      } else {
        res = "Please enter email and password";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (err.code == 'wrong-password') {
        res = 'Wrong password provided for that user.';
      } else {
        res = err.message!;
      }
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

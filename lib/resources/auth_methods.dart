import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/services/firebase_notifications.dart';

class AuthMethods {
  // Initialize Firebase Auth and Firebase Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Get current user details
  Future<model.User> getCurrentUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  // Get current user type
  Future<String> getCurrentUserType() async {
    final User currentUser = _auth.currentUser!;
    final DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return (snap.data() as Map<String, dynamic>)['userType'];
  }

  // Sign up user (Admin, Student, SASO Staff, Organization Officer)
  Future<String> signUp({
    required String email,
    required String password,
    String? username,
    required String userType,
    model.Profile? profile
  }) async {
    String res = "Enter valid credentials";
    Map<String, String>? deviceTokens = {};
    try {
      // Check if all necessary information provided
      if (email.isNotEmpty && password.isNotEmpty && userType.isNotEmpty && profile != null) {
        // Create user in Firebase Auth
        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        // Create user object for storing credentials in Firebase Firestore
        model.User user = model.User(
          uid: credential.user!.uid,
          email: email,
          username: username,
          userType: userType,
          profile: profile,
          password: password,
          deviceTokens: deviceTokens,
        );
        // Set user details in Firebase Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());
        // Set devicetoken in Firestore for mobile devices 
        if (!kIsWeb) {
          // ######### CODE FOR ADDING DEVICE REGISTRATION #########
          // Get Firebase messaging token for this device
          var token = await _firebaseMessaging.getToken();
          // Call the registerDevice method with user's uid and token in mobile device
          if (token != null) {
            await FirebaseNotifications().registerDevice(credential.user!.uid, token);
          }
          // ######################################################
        } 
        // Return success response
        res = "Success";
      } 
    } catch (err) {
      // Handle different error types from FirebaseAuth
      if (err is FirebaseAuthException) {  
        if (err.code == 'invalid-email') {
          res = 'The email is badly formatted.';
        } else if (err.code == 'weak-password') {
          res = 'The password must be 6 characters long or more.';
        } else if (err.code == 'email-already-in-use') {
          res = 'The account already exists for that email.';
        }
      } else {
        res = err.toString();
      }
    }
    return res;
  }


  // Sign in user (Admin, Student, SASO Staff, Organization Officer)
  Future<String> signIn({required String email, required String password}) async {
    // Initialize values
    String response = "Enter valid credentials";
    Map<String, String>? deviceTokens = {};
    try {
      // Check if email and password is not empty
      if (email.isNotEmpty || password.isNotEmpty) {
        // Sign in with Firebase Authentication
        UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        // Initialize deviceToken with empty map
        await _firestore.collection('users').doc(credential.user!.uid).update({'deviceTokens': deviceTokens});
        // Set devicetoken in Firestore for mobile devices
        if(!kIsWeb) {
          // ######### CODE FOR ADDING DEVICE REGISTRATION #########
          // Get Firebase messaging token for this device
          var token = await _firebaseMessaging.getToken();
          // Call the registerDevice method with user's uid and token in mobile device
          if (token != null && !kIsWeb) {
            await FirebaseNotifications().registerDevice(credential.user!.uid, token);
          }
          // ########################################################    
        }
        // Return success response
        response = "Success";
      } 
    } catch (err) {
      // Handle different error types from FirebaseAuth
      if (err is FirebaseAuthException) {  
        if (err.code == 'user-not-found') {
          response = 'No user found for that email.';
        } else if (err.code == 'wrong-password') {
          response = 'Wrong password provided for that user.';
        }
      } else {
        response = err.toString();
      }
    }
    return response;
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

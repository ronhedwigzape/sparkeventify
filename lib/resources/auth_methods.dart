import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/services/firebase_notifications.dart';

class AuthMethods {
  // Initialize Firebase Auth and Firebase Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user details
  Future<model.User?> getCurrentUserDetails() async {
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

  Future<bool> isOfficerPositionTaken(String officerPosition, String organization) async {
    final QuerySnapshot snapshot = await _firestore.collection('users')
      .where('profile.officerPosition', isEqualTo: officerPosition)
      .where('profile.organization', isEqualTo: organization)
      .get();

    // If there are documents, the position is taken
    return snapshot.docs.isNotEmpty;
  }

  bool _isStrongPassword(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'\d'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[\W_]'));
    return password.length >= 6 && hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
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
        // Check cspc email format based on userType
        if ((userType == 'Admin' || userType == 'Staff') && !email.endsWith('@cspc.edu.ph')) {
          return 'Invalid email format. Please use an email ending with @cspc.edu.ph';
        } else if ((userType == 'Student' || userType == 'Officer') && !email.endsWith('@my.cspc.edu.ph')) {
          return 'Invalid email format. Please use an email ending with @my.cspc.edu.ph';
        }

        // Additional condition to check for unique officer position in an organization
        if (userType == 'Officer' && profile.officerPosition != null && profile.organization != null) {
          bool positionTaken = await isOfficerPositionTaken(profile.officerPosition!, profile.organization!);
          if (positionTaken) {
            return 'The officer position "${profile.officerPosition}" is already taken in "${profile.organization}".';
          }
        }

        // Password strength validation
        if (!_isStrongPassword(password)) {
          return 'Password must be at least 6 characters long and include uppercase, lowercase letters, numbers, and symbols.';
        }

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
        
          // ######### CODE FOR ADDING DEVICE REGISTRATION #########
          // Get Firebase messaging token for this device
          var token = await _firebaseMessaging.getToken();
          // Call the registerDevice method with user's uid and token in mobile device
          if (token != null) {
            await FirebaseNotificationService().registerDevice(credential.user!.uid, token);
          }
          // ######################################################
        
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
      
          // ######### CODE FOR ADDING DEVICE REGISTRATION #########
          // Get Firebase messaging token for this device
          var token = await _firebaseMessaging.getToken();
          // Call the registerDevice method with user's uid and token in mobile device
          if (token != null) {
            await FirebaseNotificationService().registerDevice(credential.user!.uid, token);
          }
          // ########################################################    
        
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

  // Sign in with Google account
  Future<UserCredential?> signInWithGoogle() async {
    Map<String, String>? deviceTokens = {};
    try {
      // Sign out the existing user
      await signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      DocumentReference docRef = _firestore.collection('users').doc(userCredential.user!.uid);
      DocumentSnapshot docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({'deviceTokens': deviceTokens});
      } else {
        // Determine the user type based on the email domain and platform
        String userType = 'Guest'; // Default to 'Google'
        if (userCredential.user!.email!.endsWith('@my.cspc.edu.ph')) {
          userType = 'Student';
        } else if (userCredential.user!.email!.endsWith('@cspc.edu.ph')) {
          userType = kIsWeb ? 'Admin' : 'Staff';
        }
        // Split the displayName into parts
        List<String> nameParts = userCredential.user!.displayName!.split(' ');

        // The first part is the first name
        String firstName = nameParts.first;

        // The last part is the last name
        String lastName = nameParts.last;

        // Create a new user object with the Google user's details
        model.User user = model.User(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          password: "",
          username: userCredential.user!.displayName,
          userType: userType,
          profile: model.Profile(
            fullName: userCredential.user!.displayName,
            firstName: firstName, // First name from Google
            middleInitial: "", // Not provided by Google
            lastName: lastName, // Last name from Google
            profileImage: userCredential.user!.photoURL, // Provided by Google
            phoneNumber: "", // Not provided by Google
            department: "", // Not provided by Google
            program: "", // Not provided by Google
            year: "", // Not provided by Google
            section: "", // Not provided by Google
            officerPosition: "", // Not provided by Google
            staffPosition: "", // Not provided by Google
            staffType: "", // Not provided by Google
            staffDescription: "", // Not provided by Google
            organization: "", // Not provided by Google
          ),
          deviceTokens: deviceTokens,
        );
        // Set the new user's details in Firestore
        await docRef.set(user.toJson());
      }
      var token = await _firebaseMessaging.getToken();
      if (token != null) {
        await FirebaseNotificationService().registerDevice(userCredential.user!.uid, token);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.message ?? "FirebaseAuth error occurred");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
    return null;
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    
  }
}

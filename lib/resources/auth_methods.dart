import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> getCurrentUserUid() async {
    User currentUser = _auth.currentUser!;
    return currentUser.uid;
  }

  Future<String> getCurrentUserType() async {
    final User currentUser = _auth.currentUser!;
    final DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return (snap.data() as Map<String, dynamic>)['userType'];
  }

  Future<String> signUpAsClient(
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
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        model.User user = model.User(
            uid: credential.user!.uid,
            email: email,
            username: username,
            userType: userType,
            profile: profile,
            password: password);

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());

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
        res = err.message!;
      }
    }
    return res;
  }

  Future<String> signUpAsAdmin(
      {required String username,
      required String password,
      String? email,
      required String userType,
      model.Profile? profile}) async {
    String res = "Enter valid credentials";

    try {
      if (username.isNotEmpty &&
          password.isNotEmpty &&
          userType.isNotEmpty &&
          profile != null &&
          profile.phoneNumber!.isNotEmpty) {
        email = '$username@gmail.com'; // generate email from username
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        model.User user = model.User(
          uid: credential.user!.uid,
          email: email,
          username: username,
          password: password,
          userType: userType,
          profile: profile,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());

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
        res = 'The account already exists for that username.';
      } else {
        res = err.message!;
      }
    }
    return res;
  }

  Future<String> loginAsAdmin(
      {required String username, required String password}) async {
    String res = "Enter valid credentials";

    try {
      if (username.isNotEmpty || password.isNotEmpty) {
        String email = '$username@gmail.com'; // generate email from username
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please enter username and password";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = 'No user found for that username.';
      } else if (err.code == 'wrong-password') {
        res = 'Wrong password provided for that user.';
      } else {
        res = err.message!;
      }
    }
    return res;
  }

  Future<String> loginAsClient(
      {required String email, required String password}) async {
    String res = "Enter valid credentials";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
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

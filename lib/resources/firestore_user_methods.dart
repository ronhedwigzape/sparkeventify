import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/storage_methods.dart';

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

  Future<Map<String, String>?> getUserDeviceTokens(String uid) async {
    try {
      DocumentSnapshot docSnapshot = await _usersCollection.doc(uid).get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('deviceTokens')) {
          return Map<String, String>.from(data['deviceTokens']);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device tokens: $e');
      }
      return null;
    }
  }

  // Future<void> deleteUser(String uid) async {
  //   try {
  //     final HttpsCallable callable = functions.httpsCallable('deleteUser');
  //     await callable.call(<String, dynamic>{'uid': uid});
  //     if (kDebugMode) {
  //       print('User deleted successfully');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error deleting user: $e}');
  //     }
  //   }
  // }

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

  /* Add user account */
  Future<String> addUser({
    required String email,
    required String password,
    String? username,
    required String userType,
    model.Profile? profile
  }) async {
    String res = "Enter valid credentials";
    Map<String, String>? deviceTokens = {};
    try {
      if (email.isNotEmpty && password.isNotEmpty && userType.isNotEmpty && profile != null) {
        // Check cspc email format based on userType
        if ((userType == 'Admin' || userType == 'Staff') && !email.endsWith('@cspc.edu.ph')) {
          return 'Invalid email format. Please use an email ending with @cspc.edu.ph';
        } else if ((userType == 'Student' || userType == 'Officer') && !email.endsWith('@my.cspc.edu.ph')) {
          return 'Invalid email format. Please use an email ending with @my.cspc.edu.ph';
        }
        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        model.User user = model.User(
          uid: credential.user!.uid,
          email: email,
          username: username,
          userType: userType,
          profile: profile,
          password: password,
          deviceTokens: deviceTokens,
        );
        await _usersCollection.doc(credential.user!.uid).set(user.toJson());
        res = "Success";
      } 
    } catch (err) {
      
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

  /* Update current user account details */
  Future<String> updateUser({
    required String uid,
    required String email,
    required String password,
    String? username,
    required String userType,
    model.Profile? profile
  }) async {
    String res = "Enter valid credentials";
    Map<String, String>? deviceTokens = {};
    try {
      if (email.isNotEmpty && password.isNotEmpty && userType.isNotEmpty) {

        // Check cspc email format based on userType
        if ((userType == 'Admin' || userType == 'Staff') && !email.endsWith('@cspc.edu.ph')) {
          return 'Invalid email format. Please use an email ending with @cspc.edu.ph';
        } else if ((userType == 'Student' || userType == 'Officer') && !email.endsWith('@my.cspc.edu.ph')) {
          return 'Invalid email format. Please use an email ending with @my.cspc.edu.ph';
        }
         // Check if phone number starts with 639 and has length of 12 digits
        if (!RegExp(r"^639\d{9}$").hasMatch(profile?.phoneNumber ?? '')) {
          return 'Please enter a valid phone number. (e.g. 639123456789)';
        }

        if (userType != "Staff" && userType != "Admin") {
          // Check if section is a single letter A-Z
          if (!RegExp(r"^[A-Z]$").hasMatch(profile?.section ?? '')) {
            return 'Section should be a single letter A-Z';
          }
          // Check if year is 1-4
          if (!RegExp(r"^[1-4]$").hasMatch(profile?.year ?? '')) {
            return 'Year should be 1-4';
          }
        }

        model.User user = model.User(
          uid: uid,
          email: email,
          username: username,
          userType: userType,
          profile: profile,
          password: password,
          deviceTokens: deviceTokens,
        );

        await _auth.currentUser!.updateEmail(email);
        await _auth.currentUser!.updatePassword(password);
        await _usersCollection.doc(uid).update(user.toJson());
        
        res = "Success";
      } 
    } catch (err) {
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

  /* Delete current user account */
  Future<String> deleteUser({
    required String uid,
    required String email,
    required String password,
  }) async {
    String res = "Enter valid credentials";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _usersCollection.doc(uid).delete();
        await _auth.currentUser!.delete();
        res = "Success";
      } 
    } catch (err) {
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

  Future<String> updateUserProfile({
    required String uid,
    String? username,
    required String userType,
    String? email,
    String? password,
    Map<String, String>? deviceTokens,
    model.Profile? profile
  }) async {
    String res = "Enter valid credentials";
    try {
      if (userType.isNotEmpty && profile != null) {
        // Check if phone number starts with 639 and has length of 12 digits
        if (!RegExp(r"^639\d{9}$").hasMatch(profile.phoneNumber ?? '')) {
          return 'Please enter a valid phone number. (e.g. 639123456789)';
        }

        if (userType != "Staff") {
          // Check if section is a single letter A-Z
          if (!RegExp(r"^[A-Z]$").hasMatch(profile.section ?? '')) {
            return 'Section should be a single letter A-Z';
          }
          // Check if year is 1-4
          if (!RegExp(r"^[1-4]$").hasMatch(profile.year ?? '')) {
            return 'Year should be 1-4';
          }
        }
        
        model.User user = model.User(
          uid: uid,
          username: username,
          userType: userType,
          email: email,
          password: password,
          profile: profile,
          deviceTokens: deviceTokens,
        );
        await _usersCollection.doc(uid).update(user.toJson());
        res = "Success";
      } 
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Stream function to get all users
  Stream<List<model.User>> getAllUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();
    });
  }

  // Stream function to get all user's userType
  Stream<List<String>> getUniqueUserTypes() {
    return getAllUsers().map((users) {
      Set<String> userTypes = <String>{};
      for (var user in users) {
        userTypes.add(user.userType);
      }
      return userTypes.toList();
    });
  }

  // Stream function to get all user's year
  Stream<List<String>> getUniqueYears() {
    return getAllUsers().map((users) {
      Set<String> years = <String>{};
      for (var user in users) {
        if (user.profile?.year != null) {
          years.add(user.profile!.year!);
        }
      }
      return years.toList();
    });
  }

  // Stream function to get all user's departments
  Stream<List<String>> getUniqueDepartments() {
    return getAllUsers().map((users) {
      Set<String> departments = <String>{};
      for (var user in users) {
        if (user.profile?.department != null) {
          departments.add(user.profile!.department!);
        }
      }
      return departments.toList();
    });
  }

  // Stream function to get all user's programs
  Stream<List<String>> getUniquePrograms() {
    return getAllUsers().map((users) {
      Set<String> programs = <String>{};
      for (var user in users) {
        if (user.profile?.program != null) {
          programs.add(user.profile!.program!);
        }
      }
      return programs.toList();
    });
  }

  // Stream function to get all user's sections
  Stream<List<String>> getUniqueSections() {
    return getAllUsers().map((users) {
      Set<String> sections = <String>{};
      for (var user in users) {
        if (user.profile?.section != null) {
          sections.add(user.profile!.section!);
        }
      }
      return sections.toList();
    });
  }

}

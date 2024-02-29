import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/profile.dart';

class User {
  String? uid;
  String? userType;
  String? username;
  String? password;
  String? email;
  bool? disabled;
  Map<String, String>? deviceTokens;
  Profile? profile;
  final bool signedInWithGoogle;

  User(
      {this.uid,
      this.userType,
      this.username,
      this.password,
      this.email,
      this.disabled,
      this.deviceTokens,
      this.profile,
      this.signedInWithGoogle = false});

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userType': userType,
        'username': username,
        'password': password,
        'email': email,
        'disabled': disabled,
        'deviceTokens': deviceTokens,
        'profile': profile?.toJson(),
        'signedInWithGoogle': signedInWithGoogle,
      };

  // Create User object from DocumentSnapshot
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    var profileSnap = snapshot['profile'] as Map<String, dynamic>;

    return User(
      uid: snapshot['uid'],
      userType: snapshot['userType'],
      username: snapshot['username'],
      password: snapshot['password'],
      email: snapshot['email'],
      disabled: snapshot['disabled'],
      deviceTokens: Map<String, String>.from(snapshot['deviceTokens']),
      profile: Profile.fromMap(profileSnap),
      signedInWithGoogle: snapshot['signedInWithGoogle'] ?? false,
    );
  }
}

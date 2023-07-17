import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/profile.dart';

class User {
  String uid;
  String userType;
  String? username;
  String password;
  String email;
  Map<String, String>? deviceTokens;
  Profile? profile;

  User({
    required this.uid,
    required this.userType,
    this.username,
    required this.password,
    required this.email,
    this.deviceTokens,
    this.profile, 
  });

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userType': userType,
        'username': username,
        'password': password,
        'email': email,
        'deviceTokens': deviceTokens,
        'profile': profile?.toJson(),
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
      deviceTokens: Map<String, String>.from(snapshot['deviceTokens']),
      profile: Profile.fromMap(profileSnap),
    );
  }
}

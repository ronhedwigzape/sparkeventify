import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/profile.dart';

class User {
  final String uid;
  final String userType;
  final String? username;
  final String password;
  final String email;
  final Profile? profile;

  const User({
    required this.uid,
    required this.userType,
    this.username,
    required this.password,
    required this.email,
    this.profile,
  });

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userType': userType,
        'username': username,
        'password': password,
        'email': email,
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
      profile: Profile.fromMap(profileSnap),
    );
  }
}

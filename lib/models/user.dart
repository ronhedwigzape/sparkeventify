import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/models/profile.dart';

class User {
  final String uid;
  final String userType;
  final String username;
  final String email;
  final Profile? profile;

  const User({
    required this.uid,
    required this.userType,
    required this.username,
    required this.email,
    this.profile,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userType': userType,
        'username': username,
        'email': email,
        'profile': profile?.toJson(),
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    var profileSnap = snapshot['profile'] as Map<String, dynamic>;

    return User(
      uid: snapshot['uid'],
      userType: snapshot['userType'],
      username: snapshot['username'],
      email: snapshot['email'],
      profile: Profile.fromMap(profileSnap),
    );
  }
}

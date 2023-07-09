import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart' as custom;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserState { waiting, authenticated, unauthenticated, error }

class NotAuthenticated implements Exception {
  String cause;
  NotAuthenticated(this.cause);
}

class UserProvider with ChangeNotifier {
  UserState _userState = UserState.waiting;

  UserState get userState => _userState;

  custom.User? _user;
  final AuthMethods _authMethods = AuthMethods();

  custom.User get getUser => _user ?? (throw NotAuthenticated("User credentials not found, please login"));

  UserProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _userState = UserState.unauthenticated;
      } else {
        refreshUser();
      }
      notifyListeners();
    });
  }

  Future<void> refreshUser() async {
    custom.User? user = await _authMethods.getUserDetails();

    // ignore: unnecessary_null_comparison
    if (user != null) {
      _user = user;
      _userState = UserState.authenticated;
    } else {
      _userState = UserState.error;
      throw NotAuthenticated("User credentials not found, please login");
    }

    notifyListeners();
  }
}

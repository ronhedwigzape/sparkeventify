// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart' as custom;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum to represent the different states of the user
enum UserState { waiting, authenticated, unauthenticated, error }

// Custom exception class for not authenticated users
class NotAuthenticated implements Exception {
  String cause;
  NotAuthenticated(this.cause);
}

class UserProvider with ChangeNotifier {
  UserState _userState = UserState.waiting;

  UserState get userState => _userState;

  custom.User? _user;
  final AuthMethods _authMethods = AuthMethods();

  custom.User get getUser =>
      _user ?? (throw NotAuthenticated("User credentials not found, please login"));

  UserProvider() {
    // Listen to the authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _userState = UserState.unauthenticated;
      } else {
        refreshUser();
      }
      notifyListeners();
    });
  }

  // Method to refresh the user details
  Future<void> refreshUser() async {
    custom.User? user = await _authMethods.getUserDetails();

    // Check if user details are available
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

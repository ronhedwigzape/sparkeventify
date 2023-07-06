import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';

enum UserState { waiting, authenticated, unauthenticated, error }

class UserProvider with ChangeNotifier {
  final UserState _userState = UserState.waiting;

  UserState get userState => _userState;

  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;

    notifyListeners();
  }
}